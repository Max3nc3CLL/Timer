import Foundation
import UserNotifications
import Combine // Importer Combine pour ObservableObject et @Published

class TimerManager: ObservableObject {
    @Published var timeRemaining: TimeInterval = 0
    @Published var isRunning = false

    private var timer: Timer?
    private let notificationManager = NotificationManager.shared
    private let userPreferences = UserPreferences.shared

    init() {
        timeRemaining = userPreferences.lastTimerDuration
        // S'assurer que le temps initial n'est pas négatif
        if timeRemaining < 0 {
            timeRemaining = 0
        }
    }

    var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        // Utiliser .monospacedDigitSystemFont pour potentiellement mieux s'aligner dans la barre de menu
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func toggleTimer() {
        if isRunning {
            timer?.invalidate()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        } else {
            // S'assurer qu'il y a du temps restant avant de démarrer
            if timeRemaining > 0 {
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                    guard let self = self else { return }
                    if self.timeRemaining > 0 {
                        self.timeRemaining -= 1
                        // Sauvegarder la durée actuelle peut être fait ici ou lors de la pause/arrêt
                        // self.userPreferences.saveCurrentTimerDuration(self.timeRemaining)
                    } else {
                        self.timer?.invalidate()
                        self.isRunning = false
                        self.notificationManager.scheduleNotification(for: 0) // Notifier immédiatement à la fin
                        // Optionnel: réinitialiser à la dernière durée sauvegardée ou à 0 ?
                        // self.timeRemaining = self.userPreferences.lastTimerDuration
                    }
                }
            } else {
                 // Ne pas démarrer si le temps est à 0
                 isRunning = false // Assurer que l'état est correct
                 return // Sortir de la fonction
            }
        }
        isRunning.toggle()
    }

    func resetTimer() {
        timer?.invalidate()
        isRunning = false
        timeRemaining = userPreferences.lastTimerDuration // Revenir à la dernière durée sauvegardée au lieu de 0 ? Ou garder 0 ? Pour l'instant 0.
        timeRemaining = 0 // Conformément à l'ancien code
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        userPreferences.saveCurrentTimerDuration(timeRemaining) // Sauvegarder 0
    }

    func adjustTime(by seconds: TimeInterval) {
        // Ne pas ajuster si le minuteur est en cours d'exécution pour éviter les comportements inattendus
        if !isRunning {
            timeRemaining = max(0, timeRemaining + seconds)
            userPreferences.saveCurrentTimerDuration(timeRemaining)
        }
    }

    // Fonction pour préparer l'arrêt (par exemple, lors de la fermeture de l'application)
    func prepareForTermination() {
        if isRunning {
            timer?.invalidate()
            // Sauvegarder l'état actuel si nécessaire
            userPreferences.saveCurrentTimerDuration(timeRemaining)
        }
    }
} 