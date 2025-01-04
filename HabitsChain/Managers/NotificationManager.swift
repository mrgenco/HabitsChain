import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
    
    func scheduleHabitReminder(habit: Habit) {
        guard let reminder = habit.reminder,
              reminder.isEnabled else { return }
        
        // First remove any existing notifications for this habit
        removeHabitReminders(habitId: habit.id)
        
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "Time to work on: \(habit.name)"
        content.sound = .default
        
        // Create notifications for the next 7 days
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminder.time)
        
        for dayOffset in 0...7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) else { continue }
            let weekday = calendar.component(.weekday, from: date)
            
            // Only schedule if the weekday is enabled
            if reminder.weekdays.contains(weekday) {
                var triggerComponents = calendar.dateComponents([.year, .month, .day], from: date)
                triggerComponents.hour = components.hour
                triggerComponents.minute = components.minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "habit-\(habit.id)-\(dayOffset)",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    func removeHabitReminders(habitId: UUID) {
        let identifiers = (0...7).map { "habit-\(habitId)-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
} 