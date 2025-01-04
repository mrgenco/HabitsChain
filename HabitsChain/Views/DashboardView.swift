import SwiftUI
import Charts

struct DashboardView: View {
    let habits: [Habit]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                overallStatsCard
                completionChart
                habitsList
            }
            .padding()
        }
    }
    
    private var overallStatsCard: some View {
        VStack(spacing: 16) {
            Text("Overall Progress")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 24) {
                StatCard(
                    title: "Active Habits",
                    value: "\(habits.count)",
                    icon: "list.bullet.circle.fill"
                )
                
                StatCard(
                    title: "Total Completions",
                    value: "\(totalCompletions)",
                    icon: "checkmark.circle.fill"
                )
                
                StatCard(
                    title: "Best Streak",
                    value: "\(bestStreak)",
                    icon: "flame.fill"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
    
    private var completionChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Last 7 Days")
                .font(.title2)
                .fontWeight(.bold)
            
            Chart {
                ForEach(last7DaysData, id: \.date) { data in
                    LineMark(
                        x: .value("Date", data.date),
                        y: .value("Completions", data.completions)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    
                    AreaMark(
                        x: .value("Date", data.date),
                        y: .value("Completions", data.completions)
                    )
                    .foregroundStyle(Color.blue.opacity(0.1).gradient)
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date.formatted(.dateTime.weekday(.short)))
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
    
    private var habitsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Habit Streaks")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(habits.sorted { $0.currentStreak > $1.currentStreak }) { habit in
                HStack {
                    VStack(alignment: .leading) {
                        Text(habit.name)
                            .font(.headline)
                        Text("\(habit.currentStreak) day streak")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    CircularProgressView(progress: Double(habit.currentStreak) / Double(max(habit.longestStreak, 1)))
                        .frame(width: 44, height: 44)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
            }
        }
    }
    
    private var totalCompletions: Int {
        habits.reduce(0) { $0 + $1.completedDates.count }
    }
    
    private var bestStreak: Int {
        habits.map { $0.longestStreak }.max() ?? 0
    }
    
    private var last7DaysData: [(date: Date, completions: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<7).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let completions = habits.filter { habit in
                habit.completedDates.contains { calendar.isDate($0, inSameDayAs: date) }
            }.count
            return (date, completions)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: 80)
    }
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
    }
} 