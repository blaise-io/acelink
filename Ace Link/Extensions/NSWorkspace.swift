import Cocoa
import Foundation

extension NSWorkspace {
    func getBundle(bundleID: String) -> Bundle? {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
            return Bundle(url: url)
        }
        return nil
    }
}
