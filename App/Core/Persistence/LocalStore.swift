import Foundation

protocol KeyValueStore {
    func string(forKey key: String) -> String?
    func set(_ value: String?, forKey key: String)
    func date(forKey key: String) -> Date?
    func set(_ value: Date?, forKey key: String)
}

struct UserDefaultsStore: KeyValueStore {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func string(forKey key: String) -> String? {
        userDefaults.string(forKey: key)
    }

    func set(_ value: String?, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    func date(forKey key: String) -> Date? {
        userDefaults.object(forKey: key) as? Date
    }
    
    func set(_ value: Date?, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
}
