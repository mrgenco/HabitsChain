import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @State private var habitName = ""
    @State private var showingReminderSettings = false
    @State private var reminder: HabitReminder?
    let onAdd: (Habit) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Habit Details")) {
                    TextField("Habit Name", text: $habitName)
                }
                
                Section {
                    Button(action: {
                        showingReminderSettings = true
                    }) {
                        HStack {
                            Image(systemName: reminder?.isEnabled == true ? "bell.fill" : "bell")
                                .foregroundColor(reminder?.isEnabled == true ? .blue : .gray)
                            Text("Reminder")
                            Spacer()
                            if let reminder = reminder, reminder.isEnabled {
                                Text(reminder.time.formatted(date: .omitted, time: .shortened))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let newHabit = Habit(name: habitName, reminder: reminder)
                        onAdd(newHabit)
                        if let reminder = reminder, reminder.isEnabled {
                            NotificationManager.shared.scheduleHabitReminder(habit: newHabit)
                        }
                        dismiss()
                    }
                    .disabled(habitName.isEmpty)
                }
            }
            .sheet(isPresented: $showingReminderSettings) {
                ReminderSettingsView(
                    habit: Habit(name: habitName, reminder: reminder)
                ) { updatedHabit in
                    reminder = updatedHabit.reminder
                }
            }
        }
    }
}

#Preview {
    AddHabitView(onAdd: { _ in })
} 