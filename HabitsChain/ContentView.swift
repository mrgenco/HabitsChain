import SwiftUI

struct ContentView: View {
    @StateObject private var habitStore = HabitStore()
    @State private var showingAddHabit = false
    @State private var selectedHabit: Habit?
    @State private var selectedTab = 0
    
    init() {
        // If you have NotificationManager, call it here
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
                        Button {
                            showingAddHabit = true
                        } label: {
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
            AddHabitView { habit in
                habitStore.habits.append(habit)
                habitStore.save()
            }
        }
        .sheet(item: $selectedHabit) { habit in
            HabitDetailView(habit: habit) { updatedHabit in
                if let index = habitStore.habits.firstIndex(where: { $0.id == updatedHabit.id }) {
                    habitStore.habits[index] = updatedHabit
                    habitStore.save()
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
                            habitStore.save()
                        }
                    },
                    onTap: {
                        selectedHabit = habit
                    }
                )
            }
            .onDelete { indexSet in
                habitStore.habits.remove(atOffsets: indexSet)
                habitStore.save()
            }
        }
        .navigationTitle("My Habits")
        .toolbar {
            Button {
                showingAddHabit = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

// Example row view
struct HabitRowView: View {
    let habit: Habit
    let onUpdate: (Habit) -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
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
                    
                    if isCompletedToday {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .imageScale(.large)
                    }
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 12)
            .background(isCompletedToday ? Color.green.opacity(0.1) : Color.clear)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
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
            // Remove today's date from the completed dates
            updatedHabit.completedDates = updatedHabit.completedDates.filter { !calendar.isDate($0, inSameDayAs: today) }
        } else {
            // Insert today's date if it's not completed yet
            updatedHabit.completedDates.insert(today)
        }
        
        onUpdate(updatedHabit)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
