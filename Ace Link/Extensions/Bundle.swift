import Foundation

// App bundles typically use
// CFBundleTypeExtensions (document type name), or
// CFBundleDocumentTypes (file extensions without the period)
extension Bundle {
    var bundleDocumentTypes: [[String: Any]] {
        if let types = infoDictionary?["CFBundleDocumentTypes"] as? [[String: Any]] {
            return types
        }
        return []
    }

    func supports(fileExtension: String) -> Bool {
        for documentType in bundleDocumentTypes {
            if let bundleTypeExtensions = documentType["CFBundleTypeExtensions"] as? [String] {
                for bundleTypeExtension in bundleTypeExtensions {
                    if bundleTypeExtension.caseInsensitiveCompare(fileExtension) == .orderedSame {
                        return true
                    }
                }
            }
        }
        return false
    }

    func supports(typeConformsTo: String) -> Bool {
        for documentType in bundleDocumentTypes {
            if let itemContentTypes = documentType["LSItemContentTypes"] as? [String] {
                for itemTypeConformsTo in itemContentTypes {
                    if itemTypeConformsTo.caseInsensitiveCompare(typeConformsTo) == .orderedSame {
                        return true
                    }
                }
            }
        }
        return false
    }

    func supports(documentType: String, role: String) -> Bool {
        for bundleDocumentType in bundleDocumentTypes {
            if let bundleTypeRole = bundleDocumentType["CFBundleTypeRole"] as? String,
               let bundleTypeName = bundleDocumentType["CFBundleTypeName"] as? String {
                if bundleTypeRole == role,
                   bundleTypeName.caseInsensitiveCompare(documentType) == .orderedSame {
                    return true
                }
            }
        }
        return false
    }

    var name: String {
        if let bundleName = infoDictionary?["CFBundleName"] as? String {
            return bundleName
        }
        if let appFile = bundleURL.pathComponents.last {
            return appFile.replacingOccurrences(of: ".app", with: "")
        }
        return "Unknown"
    }

    var isBrowser: Bool {
        supports(documentType: "HTML Document", role: "Viewer")
    }
}
