import os
import Cocoa
import Foundation

class HistoryMenu {
    var historyAbsoluteDir: String
    var historySubmenu: NSMenu = NSMenu()
    var historyMenuItem = NSMenuItem(title: "History", action: nil, keyEquivalent: "")

    init() {
        let historyRelativeDir = "/Library/Application Support/Ace Link/streams"
        historyAbsoluteDir = (NSHomeDirectory() as NSString).appendingPathComponent(historyRelativeDir)
    }

    func getHistory() -> [URL] {
        do {
            try FileManager.default.createDirectory(atPath: historyAbsoluteDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            os_log("Unable to create directory %{public}@: %{public}@", historyAbsoluteDir, error.localizedDescription)
            return []
        }
        do {
            return try FileManager().contentsOfDirectory(atURL: URL(fileURLWithPath: historyAbsoluteDir), sortedBy: .accessed, ascending: false)!
        } catch {
            os_log("Unable to read directory %{public}@: %{public}@", historyAbsoluteDir, error.localizedDescription)
            return []
        }
    }

    func filterCompatibleFiles(files: [URL]) -> [URL] {
        return files.filter { file in
            return file.pathExtension == "m3u8"
        }
    }

    @objc func install(_ sender: NSMenuItem?) {
    }

    func addItems(_ menu: NSMenu) {
        menu.addItem(historyMenuItem)
        menu.setSubmenu(historySubmenu, for: historyMenuItem)
    }

    func updateItems(dependenciesInstalled: Bool) {
        historySubmenu.removeAllItems()
        self.setSubmenuItems(isEnabled: dependenciesInstalled)
    }

    func setSubmenuItems(isEnabled: Bool) {
        let files = filterCompatibleFiles(files: getHistory())
        historyMenuItem.isEnabled = !files.isEmpty

        if !files.isEmpty {
            let item = NSMenuItem(
                title: "Manage history…",
                action: #selector(openInFinder(_:)),
                keyEquivalent: "H"
            )
            item.target = self
            item.isEnabled = isEnabled
            historySubmenu.addItem(item)
        }

        for file in files {
            let item = NSMenuItem(
                title: file.deletingPathExtension().lastPathComponent,
                action: #selector(self.openHistoryFile(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = file
            historySubmenu.addItem(item)
        }
    }

    @objc func openInFinder(_ sender: NSMenuItem?) {
        NSWorkspace.shared.openFile(historyAbsoluteDir)
    }

    @objc func openHistoryFile(_ sender: NSMenuItem?) {
        let file = sender!.representedObject as! URL
        do {
            let fileContents = try String(contentsOf: file, encoding: .utf8)
            openAsStream(fileContents: fileContents)
        } catch {
            os_log("Could not open file: %{public}@", file.absoluteString)
        }
    }

    func openAsStream(fileContents: String) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        for line in fileContents.components(separatedBy: CharacterSet.newlines) {
            if line.hasPrefix("http://") {
                guard let items = URLComponents(string: line)?.queryItems else {
                    return
                }
                let id = items.filter({$0.name == "id"}).first?.value
                if id != nil {
                    appDelegate.openStream(id!, type: AppDelegate.StreamType.acestream)
                    return
                }
                let infohash = items.filter({$0.name == "infohash"}).first?.value
                if infohash != nil {
                    appDelegate.openStream(infohash!, type: AppDelegate.StreamType.magnet)
                    return
                }
            }
        }
    }
}
