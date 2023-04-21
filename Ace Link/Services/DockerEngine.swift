import Foundation

class DockerEngine: Service {
    override var maxWait: DispatchTimeInterval { DispatchTimeInterval.seconds(180) }
    override var checkEverySeconds: Double { 2.0 }
    override var defaultError: String { "Cannot start Docker engine." }

    override func run() {
        _ = Process.runCommand("open", "-b", AppConstants.Docker.bundleID, "--hide", "--background")
    }

    override func hasRunSuccesfully() -> Bool {
        let process = Process.runCommand(Process.docker!, "ps")
        return process.terminationStatus == 0
    }
}