import Cocoa
import os

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var loading = LoadingIndicator()
    private var launchedBundle: Bundle?
    private var engine: AceStreamEngine?

    func applicationDidFinishLaunching(_: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.menu = MainMenu(title: "Ace Link")

        if let statusItemButton = statusItem?.button {
            loading.statusItemButton = statusItemButton
            statusItemButton.image = NSImage(named: "StatusBarIcon")
            statusItemButton.imageScaling = .scaleProportionallyDown
        }

        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification,
            object: nil,
            queue: OperationQueue.main,
            using: detectLaunchedBundleTerminated
        )
    }

    func application(_: NSApplication, open urls: [URL]) {
		if Process.runCommand("docker", "--version").terminationStatus != 0 {
			return
		}
        if let url = urls.first, let stream = ExtractStream.from(applicationURL: url) {
            openStream(stream)
        } else {
            NSAlert.error("Unrecognized stream format.")
        }
    }

    func applicationWillTerminate(_: Notification) {
        stopAceStreamServer()
        terminateLaunchedBundle()
    }

    func openStream(_ stream: StreamFile) {
        terminateLaunchedBundle()
        os_log("Open stream: %{public}s=%s", stream.param, stream.hash)

        startAceStreamEngine {
            os_log("Ace Stream engine ready.")
            let engine = self.engine!

            if stream.hash.isEmpty {
                // Just prepare the server, some websites launch acestream:// without args,
                // task communicate directly with the server.
                os_log("No stream hash, leaving the engine running…")
                self.loading.stop()
                return
            }

            self.prepareStream(engine: engine, stream: stream) { stream in
                self.launchStreamInEngine(engine: engine, stream: stream) { bundle, url in
                    os_log(
                        "Launching %{public}@ with URL %s…",
                        bundle.debugDescription,
                        url.debugDescription
                    )

                    NSWorkspace.shared.open(
                        [url], withAppBundleIdentifier: bundle.bundleIdentifier,
                        options: [],
                        additionalEventParamDescriptor: nil,
                        launchIdentifiers: nil
                    )

                    self.launchedBundle = bundle
                    self.loading.stop()
                }
            }
        }
    }

    func prepareStream(
        engine: AceStreamEngine,
        stream: StreamFile,
        callback: @escaping (StreamFile) -> Void
    ) {
        os_log("Preparing stream…")

        let aceStreamPlaylist = AceStreamPlaylist(aceStreamEngine: engine, stream: stream)
        aceStreamPlaylist.task { error in
            if let message = error?.errorDescription {
                self.loading.stop()
                NSAlert.error(message)
                return
            }

            os_log("Waiting for peers…")
            stream.waitForPeers { result in
                if let message = result?.errorDescription {
                    self.loading.stop()
                    NSAlert.error(message)
                    return
                }

                var stream = stream
                stream.title = "\(aceStreamPlaylist.title!) [\(stream.hash.prefix(7))]"
                stream.addToHistory()

                callback(stream)
            }
        }
    }

    func launchStreamInEngine(
        engine: AceStreamEngine,
        stream: StreamFile,
        callback: @escaping (Bundle, URL) -> Void
    ) {
        os_log("Starting server for opening acelink.m3u8 over http…")

        guard let bundle = AppConfig.playerBundle else {
            NSAlert.error("Cannot get player")
            return
        }

        if bundle.isBrowser {
            callback(bundle, stream.getURLForBundleType(bundle))
            return
        }

        PlaylistServer(engine: engine, stream: stream).task { error in
            if let message = error?.errorDescription {
                self.loading.stop()
                NSAlert.error(message)
                return
            }

            callback(bundle, stream.getURLForBundleType(bundle))
        }
    }

    func startAceStreamEngine(_ callback: @escaping () -> Void) {
        loading.start()

        os_log("Starting Docker…")
        DockerEngine().task { error in
            if let message = error?.errorDescription {
                self.loading.stop()
                NSAlert.error(message)
                return
            }

            os_log("Pulling Docker image…")
            DockerImage().task { error in
                if let message = error?.errorDescription {
                    self.loading.stop()
                    NSAlert.error(message)
                    return
                }

                os_log("Starting AceStream server…")
                let launchedContainer = AceStreamEngine()
                launchedContainer.task { error in
                    if let message = error?.errorDescription {
                        self.loading.stop()
                        NSAlert.error(message)
                        return
                    }

                    self.engine = launchedContainer
                    callback()
                }
            }
        }
    }

    func detectLaunchedBundleTerminated(_ notification: Notification) {
        guard let launchedBundle = launchedBundle else {
            return
        }

        if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey],
           let terminatedBundleIdentifier = (app as? NSRunningApplication)?.bundleIdentifier,
           terminatedBundleIdentifier == launchedBundle.bundleIdentifier {
            os_log("Bundle %{public}@ terminated by user.", terminatedBundleIdentifier)
            stopAceStreamServer()
        }
    }

    func terminateLaunchedBundle() {
        guard let launchedBundle = launchedBundle else {
            return
        }
        if launchedBundle.isBrowser {
            os_log("Launched bundle is browser which may have other tabs open, not terminating.")
            self.launchedBundle = nil
            return
        }

        for runningApplication in NSWorkspace.shared.runningApplications
            where runningApplication.bundleIdentifier == launchedBundle.bundleIdentifier {
            os_log("Terminate launched bundle: %{public}@", launchedBundle)
            runningApplication.terminate()
            self.launchedBundle = nil
        }
    }

    func stopAceStreamServer() {
        os_log("Stopping AceStream server…")
        _ = Process.runCommand("docker", "kill", AppConstants.Docker.containerName)
    }
}
