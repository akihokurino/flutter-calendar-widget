import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Intents
import SwiftUI
import WidgetKit

struct Schedule: Identifiable {
    let id: String
    let name: String
}

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            dayOfWeek: "日曜日",
            day: "01",
            schedules: [],
            configuration: ConfigurationIntent()
        )
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            dayOfWeek: "日曜日",
            day: "01",
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
        let dateYMD = userDefaults?.string(forKey: "selectedDate") ?? ""
        print("保存した日付 \(dateYMD)")

        let loginId = Auth.auth().currentUser!.uid
        let db = Firestore.firestore()
        db.collection("schedule/\(loginId)/\(year)-\(month)")
            .whereField("dateYMD", isEqualTo: "\(year)-\(month)-\(day)")
            .order(by: "createdAtTimestamp")
            .getDocuments { collection, err in
                if err != nil {
                    let timeline = Timeline(entries: [SimpleEntry(
                        date: date,
                        dayOfWeek: "",
                        day: "",
                        schedules: [],
                        configuration: configuration
                    )], policy: .atEnd)
                    completion(timeline)
                    return
                }

                let schedules: [Schedule] = collection!.documents.map {
                    Schedule(id: $0.get("id") as! String, name: $0.get("name") as! String)
                }

                let timeline = Timeline(entries: [SimpleEntry(
                    date: date,
                    dayOfWeek: dayOfWeek,
                    day: day,
                    schedules: schedules,
                    configuration: configuration
                )], policy: .atEnd)
                completion(timeline)
            }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let dayOfWeek: String
    let day: String
    let schedules: [Schedule]
    let configuration: ConfigurationIntent
}

struct WidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.dayOfWeek).font(.system(size: 12))
                .foregroundColor(Color.white.opacity(0.8))
            Spacer().frame(height: 5)
            Text(entry.day).font(.system(size: 20)).fontWeight(.bold)
                .foregroundColor(Color.white)
            Spacer()
            if entry.schedules.count > 0 {
                Text(entry.schedules[0].name)
                    .lineLimit(1)
                    .font(.system(size: 14))
                    .padding(.horizontal, 5)
                    .frame(height: 35)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(8)
            }
            if entry.schedules.count > 1 {
                Text(entry.schedules[1].name)
                    .lineLimit(1)
                    .font(.system(size: 14))
                    .padding(.horizontal, 5)
                    .frame(height: 35)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(8)
            }
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .padding(10)
        .background(Color(red: 41.0 / 255.0, green: 42.0 / 255.0, blue: 47.0 / 255.0, opacity: 1.0))
    }
}

struct WidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetEntryView(entry:
            SimpleEntry(
                date: Date(),
                dayOfWeek: "日曜日",
                day: "01",
                schedules: [
                    Schedule(id: "1", name: "スケジュールA"),
                    Schedule(id: "1", name: "スケジュールB"),
                ],
                configuration: ConfigurationIntent()
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

@main
struct HomeWidget: Widget {
    let kind: String = "HomeWidget"

    init() {
        FirebaseApp.configure()
        try? Auth.auth().useUserAccessGroup("\(Env().teamId).app.akiho.calendar.keychain")
    }

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
