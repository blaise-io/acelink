import Cocoa
import Foundation

class LoadingIndicator {
    private var currentFrame = 1
    private var scheduledTimer: Timer?
    public var statusItemButton: NSButton?

    init() {}

    func start() {
        currentFrame = 1
        scheduledTimer = Timer.scheduledTimer(
            timeInterval: 0.15,
            target: self,
            selector: #selector(updateImage(_:)),
            userInfo: nil,
            repeats: true
        )
    }

    func stop() {
        scheduledTimer?.invalidate()
        statusItemButton?.image = NSImage(named: "StatusBarIcon")
    }

    @objc
    func updateImage(_: Timer?) {
        if let image = NSImage(named: "StatusBarIconLoading\(currentFrame)") {
            statusItemButton?.image = image
        }
        if currentFrame.isMultiple(of: 12) {
            currentFrame = 1
        } else {
            currentFrame += 1
        }
    }
}
