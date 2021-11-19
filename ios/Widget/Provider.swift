import FirebaseAuth
import FirebaseFirestore
import Intents
import SwiftUI
import WidgetKit

struct Schedule: Identifiable {
    let id: String
    let name: String
}

struct Provider: IntentTimelineProvider {
    typealias Entry = SimpleEntry
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            dayOfWeek: "日曜日",
            year: "2021",
            month: "01",
            day: "01",
            selectedYMD: "2021-01-01",
            focusedYMD: "2021-01-01",
            schedules: [],
            configuration: ConfigurationIntent()
        )
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            dayOfWeek: "日曜日",
            year: "2021",
            month: "01",
            day: "01",
            selectedYMD: "2021-01-01",
            focusedYMD: "2021-01-01",
            schedules: [],
            configuration: configuration
        )
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = String(format: "%02d", calendar.component(.month, from: date))
        let day = String(format: "%02d", calendar.component(.day, from: date))

        let dayOfWeek: String
        switch Calendar.current.dateComponents([.weekday], from: date).weekday {
        case 1:
            dayOfWeek = "日曜日"
        case 2:
            dayOfWeek = "月曜日"
        case 3:
            dayOfWeek = "火曜日"
        case 4:
            dayOfWeek = "水曜日"
        case 5:
            dayOfWeek = "木曜日"
        case 6:
            dayOfWeek = "金曜日"
        case 7:
            dayOfWeek = "土曜日"
        default:
            dayOfWeek = ""
        }

        let userDefaults = UserDefaults(suiteName: "group.app.akiho.calendar")
        let selectedYMD = userDefaults?.string(forKey: "selectedDate") ?? ""
        let focusedYMD = userDefaults?.string(forKey: "focusedDate") ?? ""

        let loginId = Auth.auth().currentUser!.uid
        let db = Firestore.firestore()
        db.collection("schedule/\(loginId)/\(year)-\(month)")
            .whereField("dateYMD", isEqualTo: "\(year)-\(month)-\(day)")
            .order(by: "createdAtTimestamp")
            .getDocuments { collection, err in
                if err != nil {
                    let timeline = Timeline(entries: [SimpleEntry(
                        date: date,
                        dayOfWeek: dayOfWeek,
                        year: "\(year)",
                        month: month,
                        day: day,
                        selectedYMD: selectedYMD,
                        focusedYMD: focusedYMD,
                        schedules: [],
                        configuration: configuration
                    )], policy: .atEnd)
                    completion(timeline)
                    return
                }

                let schedules: [Schedule] = collection!.documents.map {
                    Schedule(id: $0.get("id") as! String, name: $0.get("name") as! String)
                }

                var entries: [SimpleEntry] = []
                // 1時間に1度更新が走るようにする
                for hourOffset in 0 ..< 24 {
                    let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: date)!
                    let entry = SimpleEntry(
                        date: entryDate,
                        dayOfWeek: dayOfWeek,
                        year: "\(year)",
                        month: month,
                        day: day,
                        selectedYMD: selectedYMD,
                        focusedYMD: focusedYMD,
                        schedules: schedules,
                        configuration: configuration
                    )
                    entries.append(entry)
                }
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let dayOfWeek: String
    let year: String
    let month: String
    let day: String
    let selectedYMD: String
    let focusedYMD: String
    let schedules: [Schedule]
    let configuration: ConfigurationIntent
}
