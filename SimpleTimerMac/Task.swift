import Foundation
import Combine

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var dateCreated: Date
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.dateCreated = Date()
    }
}

class TaskManager: ObservableObject {
    @Published private(set) var tasks: [Task] = []
    private let saveKey = "savedTasks"
    private let lastResetKey = "lastResetDate"
    private var resetTimer: Timer?
    
    init() {
        loadTasks()
        checkAndResetTasks()
        setupDailyReset()
    }
    
    deinit {
        resetTimer?.invalidate()
    }
    
    var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var totalTasksCount: Int {
        tasks.count
    }
    
    func addTask(_ title: String) {
        let task = Task(title: title)
        tasks.append(task)
        saveTasks()
    }
    
    func toggleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
        }
    }
    
    func removeCompletedTasks() {
        tasks.removeAll(where: { $0.isCompleted })
        saveTasks()
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }
    
    // MARK: - Daily Reset Logic
    
    private func setupDailyReset() {
        // Calculer le prochain reset à 6h du matin
        let nextReset = calculateNextResetDate()
        
        // Configurer le timer pour le prochain reset
        resetTimer = Timer(fire: nextReset, interval: 24 * 60 * 60, repeats: true) { [weak self] _ in
            self?.checkAndResetTasks()
        }
        
        // S'assurer que le timer continue même si l'appareil est en veille
        if let timer = resetTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func calculateNextResetDate() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 6
        components.minute = 0
        components.second = 0
        
        var nextReset = calendar.date(from: components)!
        
        // Si on est après 6h du matin, programmer pour le lendemain
        if nextReset <= Date() {
            nextReset = calendar.date(byAdding: .day, value: 1, to: nextReset)!
        }
        
        return nextReset
    }
    
    private func checkAndResetTasks() {
        let defaults = UserDefaults.standard
        let calendar = Calendar.current
        
        // Vérifier la dernière date de reset
        let lastReset = defaults.object(forKey: lastResetKey) as? Date ?? Date.distantPast
        let now = Date()
        
        // Vérifier si nous devons réinitialiser (si la dernière réinitialisation était avant 6h aujourd'hui)
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 6
        components.minute = 0
        components.second = 0
        let todayReset = calendar.date(from: components)!
        
        if lastReset < todayReset && now >= todayReset {
            // Réinitialiser les tâches
            tasks.removeAll()
            saveTasks()
            
            // Sauvegarder la date de réinitialisation
            defaults.set(now, forKey: lastResetKey)
        }
    }
} 