import XCTest
@testable import ShopCart

final class URLProtocolStub: URLProtocol {
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = URLProtocolStub.handler else { return }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

final class PromoServiceTests: XCTestCase {

    private func makeService() -> PromoService {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return PromoService(session: URLSession(configuration: configuration))
    }

    private func stub(status: Int, body: String) {
        URLProtocolStub.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: status,
                                           httpVersion: nil, headerFields: nil)!
            return (response, Data(body.utf8))
        }
    }

    func testPercentCodeIsParsed() async throws {
        stub(status: 200, body: #"{"type":"percent","value":10}"#)
        let promo = try await makeService().validate(code: "SAVE10")
        XCTAssertEqual(promo, .percent(Decimal(10) / 100))
    }

    func testNotFoundMapsToUnknownCode() async {
        stub(status: 404, body: "{}")
        do {
            _ = try await makeService().validate(code: "BAD")
            XCTFail("Очікувалась помилка")
        } catch {
            XCTAssertEqual(error as? PromoError, .unknownCode)
        }
    }

    func testServerErrorMapsToNetwork() async {
        stub(status: 500, body: "{}")
        do {
            _ = try await makeService().validate(code: "SAVE10")
            XCTFail("Очікувалась помилка")
        } catch {
            XCTAssertEqual(error as? PromoError, .network)
        }
    }
}
