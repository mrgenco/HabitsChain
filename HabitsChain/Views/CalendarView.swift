import SwiftUI

struct CalendarView: View {
    let habit: Habit
    let onUpdate: (Habit) -> Void
    
    @State private var selectedMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let daysInWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack {
            monthHeader
            Divider()
            daysHeader
            Divider()
            daysGrid
        }
        .padding()
    }
    
    private var monthHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
            }
            
            Spacer()
            
            
            Text(monthYearString(from: selectedMonth))
                .font(.headline)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
            }
        }
    }
    
    private var daysHeader: some View {
        HStack {
            ForEach(daysInWeek, id: \.self) { day in
                Text(day)
                    .frame(maxWidth: .infinity)
                    .font(.caption)
            }
        }
    }
    
    private var daysGrid: some View {
        let days = daysInMonth()
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                if let date = date {
                    DayCell(
                        date: date,
                        isCompleted: isDateCompleted(date),
                        isToday: calendar.isDateInToday(date),
                        action: { toggleCompletion(for: date) }
                    )
                } else {
                    Color.clear
                        .aspectRatio(1, contentMode: .fill)
                }
            }
        }
    }
    
    private func daysInMonth() -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: selectedMonth)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func isDateCompleted(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        return habit.completedDates.contains { existingDate in
            calendar.isDate(existingDate, inSameDayAs: startOfDay)
        }
    }
    
    private func toggleCompletion(for date: Date) {
        var updatedHabit = habit
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        if isDateCompleted(date) {
            let datesToRemove = updatedHabit.completedDates.filter { existingDate in
                calendar.isDate(existingDate, inSameDayAs: startOfDay)
            }
            datesToRemove.forEach { updatedHabit.completedDates.remove($0) }
        } else {
            updatedHabit.completedDates.insert(startOfDay)
        }
        
        onUpdate(updatedHabit)
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
}

struct DayCell: View {
    let date: Date
    let isCompleted: Bool
    let isToday: Bool
    let action: () -> Void
    
    init(date: Date, isCompleted: Bool, isToday: Bool, action: @escaping () -> Void) {
        self.date = date
        self.isCompleted = isCompleted
        self.isToday = isToday
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text("\(Calendar.current.component(.day, from: date))")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fill)
                .background(
                    Circle()
                        .fill(isCompleted ? Color.green : Color.clear)
                        .opacity(isCompleted ? 0.3 : 0)
                )
                .overlay(
                    Circle()
                        .stroke(isToday ? Color.blue : Color.clear, lineWidth: 1)
                )
        }
        .foregroundColor(isCompleted ? .green : .primary)
    }
}

#Preview {
    CalendarView(habit: Habit(name: "Example Habit")) { _ in }
} 
