import Cocoa
import Foundation
import os

enum ExtractStream {
    static func from(applicationURL: URL) -> StreamFile? {
        os_log("applicationURL: %{public}s", applicationURL.debugDescription)
        if let components = URLComponents(url: applicationURL, resolvingAgainstBaseURL: true) {
            for scheme in AppConstants.Scheme.allCases where scheme.rawValue == components.scheme {
                return from(unverifiedData: applicationURL.absoluteString)
            }
        }
        return nil
    }

    static func from(unverifiedData: String) -> StreamFile? {
        let hash: String
        let type: AppConstants.StreamType

        if unverifiedData.range(of: AppConstants.Scheme.magnet.rawValue) != nil {
            hash = getMagnetHash(unverifiedData)
            type = AppConstants.StreamType.magnet
        } else {
            hash = getAceStreamHash(unverifiedData)
            type = AppConstants.StreamType.acestream
        }
        if !hash.isEmpty {
            guard hash.matches(for: "^[a-fA-F0-9]{40}$").count == 1 else {
                return nil
            }
        }
        return StreamFile(hash: hash, type: type)
    }

    static func from(historyURL: URL) -> StreamFile? {
        guard let items = URLComponents(url: historyURL, resolvingAgainstBaseURL: false)?
            .queryItems else {
            return nil
        }
        let idParams = items.filter { $0.name == "id" }
        if let hash = idParams.first?.value {
            return StreamFile(hash: hash, type: AppConstants.StreamType.acestream)
        }
        let infohashParams = items.filter { $0.name == "infohash" }
        if let infohash = infohashParams.first?.value {
            return StreamFile(hash: infohash, type: AppConstants.StreamType.magnet)
        }
        return nil
    }

    private static func getAceStreamHash(_ string: String) -> String {
        string.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(
            of: AppConstants.Scheme.acestream.rawValue + "://",
            with: ""
        )
    }

    private static func getMagnetHash(_ string: String) -> String {
        let magnetHash = string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(
                of: AppConstants.Scheme.magnet.rawValue + ":?xt=urn:btih:",
                with: ""
            )
        if let hash = magnetHash.components(separatedBy: "&").first {
            return hash
        }
        return "" // Start AceStream engine only
    }
}
