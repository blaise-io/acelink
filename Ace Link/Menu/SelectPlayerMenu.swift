import Cocoa
import Foundation
import os

class SelectPlayerMenu: PartialMenu {
    private let selectPlayerMenuItem = NSMenuItem(
        title: "Change media player…",
        action: #selector(selectPlayer),
        keyEquivalent: ""
    )

    override public var items: [NSMenuItem] {
        [NSMenuItem.separator(), selectPlayerMenuItem]
    }

    override init() {
        super.init()
        selectPlayerMenuItem.target = self
        if AppConfig.playerBundleIdentifier == nil {
            setDefaultPlayer()
        }
    }

    private func setDefaultPlayer() {
        let playerBundleIdentifiers = [
            "org.videolan.vlc",
            "com.colliderli.iina",
            "io.mpv",
            "com.apple.QuickTimePlayerX",
            "com.apple.Safari"
        ]
        if let player = getFirstInstalledBundle(bundleIdentifiers: playerBundleIdentifiers) {
            setPlayer(bundle: player)
        }
    }

    private func getFirstInstalledBundle(bundleIdentifiers: [String]) -> Bundle? {
        for identifier in bundleIdentifiers {
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: identifier) {
                return Bundle(url: url)
            }
        }
        return nil
    }

    @objc
    func selectPlayer(_: NSMenuItem?) {
        let dialog = NSOpenPanel()

        dialog.message = "Select a media player"
        dialog.allowedFileTypes = ["app"]
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = true
        dialog.directoryURL = URL(string: "file:///Applications")
        dialog.showsHiddenFiles = false
        dialog.treatsFilePackagesAsDirectories = false

        if dialog.runModal() == NSApplication.ModalResponse.OK {
            if let url = dialog.url, let bundle = Bundle(url: url) {
                os_log("Selected app %{public}@", bundle.name)
                setPlayer(bundle: bundle)
            }
        }
    }

    func setPlayer(bundle: Bundle) {
        warnCapabilities(bundle: bundle)
        AppConfig.playerBundleIdentifier = bundle.bundleIdentifier
    }

    private func warnCapabilities(bundle: Bundle) {
        if bundle.supports(fileExtension: "mkv") {
            // Players that support mkv will likely play anything you throw at it.
            // Typically we need h264, ac3, adts and ts support, however streams could use any
            // codec.
            // Browsers are unable to play the adts audio codec, which is relatively popular in
            // streams.
            return
        }

        if bundle.bundleIdentifier == Bundle.main.infoDictionary!["CFBundleIdentifier"] as? String {
            NSAlert.error("This causes the universe to implode.")
            return
        }

        let recommendSentence = "Switch to VLC or IINA if you encounter " +
            "issues playing streams using this app."

        if bundle.isBrowser || bundle.supports(typeConformsTo: "public.movie") {
            NSAlert.warning(
                messageText: "Not all streams supported",
                informativeText: "\(bundle.name) does not support all audio and video encodings. " +
                    recommendSentence
            )
        } else {
            NSAlert.warning(
                messageText: "No player capabilities detected",
                informativeText: "\(bundle.name) will likely not be able to play streams. " +
                    recommendSentence
            )
        }
    }
}
