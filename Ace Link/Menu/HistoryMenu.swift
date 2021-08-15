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
        absStreamsDir = (NSHomeDirectory() as NSString).appendingPathComponent(relStreamsDir)  // TODO: make URL
    }

    // TODO: sort by last opened first
    func getHistory() -> [String] {
        do {
            try FileManager.default.createDirectory(atPath: absStreamsDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            os_log("Unable to create directory %{public}@: %{public}@", absStreamsDir, error.localizedDescription)
            return []
        }

        do {
            return try FileManager.default.contentsOfDirectory(atPath: absStreamsDir)
        } catch {
            os_log("Cannot read dir contents %{public}@: %{public}@", absStreamsDir, error.localizedDescription)
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
        guard let fileAsURL = NSURL(fileURLWithPath: absStreamsDir).appendingPathComponent(file) else {
            return
        }

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
                guard let items = URLComponents(string: line)?.queryItems else {
                    return
                }
                let acestream = items.filter({$0.name == "id"}).first?.value
                if acestream != nil {
                    appDelegate.openStream(acestream!, type: AppDelegate.StreamType.acestream)
                    return
                }
                let magnet = items.filter({$0.name == "infohash"}).first?.value
                if magnet != nil {
                    appDelegate.openStream(magnet!, type: AppDelegate.StreamType.magnet)
                    return
                }
            }
        }
    }
}
