import Foundation
import SwiftData

struct AppContainer {
    let environment: AppEnvironment
    let authProvider: AuthProviding
    let networkClient: NetworkClient
    let healthAPI: HealthAPI
    let logger: AppLogger
    let keyValueStore: KeyValueStore
    let moodRepository: MoodRepositoryProtocol

    @MainActor
    static func live(bundle: Bundle = .main) -> AppContainer {
        let environment = (try? AppEnvironment.live(bundle: bundle)) ?? .fallback
        let logger = AppLoggerFactory.live(subsystem: "com.cankocakulak.moodflicker2")
        let authProvider = StaticTokenAuthProvider(token: nil)
        let keyValueStore = UserDefaultsStore(userDefaults: .standard)
        let networkClient = URLSessionNetworkClient(
            environment: environment,
            authProvider: authProvider,
            logger: logger)
        let healthAPI = LiveHealthAPI(client: networkClient)
        let moodRepository = try! MoodRepository()

        return AppContainer(
            environment: environment,
            authProvider: authProvider,
            networkClient: networkClient,
            healthAPI: healthAPI,
            logger: logger,
            keyValueStore: keyValueStore,
            moodRepository: moodRepository)
    }
}
