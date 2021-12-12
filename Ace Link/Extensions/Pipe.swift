import Foundation

extension Pipe {
    func readFile() -> String {
        let data = fileHandleForReading.readDataToEndOfFile()
        if let string = String(data: data, encoding: .utf8) {
            return string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return ""
    }
}
