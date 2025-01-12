import SwiftUI

struct HabitDetailView: View {
    @Environment(\.dismiss) var dismiss
    let habit: Habit
    let onUpdate: (Habit) -> Void
    
    @State private var editedHabit: Habit
    @State private var showingReminderSettings = false
    @State private var showingDeleteConfirmation = false
    @State private var showingEditName = false
    @State private var newName: String = ""
    
    init(habit: Habit, onUpdate: @escaping (Habit) -> Void) {
        self.habit = habit
        self.onUpdate = onUpdate
        _editedHabit = State(initialValue: habit)
        _newName = State(initialValue: habit.name)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats Section
                    HStack(spacing: 40) {
                        StatView(title: "Current Streak", value: "\(editedHabit.currentStreak)")
                        StatView(title: "Best Streak", value: "\(editedHabit.longestStreak)")
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    
                    // Calendar Section
                    VStack(alignment: .leading) {
                        Text("History")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        CalendarView(habit: editedHabit, onUpdate: { updatedHabit in
                            editedHabit = updatedHabit
                            onUpdate(updatedHabit)
                        })
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    
                    // Reminder Section
                    Button(action: {
                        showingReminderSettings = true
                    }) {
                        HStack {
                            Image(systemName: editedHabit.reminder?.isEnabled == true ? "bell.fill" : "bell")
                                .foregroundColor(editedHabit.reminder?.isEnabled == true ? .blue : .gray)
                            Text("Reminder")
                            Spacer()
                            if let reminder = editedHabit.reminder, reminder.isEnabled {
                                Text(reminder.time.formatted(date: .omitted, time: .shortened))
                                    .foregroundColor(.secondary)
                            }
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(editedHabit.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Edit Name") {
                            showingEditName = true
                        }
                        Button("Delete", role: .destructive) {
                            showingDeleteConfirmation = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingReminderSettings) {
                ReminderSettingsView(habit: editedHabit) { updatedHabit in
                    editedHabit = updatedHabit
                    onUpdate(updatedHabit)
                }
            }
            .alert("Edit Habit Name", isPresented: $showingEditName) {
                TextField("Habit Name", text: $newName)
                Button("Cancel", role: .cancel) {}
                Button("Save") {
                    if !newName.isEmpty {
                        var updatedHabit = editedHabit
                        updatedHabit.name = newName
                        editedHabit = updatedHabit
                        onUpdate(updatedHabit)
                    }
                }
            }
            .alert("Delete Habit", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this habit? This action cannot be undone.")
            }
        }
    }
}

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
} 
