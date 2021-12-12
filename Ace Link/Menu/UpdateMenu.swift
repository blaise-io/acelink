import Cocoa
import Foundation
import os

private struct GetReleasesResponse: Decodable {
    let tagName: String

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
    }
}

class UpdateMenu: PartialMenu {
    private let aceLinkDownloadLatestUrl = "https://github.com/blaise-io/acelink/releases/latest"
    private let aceLinkLatestApiUrl =
        "https://api.github.com/repos/blaise-io/acelink/releases/latest"

    private let updateItem = NSMenuItem(
        title: "Update",
        action: #selector(openLastReleasePage(_:)),
        keyEquivalent: ""
    )

    override public var items: [NSMenuItem] {
        [NSMenuItem.separator(), updateItem]
    }

    override init() {
        super.init()

        for item in items {
            item.isHidden = true
            item.target = self
        }

        DispatchQueue.global().async {
            self.checkNewReleaseAvailable()
        }
    }

    @objc
    func openLastReleasePage(_: NSMenuItem?) {
        NSWorkspace.shared.open(URL(string: aceLinkDownloadLatestUrl)!)
    }

    private func checkNewReleaseAvailable() {
        let url = URL(string: aceLinkLatestApiUrl)!
        let urlSession = URLSession(configuration: .ephemeral)

        urlSession.jsonDataTask(with: url, decodable: GetReleasesResponse.self) { result in
            guard let result = result else {
                os_log("Cannot retrieve installed version.")
                return
            }

            let localVersion = AppConstants.version
            let githubLatestVersion = result.tagName

            os_log(
                "Installed version: %{public}@, latest version available: %{public}@",
                localVersion, githubLatestVersion
            )

            if localVersion.compare(githubLatestVersion, options: .numeric) == .orderedAscending {
                os_log("Update is available")
                for item in self.items {
                    item.isHidden = false
                }
                self.updateItem.title = "Update to Ace Link \(githubLatestVersion)"
            }
        }.resume()
    }
}
