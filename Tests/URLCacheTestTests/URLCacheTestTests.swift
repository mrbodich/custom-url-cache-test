import Foundation
import Testing
@testable import URLCacheTest

@Suite(.serialized)
struct URLCacheTestTests {
    
    
    @Test("Test Cache", arguments: [
        true,
        false
    ])
    func authorTest(useEvictingCache: Bool) async throws {
        let config = URLSessionConfiguration.default
        
        if useEvictingCache {
            config.urlCache = CustomURLCache()
        } else {
            config.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 1024 * 1024 * 100)
        }
        
        let urlSession = URLSession(configuration: config)
        
        /// This endpoint returns `Cache-Control: max-age=3`
        let url = URL(string: "https://run.mocky.io/v3/a604e51e-cb8d-47f9-9f2f-f7a7b9c69c66")!
        
        let (data1, rawResponse1) = try await urlSession.data(for: URLRequest(url: url))
        let response1 = try #require(rawResponse1 as? HTTPURLResponse)
        
        try await Task.sleep(for: .seconds(1))
        
        let (data2, rawResponse2) = try await urlSession.data(for: URLRequest(url: url))
        let response2 = try #require(rawResponse2 as? HTTPURLResponse)
        
        try await Task.sleep(for: .seconds(5))
        
        let (data3, rawResponse3) = try await urlSession.data(for: URLRequest(url: url))
        let response3 = try #require(rawResponse3 as? HTTPURLResponse)
        
        /// Check if second request has the same date
        #expect(response1.date == response2.date)
        #expect(response1.date != response3.date)
        #expect(response1.value(forHTTPHeaderField: "Cache-Control") == "max-age=3")
        
        #expect(200..<300 ~= response1.statusCode)
        #expect(200..<300 ~= response2.statusCode)
        #expect(200..<300 ~= response3.statusCode)
        #expect(data1.count > 0)
        #expect(data2.count > 0)
        #expect(data3.count > 0)
    }
}

extension HTTPURLResponse {
    var date: Date {
        let date = self.allHeaderFields["Date"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd LLL yyyy HH:mm:ss zzz"
        return dateFormatter.date(from: date)!
    }
}
