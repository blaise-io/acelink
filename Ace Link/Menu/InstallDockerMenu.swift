import os
import Cocoa
import Foundation

class InstallDockerMenu {
    let downloadURL = "https://download.docker.com/mac/stable/Docker.dmg"

    let statusItem = NSMenuItem(
        title: "Docker is not installed",
        action: nil,
        keyEquivalent: ""
    )

    let installItem = NSMenuItem(
        title: "Download & install Docker manually…",
        action: #selector(install(_:)),
        keyEquivalent: ""
    )

    let dockerSeparatorItem = NSMenuItem.separator()

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
        menu.addItem(self.statusItem)
        menu.addItem(self.installItem)
        menu.addItem(self.dockerSeparatorItem)
    }

    func updateItems(dependenciesInstalled: Bool) {
        statusItem.isHidden = dependenciesInstalled
        installItem.isHidden = dependenciesInstalled
        dockerSeparatorItem.isHidden = dependenciesInstalled
    }
}
