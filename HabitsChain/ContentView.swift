//
//  ContentView.swift
//  HabitsChain
//
//  Created by Mehmet Rasid Gencosmanoglu on 30.12.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var habitStore = HabitStore()
    @State private var showingAddHabit = false
    @State private var habitToEdit: Habit?
    @State private var selectedTab = 0
    @State private var habitToShowCalendar: Habit?
    @State private var habitToShowReminder: Habit?
    
    init() {
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                habitsList
            }
            .tabItem {
                Label("Habits", systemImage: "list.bullet")
            }
            .tag(0)
            
            NavigationView {
                DashboardView(habits: habitStore.habits)
                    .navigationTitle("Dashboard")
                    .toolbar {
                        Button(action: {
                            showingAddHabit = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.bar.fill")
            }
            .tag(1)
        }
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView(habits: $habitStore.habits)
        }
        .sheet(item: $habitToEdit) { habit in
            EditHabitView(habit: habit) { updatedHabit in
                if let index = habitStore.habits.firstIndex(where: { $0.id == updatedHabit.id }) {
                    habitStore.habits[index] = updatedHabit
                }
            }
        }
    }
    
    private var habitsList: some View {
        List {
            ForEach(habitStore.habits) { habit in
                HabitRowView(
                    habit: habit,
                    onUpdate: { updatedHabit in
                        if let index = habitStore.habits.firstIndex(where: { $0.id == updatedHabit.id }) {
                            habitStore.habits[index] = updatedHabit
                        }
                    },
                    onCalendarTap: {
                        habitToShowCalendar = habit
                    },
                    onReminderTap: {
                        habitToShowReminder = habit
                    }
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        if let index = habitStore.habits.firstIndex(where: { $0.id == habit.id }) {
                            habitStore.habits.remove(at: index)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        habitToEdit = habit
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
        .navigationTitle("My Habits")
        .toolbar {
            Button(action: {
                showingAddHabit = true
            }) {
                Image(systemName: "plus")
            }
        }
        .sheet(item: $habitToShowCalendar) { habit in
            NavigationView {
                CalendarView(habit: habit) { updatedHabit in
                    if let index = habitStore.habits.firstIndex(where: { $0.id == updatedHabit.id }) {
                        habitStore.habits[index] = updatedHabit
                    }
                }
                .navigationTitle(habit.name)
                .navigationBarItems(trailing: Button("Done") {
                    habitToShowCalendar = nil
                })
            }
        }
        .sheet(item: $habitToShowReminder) { habit in
            ReminderSettingsView(habit: habit) { updatedHabit in
                if let index = habitStore.habits.firstIndex(where: { $0.id == updatedHabit.id }) {
                    habitStore.habits[index] = updatedHabit
                }
            }
        }
    }
}

struct HabitRowView: View {
    let habit: Habit
    let onUpdate: (Habit) -> Void
    let onCalendarTap: () -> Void
    let onReminderTap: () -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(habit.name)
                        .font(.headline)
                    HStack {
                        Text("Current streak: \(habit.currentStreak) days")
                            .font(.subheadline)
                        Spacer()
                        Text("Best: \(habit.longestStreak) days")
                            .font(.subheadline)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
            }
            
            if isExpanded {
                HStack(spacing: 12) {
                    Button(action: onCalendarTap) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Calendar")
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Button(action: onReminderTap) {
                        HStack {
                            Image(systemName: "bell")
                            Text("Reminder")
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 8)
        .swipeActions(edge: .leading) {
            Button {
                toggleCompletion()
            } label: {
                Label(isCompletedToday ? "Uncomplete" : "Complete", 
                      systemImage: isCompletedToday ? "xmark.circle" : "checkmark.circle")
            }
            .tint(isCompletedToday ? .red : .green)
        }
    }
    
    private var isCompletedToday: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return habit.completedDates.contains { date in
            calendar.isDate(date, inSameDayAs: today)
        }
    }
    
    private func toggleCompletion() {
        var updatedHabit = habit
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if isCompletedToday {
            let datesToRemove = updatedHabit.completedDates.filter { date in
                calendar.isDate(date, inSameDayAs: today)
            }
            datesToRemove.forEach { updatedHabit.completedDates.remove($0) }
        } else {
            updatedHabit.completedDates.insert(today)
        }
        
        onUpdate(updatedHabit)
    }
}

#Preview {
    ContentView()
}
