import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private var streaming = false;
    private enum Constants {
        static let aceStreamProtocol = "acestream"
        static let aceStreamUrlBeginning = Constants.aceStreamProtocol + "://"
        static let vlcBundleId = "org.videolan.vlc"
    }

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    private func hashFromString(_ string:String) -> String {
        return string.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(
            of: Constants.aceStreamUrlBeginning,
            with: ""
        )
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("Application finished loading")
        setupVideoPlayerClosedNotification()
        // One unnamed argument, must be the stream hash
        if CommandLine.arguments.count % 1 == 1 {
            print("Open stream from arg", CommandLine.arguments.last!)
            openStream(CommandLine.arguments.last!)
        }

        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarIcon"))
        }

        statusItem.menu = AceLinkMenu(title: "")
    }

    func openStream(_ hash: String) {
        let path = Bundle.main.path(forResource: "StartDocker", ofType: "sh")!
        let task = Process.launchedProcess(launchPath: path, arguments: [hash])
        task.waitUntilExit()
        if task.terminationStatus == 0 {
            print("Done")
        }
        streaming = true;
    }

    func stopStream() {
        let path = Bundle.main.path(forResource: "StopDocker", ofType: "sh")!
        let task = Process.launchedProcess(launchPath: path, arguments: [])
        task.waitUntilExit()
        if task.terminationStatus == 0 {
            print("Done")
        }
        streaming = false;
    }

    func getClipboardString() -> String {
        let clipboardData = NSPasteboard.general.string(forType: NSPasteboard.PasteboardType.string)

        if clipboardData == nil {
            return ""
        }

        let clipboardString: String = hashFromString(clipboardData!)

        // Verify conform SHA1
        let range = NSMakeRange(0, clipboardString.count)
        let regex = try! NSRegularExpression(
            pattern: "^[a-fA-F0-9]{40}$",
            options: NSRegularExpression.Options.caseInsensitive
        )

        if regex.firstMatch(in: clipboardString, options: [], range: range) != nil {
            return clipboardString
        }

        return ""
    }
  
    func setupVideoPlayerClosedNotification() {
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didTerminateApplicationNotification, object: nil, queue: OperationQueue.main) { (notification) in
              guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication , app.bundleIdentifier == Constants.vlcBundleId ,
                self.streaming else {
                return;
              }
              // VLC Closed. stop stream
              print("VLC closed. Stopping stream...");
              self.stopStream();
          }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        stopStream()
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        if urlComponents.scheme == Constants.aceStreamProtocol {
            openStream(hashFromString(url.absoluteString))
        }
    }
}
