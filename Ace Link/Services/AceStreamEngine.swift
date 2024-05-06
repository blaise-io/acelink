import Foundation
import os

class AceStreamEngine: Service {
    var accessToken: String?
    var playlist: String?
    var containerID: String?
    let token = UUID().uuidString

    override var defaultError: String { "Cannot run AceStream server." }

    override init() {
        _ = Process.runCommand("docker", "kill", AppConstants.Docker.containerName)
        super.init()
    }

    override func run() {
        let process = Process.runCommand(
            "docker",
            "run",
            "--rm",
            "--detach",
            "--publish=\(AppConstants.Docker.enginePort):\(AppConstants.Docker.enginePort)",
            "--publish=\(AppConstants.Docker.proxyPort):\(AppConstants.Docker.proxyPort)",
            "--name=\(AppConstants.Docker.containerName)",
            AppConstants.Docker.image,
            "--client-console",
            "--access-token=\(token)",
            "--allow-user-config",
            "--bind-all",
            "--live-buffer-time=15",
            "--live-cache-type=memory",
            "-–vod-buffer=15",
            "--vod-cache-type=memory"
        )
        if process.standardOutContents.isEmpty {
            os_log("Cannot get engine ID...")
            callback(nil)
            return
        }
        containerID = process.standardOutContents
    }

    override func check() {
        let serverURL = AppConstants.Docker.baseURL
            .appendingPathComponent("/webui/app/\(token)/server")
        os_log("Check server up at %{public}@ …", serverURL.absoluteString)
        urlSession.dataTask(with: serverURL) { data, _, _ in
            if let data = data, let str = String(data: data, encoding: .utf8) {
                self.accessToken = str.matches(for: "\"access_token\": \"([^\"]{64})\"").first
                self.playlist = str.matches(for: "\"playlist_id\": \"([^\"]{7})\"").first
                if self.containerID != nil, self.accessToken != nil {
                    self.callbackInMainThread()
                    return
                }
            }
            self.scheduleCheck()
        }.resume()
    }
}
