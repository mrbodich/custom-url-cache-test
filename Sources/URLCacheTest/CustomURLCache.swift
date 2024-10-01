// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

class CustomURLCache: URLCache, @unchecked Sendable {
    let cachedResponseFileURL = URL(filePath: NSTemporaryDirectory().appending("entry.data"))

    // MARK: Internal storage
    func read() -> CachedURLResponse? {
        guard let data = try? Data(contentsOf: cachedResponseFileURL) else { return nil }
        return try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! CachedURLResponse
    }

    func store(_ cachedResponse: CachedURLResponse) {
        try! (try! NSKeyedArchiver.archivedData(withRootObject: cachedResponse, requiringSecureCoding: false)).write(to: cachedResponseFileURL)
    }

    // MARK: URLCache Overrides
    override func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        let response = read()
        return response
    }
    
    override func cachedResponse(for dataTask: URLSessionDataTask) async -> CachedURLResponse? {
        let response = read()
        return response
    }

    override func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
        store(cachedResponse)
    }
    
    override func storeCachedResponse(_ cachedResponse: CachedURLResponse, for dataTask: URLSessionDataTask) {
        store(cachedResponse)
    }
}
