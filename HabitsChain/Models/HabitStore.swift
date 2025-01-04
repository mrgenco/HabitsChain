import Foundation

@Observable
class HabitStore {
    private static let habitsKey = "habits"
    var habits: [Habit] = [] {
        didSet {
            saveHabits()
        }
    }
    
    init() {
        loadHabits()
    }
    
    private func loadHabits() {
        guard let data = UserDefaults.standard.data(forKey: Self.habitsKey) else { return }
        
        do {
            habits = try JSONDecoder().decode([Habit].self, from: data)
        } catch {
            print("Error loading habits: \(error)")
        }
    }
    
    private func saveHabits() {
        do {
            let data = try JSONEncoder().encode(habits)
            UserDefaults.standard.set(data, forKey: Self.habitsKey)
        } catch {
            print("Error saving habits: \(error)")
        }
    }
} 