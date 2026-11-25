import Foundation
import CoreLocation

@MainActor
final class LocationService: NSObject,
                             LocationServiceProtocol,
                             @preconcurrency CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()

    private var continuation:
        CheckedContinuation<CLLocation, Error>?

    private var timeoutTask: Task<Void, Never>?
    private var requestID: UUID?
    private var hasRequestedLocation = false

    // MARK: - Initialization

    override init() {

        super.init()

        locationManager.delegate = self

        locationManager.desiredAccuracy =
            kCLLocationAccuracyHundredMeters
    }

    // MARK: - Request Location

    func requestCurrentLocation() async throws -> CLLocation {

        try Task.checkCancellation()

        guard continuation == nil else {
            throw LocationServiceError.requestInProgress
        }

        let id = UUID()

        return try await withTaskCancellationHandler {

            try await withCheckedThrowingContinuation {
                (continuation: CheckedContinuation<CLLocation, Error>) in

                self.continuation = continuation
                self.requestID = id
                self.hasRequestedLocation = false

                startTimeout(for: id)
                handleAuthorization()
            }

        } onCancel: {

            Task { @MainActor in

                guard self.requestID == id else {
                    return
                }

                self.finish(
                    with: .failure(CancellationError())
                )
            }
        }
    }

    // MARK: - Authorization

    private func handleAuthorization() {

        guard continuation != nil else {
            return
        }

        switch locationManager.authorizationStatus {

        case .notDetermined:

            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:

            guard !hasRequestedLocation else {
                return
            }

            hasRequestedLocation = true
            locationManager.requestLocation()

        case .denied:

            finish(
                with: .failure(
                    LocationServiceError.permissionDenied
                )
            )

        case .restricted:

            finish(
                with: .failure(
                    LocationServiceError.permissionRestricted
                )
            )

        @unknown default:

            finish(
                with: .failure(
                    LocationServiceError.locationUnavailable
                )
            )
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {

        handleAuthorization()
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {

        guard let location = locations.last(where: {
            $0.horizontalAccuracy >= 0
        }) else {

            finish(
                with: .failure(
                    LocationServiceError.locationUnavailable
                )
            )

            return
        }

        finish(with: .success(location))
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {

        finish(with: .failure(error))
    }

    // MARK: - Timeout

    private func startTimeout(for id: UUID) {

        timeoutTask?.cancel()

        timeoutTask = Task { [weak self] in

            do {

                try await Task.sleep(
                    for: .seconds(
                        AppConstants.Stores.locationTimeoutSeconds
                    )
                )

            } catch {
                return
            }

            guard let self,
                  self.requestID == id else {
                return
            }

            self.finish(
                with: .failure(
                    LocationServiceError.requestTimedOut
                )
            )
        }
    }

    // MARK: - Finish Request

    private func finish(
        with result: Result<CLLocation, Error>
    ) {

        guard let continuation = continuation else {
            return
        }

        self.continuation = nil
        self.requestID = nil
        self.hasRequestedLocation = false

        timeoutTask?.cancel()
        timeoutTask = nil

        locationManager.stopUpdatingLocation()

        continuation.resume(with: result)
    }
}

// MARK: - Location Errors

enum LocationServiceError: LocalizedError {

    case permissionDenied
    case permissionRestricted
    case locationUnavailable
    case requestInProgress
    case requestTimedOut

    var errorDescription: String? {

        switch self {

        case .permissionDenied:
            return "Location permission was denied. You can enable it in Settings."

        case .permissionRestricted:
            return "Location services are restricted on this device."

        case .locationUnavailable:
            return "Your current location could not be determined."

        case .requestInProgress:
            return "A location request is already in progress."

        case .requestTimedOut:
            return "The location request took too long. Please try again."
        }
    }
}
