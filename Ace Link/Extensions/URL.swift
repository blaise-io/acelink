import Foundation

extension URL {
    func appendingQuery(_ name: String, _ value: String?) -> URL {
        guard var urlComponents = URLComponents(string: absoluteString) else { return self }
        var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
        let queryItem = URLQueryItem(name: name, value: value)
        queryItems.append(queryItem)
        urlComponents.queryItems = queryItems
        return urlComponents.url!
    }
}
