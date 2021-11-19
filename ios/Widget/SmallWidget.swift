import Intents
import SwiftUI
import WidgetKit

struct SmallEntryView: View {
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

struct SmallEntryView_Previews: PreviewProvider {
    static var previews: some View {
        SmallEntryView(entry:
            SimpleEntry(
                date: Date(),
                dayOfWeek: "日曜日",
                day: "01",
                selectedYMD: "2021-01-01",
                schedules: [
                    Schedule(id: "1", name: "スケジュールA"),
                    Schedule(id: "1", name: "スケジュールB"),
                ],
                configuration: ConfigurationIntent()
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct SmallWidget: Widget {
    let kind: String = "SmallWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SmallEntryView(entry: entry)
        }
        .configurationDisplayName("small")
        .description("widget for calendar schedules")
        .supportedFamilies([.systemSmall])
    }
}
