import Foundation

enum PromoError: Error, Equatable {
    case unknownCode
    case network
}

protocol PromoServiceProtocol {
    func validate(code: String) async throws -> PromoCode
}

private struct PromoDTO: Decodable {
    let type: String
    let value: Int
}

struct PromoService: PromoServiceProtocol {
    var session: URLSession = .shared
    var baseURL = URL(string: "https://api.shopcart.example/promo")!

    func validate(code: String) async throws -> PromoCode {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "code", value: code)]

        let (data, response) = try await session.data(from: components.url!)
        guard let http = response as? HTTPURLResponse else { throw PromoError.network }
        guard http.statusCode == 200 else {
            throw http.statusCode == 404 ? PromoError.unknownCode : PromoError.network
        }

        let dto = try JSONDecoder().decode(PromoDTO.self, from: data)
        switch dto.type {
        case "percent": return .percent(Decimal(dto.value) / 100)
        case "free_shipping": return .freeShipping
        default: throw PromoError.unknownCode
        }
    }
}

/// Заглушка для UI-тестів (вмикається аргументом запуску -UITests)
struct StubPromoService: PromoServiceProtocol {
    func validate(code: String) async throws -> PromoCode {
        switch code {
        case "SAVE10": return .percent(Decimal(10) / 100)
        case "FREESHIP": return .freeShipping
        default: throw PromoError.unknownCode
        }
    }
}
