import os
import Cocoa
import Foundation

class UpdateMenu {
    let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    let aceLinkDownloadLatestUrl = "https://github.com/blaise-io/acelink/releases/latest"
    let aceLinkLatestApiUrl = "https://api.github.com/repos/blaise-io/acelink/releases/latest"

    let updateAvailableSeparatorItem = NSMenuItem.separator()
    let updateAvailableItem = NSMenuItem(
        title: "Update",
        action: #selector(openLastReleasePage(_:)),
        keyEquivalent: ""
    )

    init() {
        updateAvailableSeparatorItem.isHidden = true
        updateAvailableItem.target = self
        updateAvailableItem.isHidden = true

        DispatchQueue.main.async {
            self.checkNewReleaseAvailable()
        }
    }

    @objc func openLastReleasePage(_ sender: NSMenuItem?) {
        NSWorkspace.shared.open(
            URL(string: aceLinkDownloadLatestUrl)!
        )
    }

    func addItems(_ menu: NSMenu) {
        menu.addItem(self.updateAvailableSeparatorItem)
        menu.addItem(self.updateAvailableItem)
    }

    func checkNewReleaseAvailable() {
        let url = URL(string: aceLinkLatestApiUrl)!
        struct Response: Decodable {
            let tag_name: String
        }

        URLSession(configuration: .ephemeral).dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(Response.self, from: data)
                    let remote = result.tag_name
                    os_log("Installed version: %{public}@, latest version available: %{public}@", self.version, remote)

                    if self.version.compare(remote, options: .numeric) == .orderedAscending {
                        os_log("Update is available")
                        self.updateAvailableSeparatorItem.isHidden = false
                        self.updateAvailableItem.isHidden = false
                        self.updateAvailableItem.title = "Update to Ace Link \(remote)"
                    }

                } catch let error {
                    os_log("Could not extract remote version: %{public}@", type: .error, error.localizedDescription)
                }
            }
        }.resume()
    }
}
