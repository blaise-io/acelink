import os
import Cocoa
import Foundation


class InstallVLCMenu {
    let downloadURL = "https://www.videolan.org/vlc/download-macosx.html"

    let statusItem = NSMenuItem(
        title: "VLC is not installed",
        action: nil,
        keyEquivalent: ""
    )

    let installItem = NSMenuItem(
        title: "Download & install VLC manually…",
        action: #selector(install(_:)),
        keyEquivalent: ""
    )

    let separatorItem = NSMenuItem.separator()

    init() {
        statusItem.isEnabled = false
        installItem.target = self
    }

    @objc func install(_ sender: NSMenuItem?) {
        NSWorkspace.shared.open(
            URL(string: downloadURL)!
        )
    }

    func addItems(_ menu: NSMenu) {
        menu.addItem(statusItem)
        menu.addItem(installItem)
        menu.addItem(separatorItem)
    }

    func updateItems(dependenciesInstalled: Bool) {
        statusItem.isHidden = dependenciesInstalled
        installItem.isHidden = dependenciesInstalled
        separatorItem.isHidden = dependenciesInstalled
    }
}
