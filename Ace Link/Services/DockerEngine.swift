import Foundation

class DockerEngine: Service {
    override var maxWait: DispatchTimeInterval { DispatchTimeInterval.seconds(180) }
    override var checkEverySeconds: Double { 2.0 }
    override var defaultError: String { "Cannot start Docker engine." }

    override func run() {
        // Default Docker bundle ID
        var dockerBundleID = "com.docker.docker" // Fallback bundle ID for Docker
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", "id of app \"OrbStack\""]

        do {
            // Create a pipe to capture standard output
            let outputPipe = Pipe()
            process.standardOutput = outputPipe

            // Launch the process
            try process.run()
            process.waitUntilExit()

            // Capture the output
            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let trimmedOutput = output.trimmingCharacters(in: .whitespacesAndNewlines)

                // Only update dockerBundleID if the output is not empty
                if !trimmedOutput.isEmpty {
                    dockerBundleID = trimmedOutput
                    print("Updated Docker Bundle ID: \(dockerBundleID)") // Print for debugging
                } else {
                    print("No valid bundle ID found for OrbStack; using default: \(dockerBundleID)")
                }
            } else {
                print("Failed to convert output to string.")
            }
        } catch {
            print("Error running osascript: \(error)")
            return // Early exit if osascript fails
        }

        // Attempt to open the application using the (potentially updated) bundle ID
        let openProcess = Process()
        openProcess.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        openProcess.arguments = ["-b", dockerBundleID, "--hide", "--background"]

        do {
            try openProcess.run()
            print("Opened application with bundle ID: \(dockerBundleID)")
        } catch {
            print("Error opening application: \(error)")
        }
    }

    override func hasRunSuccesfully() -> Bool {
        let process = Process.runCommand("docker", "ps")
        return process.terminationStatus == 0
    }
}
