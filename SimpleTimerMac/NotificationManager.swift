import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                completion(true) // Déjà autorisé
            case .denied:
                completion(false) // Refusé
            case .notDetermined:
                // Demander l'autorisation
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                    if granted {
                        print("Notifications autorisées")
                        completion(true)
                    } else {
                        if let error = error {
                            print("Erreur d'autorisation des notifications: \(error.localizedDescription)")
                        }
                        completion(false)
                    }
                }
            @unknown default:
                completion(false)
            }
        }
    }
    
    func scheduleNotification(for timeInterval: TimeInterval) {
        // Vérifier et demander l'autorisation si nécessaire avant de planifier
        requestAuthorizationIfNeeded { authorized in
            guard authorized else {
                print("Impossible de planifier la notification: autorisation refusée ou non accordée.")
                return
            }
            
            // Continuer avec la planification si autorisé
            let content = UNMutableNotificationContent()
            content.title = "Timer terminé"
            content.body = "Votre minuteur est terminé !"
            content.sound = UNNotificationSound.default
            
            // Utiliser un délai très court (ex: 0.1s) si timeInterval est 0 pour que la notif s'affiche immédiatement
            let effectiveTimeInterval = max(0.1, timeInterval)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: effectiveTimeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Erreur lors de la planification de la notification: \(error.localizedDescription)")
                }
            }
        }
    }
} 