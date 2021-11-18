import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Intents
import SwiftUI
import WidgetKit

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            loginId: "",
            date: Date(),
            dateYMD: "21年1月1日",
            configuration: ConfigurationIntent()
        )
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            loginId: "",
            date: Date(),
            dateYMD: "21年1月1日",
            configuration: configuration
        )
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let loginId = Auth.auth().currentUser!.uid
        let userDefaults = UserDefaults(suiteName: "group.app.akiho.calendar")
        let dateYMD = userDefaults?.string(forKey: "selectedDate") ?? ""

        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(
                loginId: loginId,
                date: entryDate,
                dateYMD: dateYMD,
                configuration: configuration
            )
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let loginId: String
    let date: Date
    let dateYMD: String
    let configuration: ConfigurationIntent
}

struct WidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.dateYMD).font(.body)
        Text(entry.loginId).font(.body)
        Text(entry.date, style: .time)
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
