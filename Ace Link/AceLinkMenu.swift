import Cocoa

class AceLinkMenu: NSMenu {

    let statusItem = NSMenuItem(
        title: "Ace Link dependencies set up",
        action: #selector(noAction(_:)),
        keyEquivalent: ""
    )

    let dockerStatusItem = NSMenuItem(
        title: "Docker is not installed",
        action: #selector(noAction(_:)),
        keyEquivalent: ""
    )

    let dockerInstallItem = NSMenuItem(
        title: "Download & install Docker manually",
        action: #selector(installDocker(_:)),
        keyEquivalent: ""
    )

    let dockerSeparatorItem = NSMenuItem.separator()

    @objc func installDocker(_ sender: NSMenuItem?) {
        NSWorkspace.shared.open(
            URL(string: "https://download.docker.com/mac/stable/Docker.dmg")!
        )
    }

    let vlcStatusItem = NSMenuItem(
        title: "VLC is not installed",
        action: #selector(noAction(_:)),
        keyEquivalent: ""
    )

    let vlcInstallItem = NSMenuItem(
        title: "Download & install VLC manually",
        action: #selector(installVLC(_:)),
        keyEquivalent: ""
    )

    let vlcSeparatorItem = NSMenuItem.separator()

    @objc func installVLC(_ sender: NSMenuItem?) {
        NSWorkspace.shared.open(
            URL(string: "https://www.videolan.org/vlc/download-macosx.html")!
        )
    }

    let openStreamItem = NSMenuItem(
        title: "",
        action: #selector(AceLinkMenu.openStreamFromClipboard(_:)),
        keyEquivalent: "v"
    )

    @objc func openStreamFromClipboard(_ sender: NSMenuItem?) {
        let appDelegate = getAppDelegate()
        appDelegate.openStream(appDelegate.getClipboardString())
    }

    let quitItem = NSMenuItem(
        title: "Quit Ace Link",
        action: #selector(NSApplication.terminate(_:)),
        keyEquivalent: "q"
    )

    @objc func noAction(_ sender: NSMenuItem?) {}

    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    override init(title: String) {
        super.init(title: title)

        self.autoenablesItems = false

        dockerStatusItem.isEnabled = false
        dockerInstallItem.target = self

        vlcStatusItem.isEnabled = false
        vlcInstallItem.target = self

        openStreamItem.target = self

        self.addItem(dockerStatusItem)
        self.addItem(dockerInstallItem)
        self.addItem(dockerSeparatorItem)

        self.addItem(vlcStatusItem)
        self.addItem(vlcInstallItem)
        self.addItem(vlcSeparatorItem)

        self.addItem(statusItem)
        self.addItem(openStreamItem)
        self.addItem(NSMenuItem.separator())
        self.addItem(quitItem)
    }

    func getAppDelegate() -> AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }

    func isDir(_ dir: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: dir, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    func isinstalled(_ bundleId: String) -> Bool {
        let appUrlUnmanaged = LSCopyApplicationURLsForBundleIdentifier(bundleId as CFString, nil)
        return appUrlUnmanaged?.takeRetainedValue() != nil
    }

    override func update() {
        let isDockerInstalled = isinstalled("com.docker.docker")
        let isVLCInstalled = isinstalled("org.videolan.vlc")
        let isAllInstalled = isDockerInstalled && isVLCInstalled
        let clipboardString = getAppDelegate().getClipboardString()

        openStreamItem.isEnabled = isAllInstalled && clipboardString != ""
        openStreamItem.title = "Open stream from clipboard"

        if isDockerInstalled {
            dockerStatusItem.isHidden = true
            dockerInstallItem.isHidden = true
            dockerSeparatorItem.isHidden = true
        }

        if isVLCInstalled {
            vlcStatusItem.isHidden = true
            vlcInstallItem.isHidden = true
            vlcSeparatorItem.isHidden = true
        }

        statusItem.state = NSControl.StateValue.on
        statusItem.isEnabled = false
        statusItem.isHidden = !isAllInstalled
    }

}
