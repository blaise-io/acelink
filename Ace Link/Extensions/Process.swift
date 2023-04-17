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

    static func runCommand(_ arguments: String...) -> Self {
        let process = Self()

        process.launchPath = "/usr/bin/env"
        process.arguments = arguments
        process.environment = [
            "PATH": ProcessInfo.processInfo.environment["PATH"]! + ":/usr/local/bin:/opt/local/bin",
            "DOCKER_DEFAULT_PLATFORM": "linux/amd64",
        ]

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
