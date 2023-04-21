import Cocoa
import Foundation
import os

extension NSWorkspace {
    func getBundle(bundleID: String) -> Bundle? {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
            return Bundle(url: url)
        }
        os_log("Unable to find app with bundleID %{public}@", bundleID)
        return nil
    }

    func getBinaryPath(bundleID: String) -> String? {
        if let bundle = getBundle(bundleID: bundleID) {
            os_log("Path for bundle %{public}@: %{public}@", bundleID, bundle.bundlePath)
            let bundleURL = URL(fileURLWithPath: bundle.bundlePath)
            return bundleURL.appendingPathComponent("Contents/Resources/bin/docker").path
        }
        return nil
    }
}
