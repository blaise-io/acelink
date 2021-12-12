import Foundation

public enum AppConstants {
    static var version: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "0.0.0"
    }

    enum Scheme: String, CaseIterable {
        case magnet
        case acestream
    }

    enum StreamType {
        case acestream
        case magnet
        case none
    }

    enum Docker {
        static let baseURL = URL(string: "http://127.0.0.1:\(enginePort)")!
        static let bundleID = "com.docker.docker"
        static let containerName = "acelink--ace-stream-server"
        static let enginePort = 6878
        static let image = "blaiseio/acelink:\(AppConstants.version)"
        static let proxyPort = 6888
    }
}
