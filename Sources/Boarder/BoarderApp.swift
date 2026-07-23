import AppKit

@main
struct BoarderApp {
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory) // menu-bar-only, no Dock icon, set before run() to avoid a flash
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}
