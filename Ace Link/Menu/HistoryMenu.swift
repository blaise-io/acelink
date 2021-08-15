import os
import Cocoa
import Foundation

class HistoryMenu {
    var relStreamsDir: String
    var absStreamsDir: String
    var submenu: NSMenu = NSMenu()
    var parentmenu: NSMenu = NSMenu()
    var parent = NSMenuItem(title: "History", action: nil, keyEquivalent: "")

    init() {
        relStreamsDir = "/Library/Application Support/Ace Link/streams"
        absStreamsDir = (NSHomeDirectory() as NSString).appendingPathComponent(relStreamsDir)
    }

    func getHistory() -> [String] {
        do {
            try FileManager.default.createDirectory(atPath: absStreamsDir, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            os_log("Unable to create directory %{public}@", error.debugDescription)
            return []
        }

        do {
            return try FileManager.default.contentsOfDirectory(atPath: absStreamsDir)
        } catch {
            os_log("%{public}@", error.localizedDescription)
            return []
        }
    }

    func filterCompatibleFiles(files: [String]) -> [String] {
        return files.filter { word in
            return word.hasSuffix(".m3u8")
        }
    }

    @objc func install(_ sender: NSMenuItem?) {
    }

    func addItems(_ menu: NSMenu) {
        menu.addItem(parent)
        menu.setSubmenu(submenu, for: parent)
    }

    func updateItems(dependenciesInstalled: Bool) {
        submenu.removeAllItems()
        self.setSubmenuItems(isEnabled: dependenciesInstalled)
    }

    func setSubmenuItems(isEnabled: Bool) {
        let fileList = filterCompatibleFiles(files: getHistory())

        let item = NSMenuItem(
            title: "Manage history…",
            action: #selector(openInFinder(_:)),
            keyEquivalent: "H"
        )
        item.target = self
        item.isEnabled = isEnabled
        submenu.addItem(item)

        for file in fileList {
            let item = NSMenuItem(
                title: file.replacingOccurrences(of: ".m3u8", with: ""),
                action: #selector(self.openHistoryFile(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = file
            submenu.addItem(item)
        }
    }

    @objc func openInFinder(_ sender: NSMenuItem?) {
        NSWorkspace.shared.openFile(absStreamsDir)
    }

    @objc func openHistoryFile(_ sender: NSMenuItem?) {
        let file = sender!.representedObject as! String
        let fileAsURL = NSURL(fileURLWithPath: absStreamsDir).appendingPathComponent(file)!

        do {
            let fileContents = try String(contentsOf: fileAsURL, encoding: .utf8)
            openAsStream(fileContents: fileContents)
        } catch {
            os_log("Could not open file: %{public}@", fileAsURL.absoluteString)
        }
    }

    func openAsStream(fileContents: String) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        for line in fileContents.components(separatedBy: CharacterSet.newlines) {
            if line.hasPrefix("http://") {
                let items = URLComponents(string: line)?.queryItems
                let acestream = items?.filter({$0.name == "id"}).first
                if acestream?.value != nil {
                    appDelegate.openStream(acestream!.value!, type: AppDelegate.StreamType.acestream)
                } else {
                    let magnet = items?.filter({$0.name == "infohash"}).first
                    if magnet?.value != nil {
                        appDelegate.openStream(magnet!.value!, type: AppDelegate.StreamType.magnet)
                    }
                }
            }
        }
    }
}
