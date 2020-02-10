import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private var vlcLaunched = false;
    private enum Constants {
        static let magnetStreamProtocol = "magnet"
        static let magnetStreamUrlBeginning = Constants.magnetStreamProtocol + ":?xt=urn:btih:"
        static let aceStreamProtocol = "acestream"
        static let aceStreamUrlBeginning = Constants.aceStreamProtocol + "://"
        static let vlcBundleId = "org.videolan.vlc"
        static let startDockerExitCodes = [
            100: "Cannot launch Docker",
            101: "Cannot connect to Docker",
            102: "Cannot connect to Acestream server",
            103: "Cannot open stream",
            104: "Cannot launch VLC",
        ]
    }

    enum StreamType {
        case acestream
        case magnet
        case none
    }
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    private func hashFromString(_ string:String) -> String {
        return string.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(
            of: Constants.aceStreamUrlBeginning,
            with: ""
        )
    }

   private func hashFromMagnetString(_ string:String) -> String {
        let magnetHash = string.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(
                of: Constants.magnetStreamUrlBeginning,
                with: ""
            )
        
        let delimiter = "&"
        let token = magnetHash.components(separatedBy: delimiter)
        
        if token.isEmpty {
            return ""
        } else {
            return token[0];
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("Application finished loading")

        // One unnamed argument, must be the stream hash
        if CommandLine.arguments.count % 1 == 1 {
            print("Open stream from arg", CommandLine.arguments.last!)
            openStream(CommandLine.arguments.last!, type: StreamType.acestream)
        }

        if let button = statusItem.button {
            button.image = NSImage(named:"StatusBarIcon")
        }

        statusItem.menu = AceLinkMenu(title: "")

        setupTerminationNotificationHandler()
    }

    func openStream(_ hash: String, type: StreamType) {
        print("Open stream")

        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let startDockerPath = Bundle.main.path(forResource: "StartDocker", ofType: "sh")!
        let process = Process()

        process.environment = ProcessInfo.processInfo.environment
        process.environment!["image"] = "blaiseio/acelink:" + version
        process.environment!["hash"] = hash
        if (type == StreamType.magnet) {
            process.environment!["stream_id_param"] = "infohash"
        } else {
            process.environment!["stream_id_param"] = "id"
        }
        process.launchPath = startDockerPath
        process.launch()
        process.waitUntilExit()
        
        print("StartDocker.sh returned status code: " + String(process.terminationStatus))

        let exitCode = Int(process.terminationStatus)
        let message = Constants.startDockerExitCodes[exitCode]
        
        if exitCode == 0 {
            vlcLaunched = true;
            return
        }

        error("\(message ?? "Unknown error") (code \(exitCode)) ")
    }
    
    func error(_ text: String) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Ace Link error"
        alert.icon = NSImage(named: NSImage.cautionName)
        alert.informativeText = text
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    func stopStream() {
        print("Stop stream")
        let path = Bundle.main.path(forResource: "StopDocker", ofType: "sh")!
        let task = Process.launchedProcess(launchPath: path, arguments: [])
        task.waitUntilExit()
        if task.terminationStatus == 0 {
            vlcLaunched = false;
            print("Stop stream done")
        }
    }
    
    func getClipboardStringLinkType() -> StreamType {
        let clipboardData = NSPasteboard.general.string(forType: NSPasteboard.PasteboardType.string)

        if clipboardData == nil {
            return StreamType.none
        }
        
        if clipboardData?.range(of:Constants.magnetStreamProtocol) != nil {
            return StreamType.magnet
        } else {
            return StreamType.acestream
        }
    }
    
    func getClipboardString() -> String {
        let clipboardData = NSPasteboard.general.string(forType: NSPasteboard.PasteboardType.string)

        if clipboardData == nil {
            return ""
        }
        
        let clipboardString: String
            
        if clipboardData?.range(of:Constants.magnetStreamProtocol) != nil {
            clipboardString = hashFromMagnetString(clipboardData!)
        } else {
            clipboardString = hashFromString(clipboardData!)
        }

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
  
    func setupTerminationNotificationHandler() {
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification,
            object: nil,
            queue: OperationQueue.main,
            using: handleTerminationNotifications
        )
    }

    func handleTerminationNotifications(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
            return
        }
        if app.bundleIdentifier == Constants.vlcBundleId && self.vlcLaunched {
            print("VLC closed by user");
            self.stopStream();
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        stopStream()
    }

    // Mac OS >= 10.13
    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }
        if urlComponents.scheme == Constants.aceStreamProtocol {
            
            if url.absoluteString.range(of:Constants.magnetStreamProtocol) != nil {
                openStream(hashFromMagnetString(url.absoluteString), type: StreamType.magnet)
            } else {
                openStream(hashFromString(url.absoluteString), type: StreamType.acestream)
            }
        }
    }
}
