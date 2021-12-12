import Cocoa

extension NSAlert {
    static func error(_ error: String) {
        showAlert(messageText: "Ace Link error", informativeText: error)
    }

    static func warning(messageText: String, informativeText: String) {
        showAlert(messageText: messageText, informativeText: informativeText)
    }

    private static func showAlert(messageText: String, informativeText: String) {
        let alert = Self()
        alert.alertStyle = .warning
        alert.messageText = messageText
        alert.icon = NSImage(named: NSImage.cautionName)
        alert.informativeText = informativeText
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
