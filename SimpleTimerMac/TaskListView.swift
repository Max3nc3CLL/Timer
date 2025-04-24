import SwiftUI

// MARK: - TaskListView
struct TaskListView: View {
    @ObservedObject var taskManager: TaskManager
    @State private var newTaskTitle = ""
    
    var body: some View {
        VStack(spacing: 4) {
            TaskListScrollView(
                taskManager: taskManager,
                newTaskTitle: $newTaskTitle
            )
            
            Divider()
                .background(Color.white.opacity(0.15))
            
            TaskCounterView(taskManager: taskManager)
        }
        .onSubmit {
            addNewTask()
        }
    }
    
    private func addNewTask() {
        guard !newTaskTitle.isEmpty else { return }
        withAnimation {
            taskManager.addTask(newTaskTitle)
            newTaskTitle = ""
        }
    }
}

// MARK: - TaskListScrollView
private struct TaskListScrollView: View {
    @ObservedObject var taskManager: TaskManager
    @Binding var newTaskTitle: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 2) {
                TaskListContent(taskManager: taskManager)
                NewTaskInputField(newTaskTitle: $newTaskTitle)
            }
        }
        .frame(maxHeight: taskManager.tasks.isEmpty ? 40 : nil)
    }
}

// MARK: - TaskListContent
private struct TaskListContent: View {
    @ObservedObject var taskManager: TaskManager
    
    var body: some View {
        ForEach(taskManager.tasks.filter { !$0.isCompleted }) { task in
            VStack {
                TaskRow(task: task, onToggle: handleTaskToggle)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                
                if task.id != taskManager.tasks.last?.id {
                    TaskDivider()
                }
            }
        }
        
        if !taskManager.tasks.isEmpty {
            TaskDivider()
        }
    }
    
    private func handleTaskToggle(_ task: Task) {
        withAnimation(.easeOut(duration: 0.2)) {
            taskManager.toggleTask(task)
            if task.isCompleted {
                taskManager.removeCompletedTasks()
            }
        }
    }
}

// MARK: - NewTaskInputField
private struct NewTaskInputField: View {
    @Binding var newTaskTitle: String
    
    var body: some View {
        HStack {
            TextField("Qu'est-ce que tu dois faire aujourd'hui ?", text: $newTaskTitle)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.8))
                .opacity(0.5)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

// MARK: - TaskCounterView
private struct TaskCounterView: View {
    @ObservedObject var taskManager: TaskManager
    
    var body: some View {
        HStack {
            Text("Tâches faites : \(taskManager.completedTasksCount)/\(taskManager.totalTasksCount)")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.5))
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 2)
        .padding(.bottom, 6)
    }
}

// MARK: - TaskDivider
private struct TaskDivider: View {
    var body: some View {
        Divider()
            .background(Color.white.opacity(0.05))
            .padding(.horizontal)
    }
}

// MARK: - TaskRow
struct TaskRow: View {
    let task: Task
    let onToggle: (Task) -> Void
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            TaskTitle(title: task.title, isCompleted: task.isCompleted)
            Spacer()
            TaskCheckbox(isCompleted: task.isCompleted, isHovered: isHovered)
        }
        .contentShape(Rectangle())
        .onTapGesture { onToggle(task) }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - TaskTitle
private struct TaskTitle: View {
    let title: String
    let isCompleted: Bool
    
    var body: some View {
        Text(title)
            .font(.system(size: 13))
            .foregroundColor(isCompleted ? .white.opacity(0.5) : .white.opacity(0.8))
            .lineLimit(1)
    }
}

// MARK: - TaskCheckbox
private struct TaskCheckbox: View {
    let isCompleted: Bool
    let isHovered: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(
                    isHovered || isCompleted ? Color.white.opacity(0.8) : Color.white.opacity(0.3),
                    lineWidth: 1.5
                )
                .frame(width: 16, height: 16)
            
            if isCompleted {
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 10, height: 10)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    TaskListView(taskManager: TaskManager())
        .frame(width: 300)
        .preferredColorScheme(.dark)
} 