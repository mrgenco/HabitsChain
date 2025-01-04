import SwiftUI

struct ReminderSettingsView: View {
    @Environment(\.dismiss) var dismiss
    let habit: Habit
    let onUpdate: (Habit) -> Void
    
    @State private var isEnabled: Bool
    @State private var reminderTime: Date
    @State private var selectedWeekdays: Set<Int>
    
    init(habit: Habit, onUpdate: @escaping (Habit) -> Void) {
        self.habit = habit
        self.onUpdate = onUpdate
        
        _isEnabled = State(initialValue: habit.reminder?.isEnabled ?? false)
        _reminderTime = State(initialValue: habit.reminder?.time ?? Date())
        _selectedWeekdays = State(initialValue: habit.reminder?.weekdays ?? Set(1...7))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Enable Reminder", isOn: $isEnabled)
                    
                    if isEnabled {
                        DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                if isEnabled {
                    Section(header: Text("Repeat on")) {
                        ForEach(1...7, id: \.self) { weekday in
                            Toggle(Calendar.current.weekdaySymbol(for: weekday), isOn: Binding(
                                get: { selectedWeekdays.contains(weekday) },
                                set: { isSelected in
                                    if isSelected {
                                        selectedWeekdays.insert(weekday)
                                    } else {
                                        selectedWeekdays.remove(weekday)
                                    }
                                }
                            ))
                        }
                    }
                }
            }
            .navigationTitle("Reminder Settings")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveReminder()
                }
            )
        }
    }
    
    private func saveReminder() {
        var updatedHabit = habit
        if isEnabled {
            updatedHabit.reminder = HabitReminder(
                time: reminderTime,
                isEnabled: true,
                weekdays: selectedWeekdays
            )
        } else {
            updatedHabit.reminder = nil
        }
        
        onUpdate(updatedHabit)
        
        if isEnabled {
            NotificationManager.shared.scheduleHabitReminder(habit: updatedHabit)
        } else {
            NotificationManager.shared.removeHabitReminders(habitId: habit.id)
        }
        
        dismiss()
    }
}

extension Calendar {
    func weekdaySymbol(for weekday: Int) -> String {
        let symbols = self.weekdaySymbols
        let index = (weekday - 1) % 7
        return symbols[index]
    }
} 