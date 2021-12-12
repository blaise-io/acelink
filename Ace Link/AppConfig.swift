import Cocoa
import Foundation
import os

public enum AppConfig: String {
    case bundleIdentifier

    static var streamsDir: URL {
        FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        )[0].appendingPathComponent("Ace Link/streams")
    }

    static var playerBundleIdentifier: String? {
        get {
            UserDefaults.standard.string(forKey: bundleIdentifier.rawValue)
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: bundleIdentifier.rawValue)
        }
    }

    static var playerBundle: Bundle? {
        guard let playerBundleIdentifier = playerBundleIdentifier else {
            os_log("No player selected")
            return nil
        }
        guard let bundle = NSWorkspace.shared.getBundle(bundleID: playerBundleIdentifier) else {
            os_log("No such bundle %{public}@", playerBundleIdentifier)
            return nil
        }
        return bundle
    }
}
