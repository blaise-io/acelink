import Cocoa
import Foundation
import os

class HistoryMenu: PartialMenu {
    private var menuItem = NSMenuItem(title: "History", action: nil, keyEquivalent: "")

    override public var items: [NSMenuItem] {
        [NSMenuItem.separator(), menuItem]
    }

    override init() {
        super.init()
    }

    override func update(canPlay: Bool) {
        setSubmenuItems(canPlay: canPlay)
    }

    private func getHistory() -> [URL] {
        do {
            try FileManager.default.createDirectory(
                atPath: AppConfig.streamsDir.path,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            os_log(
                "Unable to create directory %{public}@: %{public}@",
                AppConfig.streamsDir.path,
                error.localizedDescription
            )
            return []
        }
        do {
            return try FileManager.default.contentsOfDirectory(
                atURL: AppConfig.streamsDir,
                sortedBy: .modified,
                ascending: false
            )
        } catch {
            os_log(
                "Unable to read streams directory %{public}@: %{public}@",
                AppConfig.streamsDir.path,
                error.localizedDescription
            )
            return []
        }
    }

    private func setSubmenuItems(canPlay: Bool) {
        let files = getHistory().filter { file in
            file.pathExtension == "m3u8"
        }

        let menu = NSMenu()
        menuItem.submenu = menu
        menuItem.isEnabled = !files.isEmpty

        if !files.isEmpty {
            let item = NSMenuItem(
                title: "Manage history…",
                action: #selector(openInFinder(_:)),
                keyEquivalent: "H"
            )
            item.target = self
            item.isEnabled = canPlay
            menu.addItem(item)
        }

        for file in files {
            let item = NSMenuItem(
                title: file.deletingPathExtension().lastPathComponent,
                action: #selector(openHistoryFile(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = file
            menu.addItem(item)
        }
    }

    @objc
    private func openInFinder(_: NSMenuItem?) {
        NSWorkspace.shared.openFile(AppConfig.streamsDir.path)
    }

    @objc
    private func openHistoryFile(_ sender: NSMenuItem?) {
        guard let file = sender!.representedObject as? URL else {
            return
        }
        do {
            let fileContents = try String(contentsOf: file, encoding: .utf8)
            openAsStream(fileContents: fileContents)
        } catch {
            os_log("Could not open file: %{public}@", file.absoluteString)
        }
    }

    private func openAsStream(fileContents: String) {
        let playlistLines = fileContents.components(separatedBy: CharacterSet.newlines)
        for line in playlistLines where line.hasPrefix("http://") {
            if let historyURL = URL(string: line) {
                if let file = ExtractStream.from(historyURL: historyURL) {
                    appDelegate.openStream(file)
                }
            }
        }
    }
}
