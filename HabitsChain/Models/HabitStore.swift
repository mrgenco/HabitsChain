import Foundation
import Combine

class HabitStore: ObservableObject {
    @Published var habits: [Habit] = []
    
    init() {
        load()
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: "Habits")
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: "Habits"),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
    }
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        save()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            save()
        }
    }
}
