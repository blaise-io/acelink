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

    /// Returns the Docker socket path by checking (in order):
    /// 1. Docker context (supports Docker Desktop, OrbStack, Rancher Desktop, Colima, etc.)
    /// 2. User-specific socket (~/.docker/run/docker.sock)
    /// 3. OrbStack socket (~/.orbstack/run/docker.sock)
    /// 4. Colima socket (~/.colima/default/docker.sock)
    /// 5. Legacy system socket (/var/run/docker.sock)
    var dockerSocket: String? {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let fileManager = FileManager.default

        // 1. Try to get socket from docker context (respects user's configured context)
        if let contextSocket = getDockerContextSocket() {
            return contextSocket
        }

        // 2. Fallback to known socket paths
        let knownSockets = [
            home + "/.docker/run/docker.sock",      // Docker Desktop (new)
            home + "/.orbstack/run/docker.sock",    // OrbStack
            home + "/.colima/default/docker.sock",  // Colima
            "/var/run/docker.sock",                 // Legacy/Linux
        ]

        for socketPath in knownSockets {
            if fileManager.fileExists(atPath: socketPath) {
                os_log("Found Docker socket at: %{public}@", socketPath)
                return socketPath
            }
        }

        return nil
    }

    /// Gets the Docker socket from the current docker context using `docker context inspect`
    private func getDockerContextSocket() -> String? {
        let task = Foundation.Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["docker", "context", "inspect", "--format", "{{.Endpoints.docker.Host}}"]
        task.environment = [
            "PATH": ProcessInfo.processInfo.environment["PATH"]! + ":/usr/local/bin:/opt/local/bin:/opt/homebrew/bin",
        ]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = FileHandle.nullDevice

        do {
            try task.run()
            task.waitUntilExit()

            if task.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                   output.hasPrefix("unix://") {
                    let socketPath = String(output.dropFirst(7)) // Remove "unix://"
                    if FileManager.default.fileExists(atPath: socketPath) {
                        os_log("Docker context socket: %{public}@", socketPath)
                        return socketPath
                    }
                }
            }
        } catch {
            os_log("Failed to get docker context: %{public}@", error.localizedDescription)
        }

        return nil
    }

    static func runCommand(_ arguments: String...) -> Self {
        let process = Self()

        process.launchPath = "/usr/bin/env"
        process.arguments = arguments
        process.environment = [
            // Modify PATH to include dirs containing local binaries (including Homebrew on Apple Silicon).
            "PATH": ProcessInfo.processInfo.environment["PATH"]! + ":/usr/local/bin:/opt/local/bin:/opt/homebrew/bin",
            // Don't attempt to download/run arm64 packages because they're not supported.
            "DOCKER_DEFAULT_PLATFORM": "linux/amd64",
        ]

        // Set Docker socket from context or known paths (supports Docker Desktop, OrbStack, Colima, etc.)
        if let dockerSocket = process.dockerSocket {
            process.environment?["DOCKER_HOST"] = "unix://" + dockerSocket
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
