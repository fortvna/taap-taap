import SwiftUI

@main
struct TaapTaapApp: App {
    var body: some Scene {
        #if os(macOS)
        Window("Taap Taap", id: "main") {
            RootView().frame(minWidth: 540, minHeight: 650)
        }
        .defaultSize(width: 1080, height: 820)
        #else
        WindowGroup {
            RootView()
        }
        #endif
    }
}
