import Foundation

class UserPreferences {
    static let shared = UserPreferences()
    
    private let defaults = UserDefaults.standard
    private let lastTimerDurationKey = "lastTimerDuration"
    
    private init() {}
    
    var lastTimerDuration: TimeInterval {
        get {
            return defaults.double(forKey: lastTimerDurationKey)
        }
        set {
            defaults.set(newValue, forKey: lastTimerDurationKey)
        }
    }
    
    func saveCurrentTimerDuration(_ duration: TimeInterval) {
        lastTimerDuration = duration
    }
} 