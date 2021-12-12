import Foundation
import os

extension String {
    // Return matches for all regex matches in a string.
    func matches(for regexPattern: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regexPattern)
            let matches = regex.matches(
                in: self,
                range: NSRange(startIndex..., in: self)
            )

            return matches.map { match in
                let rangeBounds = match.range(at: match.numberOfRanges - 1)
                guard let range = Range(rangeBounds, in: self) else {
                    return ""
                }
                return String(self[range])
            }
        } catch {
            os_log("Invalid regex: %s", error.localizedDescription)
            return []
        }
    }

    // Scrub AceStream and Magnet URI hashes.
    func scrubHashes() -> String {
        #if !DEBUG
            if let regex = try? NSRegularExpression(pattern: "[a-fA-F0-9]{16,}") {
                return regex.stringByReplacingMatches(
                    in: self,
                    options: [],
                    range: NSRange(location: 0, length: count),
                    withTemplate: "[HASH SCRUBBED]"
                )
            }
        #endif
        return self
    }
}
