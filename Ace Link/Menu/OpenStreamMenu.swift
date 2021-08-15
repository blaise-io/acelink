import os
import Cocoa
import Foundation

class OpenStreamMenu {

    let openStreamItem = NSMenuItem(
        title: "Open stream from clipboard",
        action: #selector(openStreamFromClipboard(_:)),
        keyEquivalent: "v"
    )

    init() {
        openStreamItem.target = self
    }

    @objc func openStreamFromClipboard(_ sender: NSMenuItem?) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let clipboardString = appDelegate.getClipboardString()
        appDelegate.openStream(clipboardString, type: appDelegate.getClipboardStringLinkType())
    }

    func addItems(_ menu: NSMenu) {
        menu.addItem(openStreamItem)
    }

    func updateItems(dependenciesInstalled: Bool) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let clipboardString = appDelegate.getClipboardString()
        let enabed = dependenciesInstalled && clipboardString != ""
        openStreamItem.isEnabled = enabed
    }
}
