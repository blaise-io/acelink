import Foundation
import os

extension URLSession {
    func jsonDataTask<T>(
        with url: URL,
        decodable: T.Type,
        completionHandler: @escaping (T?) -> Void
    ) -> URLSessionDataTask where T: Decodable {
        os_log("Getting JSON from URL: %{public}@", url.absoluteString.scrubHashes())

        return dataTask(with: url) { data, _, error in
            if let error = error {
                os_log("Cannot retrieve data: %{public}@", error.localizedDescription)
                completionHandler(nil)
                return
            }
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(decodable, from: data)
                    completionHandler(decoded)
                    return
                } catch {
                    os_log("Cannot decode JSON: %{public}@", error.localizedDescription)
                }
            }
            completionHandler(nil)
        }
    }
}
