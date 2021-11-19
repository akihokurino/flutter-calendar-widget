import FirebaseAuth
import FirebaseCore
import SwiftUI
import WidgetKit

@main
struct Widgets: WidgetBundle {
    init() {
        FirebaseApp.configure()
        try? Auth.auth().useUserAccessGroup("\(Env["IOS_TEAM_ID"]!).app.akiho.calendar.keychain")
    }

    var body: some Widget {
        SmallWidget()
        MediumWidget()
        LargeWidget()
    }
}
