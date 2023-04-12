import Cocoa
import os

class MainMenu: NSMenu {
    let partialMenus: [PartialMenu] = [
        InstallDockerMenu(),
        OpenStreamMenu(),
        HistoryMenu(),
        UpdateMenu(),
        SelectPlayerMenu()
    ]

    let openHelpDialogItem = NSMenuItem(
        title: "Help on opening streams…",
        action: #selector(openHelpDialog(_:)),
        keyEquivalent: ""
    )

    let quitItem = NSMenuItem(
        title: "Quit Ace Link",
        action: #selector(NSApplication.shared.terminate(_:)),
        keyEquivalent: "q"
    )

    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    override init(title: String) {
        super.init(title: title)

        autoenablesItems = false
        openHelpDialogItem.target = self

        for partialMenu in partialMenus {
            for item in partialMenu.items {
                addItem(item)
            }
        }

        addItem(openHelpDialogItem)
        addItem(quitItem)

        update()
    }

    override func update() {
        let canPlay = Process.runCommand("docker", "--version").terminationStatus == 0
        for menu in partialMenus {
            menu.update(canPlay: canPlay)
        }
    }

    @objc
    func openHelpDialog(_: NSMenuItem?) {
        let alert = NSAlert()
        alert.messageText = "How to open a stream using Ace Link?"
        alert.informativeText = """
        The Open stream option is enabled when a supported format is detected on your clipboard.

        Supported formats:

        • AceStream hash.
        Example: 049ea83561b6213dee5ae806cfdf52838a4c921e

        • AceStream hash including protocol.
        Example: acestream://049ea83561b6213dee5ae806cfdf52838a4c921e

        • Magnet URI starting with magnet:?x followed by parameters.
        Example: magnet:?xt=urn:btih:c12fe1c06bbe254a9dc9f519b335aa7c1367a88a

        You can also open streams by selecting Ace Link when opening acestream:// or magnet: links.
        """
        alert.accessoryView = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 0))
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
