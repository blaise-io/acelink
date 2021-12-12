import Foundation

// QuickTime and Safari cannot play streams when loaded from a m3u8 file from the local filesystem.
class PlaylistServer: Service {
    private let engine: AceStreamEngine
    private let stream: StreamFile
    override var defaultError: String { "Cannot launch Python server." }

    init(engine: AceStreamEngine, stream: StreamFile) {
        self.engine = engine
        self.stream = stream
        super.init()
    }

    override func run() {
        let cmdInContainer = "echo '\(stream.m3uData)' > acelink.m3u8;" +
            "python -m SimpleHTTPServer \(AppConstants.Docker.proxyPort)"
        _ = Process.runCommand(
            "docker", "exec", "--detach", "--workdir=/acelink", engine.containerID!,
            "sh", "-c", cmdInContainer
        )
    }

    override func check() {
        urlSession.dataTask(with: stream.playlistURL) { _, response, _ in
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    self.callbackInMainThread()
                    return
                }
            }
            self.scheduleCheck()
        }.resume()
    }
}
