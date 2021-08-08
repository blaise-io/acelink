import os
import Cocoa
import Foundation

class HistoryMenu {
    
    init() {
    }
    
    func get_history() -> [String] {
        os_log("%{public}@", NSHomeDirectory())
        
        let relStreamsDir = "/Library/Application Support/Ace Link/streams"
        let absStreamsDir = (NSHomeDirectory() as NSString).appendingPathComponent(relStreamsDir)
        os_log("%{public}@", absStreamsDir)
        
        do {
            try FileManager.default.createDirectory(atPath: absStreamsDir, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            os_log("Unable to create directory %{public}@", error.debugDescription)
            return []
        }
        
        // TODO: Sort by last modified
        // TODO: Translate infohash and id back, or pass query params
        
        do {
            return try FileManager.default.contentsOfDirectory(atPath: absStreamsDir)
        } catch {
            os_log("%{public}@", error.localizedDescription)
            return []
        }
    }
    
    @objc func install(_ sender: NSMenuItem?) {
    }
    
    func addItems(_ menu: NSMenu) {

        let parent = NSMenuItem(title: "History", action: nil, keyEquivalent: "")
        let submenu = NSMenu()
        
        menu.addItem(parent)
        menu.setSubmenu(submenu, for: parent)
        
        let fileList = get_history()

        for file in fileList {
            os_log("%{public}@", file)
            submenu.addItem(NSMenuItem(
                title: file,
                action: nil,
                keyEquivalent: ""
            ))
        }
    }
    
    func updateItems(dependenciesInstalled: Bool) {
    }
}
