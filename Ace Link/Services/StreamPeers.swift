import Foundation
import os

private struct GetStatsResponse: Decodable {
    let response: StreamStatsResponse
    let error: String?

    struct StreamStatsResponse: Decodable {
        let downloaded: Int?
        let peers: Int?
    }
}

class StreamPeers: Service {
    let statURL: URL

    override var maxWait: DispatchTimeInterval { DispatchTimeInterval.seconds(30) }
    override var defaultError: String { "Stream does not have peers." }

    init(statURL: URL) {
        os_log("Getting stream stats from %{public}s…", statURL.debugDescription)
        self.statURL = statURL
        super.init()
    }

    override func check() {
        urlSession.jsonDataTask(with: statURL, decodable: GetStatsResponse.self) { result in
            if let response = result?.response {
                os_log(
                    "Stream stats; downloaded: %d, peers: %d.",
                    response.downloaded ?? 0,
                    response.peers ?? 0
                )
                if let peers = response.peers, peers > 0 {
                    self.callbackInMainThread()
                    return
                }
            }
            os_log("Waiting for peers…")
            self.scheduleCheck()
        }.resume()
    }
}
