import Cocoa
import Foundation
import os

class InstallDockerMenu: PartialMenu {
    private let downloadURL = URL(string: "https://download.docker.com/mac/stable/Docker.dmg")!

    private let statusItem = NSMenuItem(
        title: "Docker is required to play streams",
        action: nil,
        keyEquivalent: ""
    )

    private let installItem = NSMenuItem(
        title: "Download Docker…",
        action: #selector(install(_:)),
        keyEquivalent: ""
    )

    override public var items: [NSMenuItem] {
        [statusItem, installItem, NSMenuItem.separator()]
    }

    override init() {
        super.init()
        statusItem.isEnabled = false
        installItem.target = self
    }

    override func update(canPlay: Bool) {
        for item in items {
            item.isHidden = canPlay
        }
    }

    @objc
    private func install(_: NSMenuItem?) {
        NSWorkspace.shared.open(downloadURL)
    }
}
