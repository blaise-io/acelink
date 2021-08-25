// https://stackoverflow.com/a/58186422/451480

import Foundation

extension FileManager {

    enum ContentDate {
        case created, modified, accessed

        var resourceKey: URLResourceKey {
            switch self {
            case .created: return .creationDateKey
            case .modified: return .contentModificationDateKey
            case .accessed: return .contentAccessDateKey
            }
        }
    }

    func contentsOfDirectory(atURL url: URL, sortedBy: ContentDate, ascending: Bool = true, options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]) throws -> [URL]? {

        let key = sortedBy.resourceKey

        let files = try contentsOfDirectory(at: url, includingPropertiesForKeys: [key], options: options)

        return try files.sorted {

            let values1 = try $0.resourceValues(forKeys: [key])
            let values2 = try $1.resourceValues(forKeys: [key])

            if let date1 = values1.allValues.first?.value as? Date, let date2 = values2.allValues.first?.value as? Date {

                return date1.compare(date2) == (ascending ? .orderedAscending : .orderedDescending)
            }
            return true
        }
    }
}
