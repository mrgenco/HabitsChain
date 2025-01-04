import Foundation

struct Habit: Identifiable, Codable {
    let id: UUID
    var name: String
    var createdDate: Date
    var completedDates: Set<Date>
    var reminder: HabitReminder?
    
    init(id: UUID = UUID(), name: String, createdDate: Date = Date(), reminder: HabitReminder? = nil) {
        self.id = id
        self.name = name
        self.createdDate = createdDate
        self.completedDates = []
        self.reminder = reminder
    }
    
    var currentStreak: Int {
        calculateCurrentStreak()
    }
    
    var longestStreak: Int {
        calculateLongestStreak()
    }
    
    private func calculateCurrentStreak() -> Int {
        let calendar = Calendar.current
        let today = Date()
        var currentDate = today
        var streak = 0
        
        // Go backwards from today until we find a day that's not completed
        while true {
            let isCompleted = completedDates.contains { date in
                calendar.isDate(date, inSameDayAs: currentDate)
            }
            
            if !isCompleted {
                break
            }
            
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }
        
        return streak
    }
    
    private func calculateLongestStreak() -> Int {
        let calendar = Calendar.current
        let sortedDates = completedDates.sorted()
        var longestStreak = 0
        var currentStreak = 0
        var previousDate: Date?
        
        for date in sortedDates {
            if let previous = previousDate {
                let dayDifference = calendar.dateComponents([.day], from: previous, to: date).day ?? 0
                if dayDifference == 1 {
                    currentStreak += 1
                } else {
                    longestStreak = max(longestStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            previousDate = date
        }
        
        return max(longestStreak, currentStreak)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdDate
        case completedDates
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        let dateArray = try container.decode([Date].self, forKey: .completedDates)
        completedDates = Set(dateArray)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(Array(completedDates), forKey: .completedDates)
    }
}

struct HabitReminder: Codable, Equatable {
    var time: Date
    var isEnabled: Bool
    var weekdays: Set<Int> // 1 = Sunday, 2 = Monday, etc.
    
    init(time: Date, isEnabled: Bool = true, weekdays: Set<Int> = Set(1...7)) {
        self.time = time
        self.isEnabled = isEnabled
        self.weekdays = weekdays
    }
} 