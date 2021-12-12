import Foundation
import os

class Service {
    private let started = DispatchTime.now()
    let urlSession = URLSession(configuration: .ephemeral)

    var callback: (AppError?) -> Void = { _ in }
    var error: () -> Void = {}
    var maxWait: DispatchTimeInterval { DispatchTimeInterval.seconds(30) }
    var checkEverySeconds: Double { 0.5 }
    var defaultError: String { "Timed out" }

    func hasRunSuccesfully() -> Bool { false }
    func run() {}

    init() {}

    func task(_ callback: @escaping (AppError?) -> Void) {
        self.callback = callback
        DispatchQueue.global().async {
            if self.hasRunSuccesfully() {
                self.callbackInMainThread()
            } else {
                self.run()
                self.check()
            }
        }
    }

    func scheduleCheck() {
        if DispatchTime.now() >= started + maxWait {
            callbackInMainThread(AppError(defaultError))
        } else {
            DispatchQueue.global().asyncAfter(deadline: .now() + checkEverySeconds) {
                self.check()
            }
        }
    }

    func check() {
        if hasRunSuccesfully() {
            callbackInMainThread()
            return
        }
        scheduleCheck()
    }

    func callbackInMainThread(_ error: AppError? = nil) {
        DispatchQueue.main.async {
            self.callback(error)
        }
    }
}
