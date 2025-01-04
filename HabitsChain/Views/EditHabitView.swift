import SwiftUI

struct EditHabitView: View {
    @Environment(\.dismiss) var dismiss
    let habit: Habit
    let onSave: (Habit) -> Void
    
    @State private var habitName: String
    
    init(habit: Habit, onSave: @escaping (Habit) -> Void) {
        self.habit = habit
        self.onSave = onSave
        _habitName = State(initialValue: habit.name)
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Habit name", text: $habitName)
            }
            .navigationTitle("Edit Habit")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    var updatedHabit = habit
                    updatedHabit.name = habitName
                    onSave(updatedHabit)
                    dismiss()
                }
                .disabled(habitName.isEmpty)
            )
        }
    }
}

#Preview {
    EditHabitView(habit: Habit(name: "Example Habit")) { _ in }
} 