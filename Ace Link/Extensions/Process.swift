import Foundation
import os

// Weak maps to store additional data for the extension.
private let standardOutputMap = NSMapTable<Process, NSString>.weakToStrongObjects()
private let standardErrorMap = NSMapTable<Process, NSString>.weakToStrongObjects()

extension Process {
    var standardOutContents: String {
        get { (standardOutputMap.object(forKey: self) as String?) ?? "" }
        set { standardOutputMap.setObject(NSString(string: newValue), forKey: self) }
    }

    var standardErrorContents: String {
        get { (standardErrorMap.object(forKey: self) as String?) ?? "" }
        set { standardErrorMap.setObject(NSString(string: newValue), forKey: self) }
    }

    var userDockerSocket: String? {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let userSocketPath = home.path + "/.docker/run/docker.sock"
        if FileManager.default.fileExists(atPath: userSocketPath) {
            return userSocketPath
        }
        return nil
    }

    static func runCommand(_ arguments: String...) -> Self {
        let process = Self()

        process.launchPath = "/usr/bin/env"
        process.arguments = arguments
        process.environment = [
            // Modify PATH to include dirs containing local binaries.
            "PATH": ProcessInfo.processInfo.environment["PATH"]! + ":/usr/local/bin:/opt/local/bin",
            // Don't attempt to download/run arm64 packages because they're not supported.
            "DOCKER_DEFAULT_PLATFORM": "linux/amd64",
        ]

        // Docker-for-Mac allows both /Users/<user>/.docker/run/docker.sock (new)
        // and /var/run/docker.sock (legacy but supported).
        if let userDockerSocket = process.userDockerSocket {
            process.environment?["DOCKER_HOST"] = "unix://" + userDockerSocket
        }

        os_log("Running command: %{public}@", arguments.joined(separator: " ").scrubHashes())

        let outputPipe = Pipe(), errorPipe = Pipe()

        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.launch()
        process.waitUntilExit()

        process.standardOutContents = outputPipe.readFile()
        process.standardErrorContents = errorPipe.readFile()

        os_log("StandardOut: %{public}@", process.standardOutContents.scrubHashes())
        os_log("standardError: %{public}@", process.standardErrorContents.scrubHashes())

        return process
    }
}
