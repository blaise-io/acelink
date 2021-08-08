import os
import Cocoa

class StatusMenu: NSMenu {
    let updateMenu = UpdateMenu()
    let dockerMenu = InstallDockerMenu()
    let vlcMenu = InstallVLCMenu()
    let openStreamMenu = OpenStreamMenu()
    let historyMenu = HistoryMenu()

    let dependenciesStatusItem = NSMenuItem(
        title: "Dependencies set up",
        action: nil,
        keyEquivalent: ""
    )

    let quitItem = NSMenuItem(
        title: "Quit Ace Link",
        action: #selector(NSApplication.terminate(_:)),
        keyEquivalent: "q"
    )

    let openHelpDialogItem = NSMenuItem(
        title: "Help on opening streams…",
        action: #selector(openHelpDialog(_:)),
        keyEquivalent: ""
    )

    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    override init(title: String) {
        super.init(title: title)
        self.autoenablesItems = false
        openHelpDialogItem.target = self

        dependenciesStatusItem.state = NSControl.StateValue.on
        dependenciesStatusItem.isEnabled = false
        self.addItem(dependenciesStatusItem)

        dockerMenu.addItems(self)
        vlcMenu.addItems(self)
        openStreamMenu.addItems(self)
        historyMenu.addItems(self)
        updateMenu.addItems(self)

        self.addItem(NSMenuItem.separator())
        self.addItem(openHelpDialogItem)
        self.addItem(quitItem)
    }

    @objc func openHelpDialog(_ sender: NSMenuItem?) {
        let alert = NSAlert()
        alert.messageText = "How to open a stream using Ace Link?"
        alert.informativeText = """
        The Open stream option is enabled when Docker and VLC are installed, and a supported format is detected in your clipboard. Supported formats are Acestream hashes, Acestream uris and Magnet uris.

        An Acestream hash is a 40-character code. Example: 049ea83561b6213dee5ae806cfdf52838a4c921e

        An Acestream uri starts with acestream:// followed by the Acestream hash. You can also click and open acestream:// hyperlinks in Ace Link.

        A Magnet uri starts with magnet:?x followed by multiple parameters. Example: magnet:?xt=urn:btih:c12fe1c06bbe254a9dc9f519b335aa7c1367a88a

        Note that opening a stream may take a minute, especially if Docker needs to start first. If playback fails, please try another stream before reporting an issue with Ace Link. Some streams may be offline, peerless or broken otherwise.
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    func isinstalled(_ bundleId: String) -> Bool {
        let appUrlUnmanaged = LSCopyApplicationURLsForBundleIdentifier(bundleId as CFString, nil)
        return appUrlUnmanaged?.takeRetainedValue() != nil
    }

    override func update() {
        let isDockerInstalled = isinstalled("com.docker.docker")
        let isVLCInstalled = isinstalled("org.videolan.vlc")
        let isAllInstalled = isDockerInstalled && isVLCInstalled

        openStreamMenu.updateItems(dependenciesInstalled: isAllInstalled)
        historyMenu.updateItems(dependenciesInstalled: isAllInstalled)
        dockerMenu.updateItems(dependenciesInstalled: isDockerInstalled)
        vlcMenu.updateItems(dependenciesInstalled: isVLCInstalled)

        dependenciesStatusItem.isHidden = !isAllInstalled
    }
}
