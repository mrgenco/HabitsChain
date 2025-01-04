import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var habits: [Habit]
    @State private var habitName = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Habit name", text: $habitName)
            }
            .navigationTitle("New Habit")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Add") {
                    let habit = Habit(name: habitName)
                    habits.append(habit)
                    dismiss()
                }
                .disabled(habitName.isEmpty)
            )
        }
    }
}

#Preview {
    AddHabitView(habits: .constant([]))
} 