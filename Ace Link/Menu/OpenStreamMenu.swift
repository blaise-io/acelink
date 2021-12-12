import Cocoa
import Foundation
import os

class OpenStreamMenu: PartialMenu {
    private let openStreamItem = NSMenuItem(
        title: "Open stream from clipboard",
        action: #selector(openStreamFromClipboard(_:)),
        keyEquivalent: "v"
    )

    override var items: [NSMenuItem] {
        [openStreamItem]
    }

    override init() {
        super.init()
        openStreamItem.target = self
    }

    private var streamFromClipboard: StreamFile? {
        let clipboard = NSPasteboard.general.string(forType: NSPasteboard.PasteboardType.string)
        if let clipboard = clipboard {
            return ExtractStream.from(unverifiedData: clipboard)
        }
        return nil
    }

    @objc
    private func openStreamFromClipboard(_: NSMenuItem?) {
        if let stream = streamFromClipboard {
            appDelegate.openStream(stream)
        }
    }

    override func update(canPlay: Bool) {
        openStreamItem.isEnabled = canPlay && streamFromClipboard != nil
        if let playerBundle = AppConfig.playerBundle {
            openStreamItem.image = NSWorkspace.shared.icon(forFile: playerBundle.bundleURL.path)
            openStreamItem.image?.size = NSSize(width: 24.0, height: 24.0)
        }
    }
}
