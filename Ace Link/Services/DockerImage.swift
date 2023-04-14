import Foundation

class DockerImage: Service {
    override var maxWait: DispatchTimeInterval { DispatchTimeInterval.seconds(1200) }
    override var checkEverySeconds: Double { 2.0 }
    override var defaultError: String { "Cannot pull \(AppConstants.Docker.image)." }

    override func run() {
        _ = Process.runCommand("docker", "pull", "--platform=linux/amd64", AppConstants.Docker.image)
    }

    override func hasRunSuccesfully() -> Bool {
        let process = Process.runCommand(
            "docker", "image", "inspect", "-f", "OK", AppConstants.Docker.image
        )
        return process.terminationStatus == 0
    }
}
