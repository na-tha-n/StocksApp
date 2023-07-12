//
//  Service.swift
//  CashAppStocks
//
//  Created by Ngoc Nguyen on 7/11/23.
//

import Foundation

enum APIError: Error{
    case invalidURL
    case invalidResponse
    case decodingError
    case emptyData
    var description: String {
        switch self {
        case .invalidURL:
            return "invalid URL"
        case .invalidResponse:
            return "invalid response"
        case .emptyData:
            return "empty data"
        case .decodingError:
            return "decoding error or malformed data response"
        }
    }
}

protocol ServiceProtocol{
    func getStock() async throws -> StockResponse
}

class Service : ServiceProtocol{
    func getStock() async throws -> StockResponse{
        //Prepare URL
        let endpoint = "https://storage.googleapis.com/cash-homework/cash-stocks-api/portfolio.json"
        //Empty Json response
//        let endpoint = "https://storage.googleapis.com/cash-homework/cash-stocks-api/portfolio_empty.json"
        //Malformed Json response
//        let endpoint = "https://storage.googleapis.com/cash-homework/cash-stocks-api/portfolio_malformed.json"
        guard let url = URL(string: endpoint) else { throw APIError.invalidURL}

        //Make API call
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as?HTTPURLResponse, response.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        //Decode data
        var result: StockResponse?
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase //convert to Camel case from Snake Case
            result = try decoder.decode(StockResponse.self, from: data)
//            print(result)
        } catch {
            throw APIError.decodingError
        }
        
        //Handle empty result case
        if let result = result {
            if result.stocks.isEmpty {
                throw APIError.emptyData
            }
//            print(result)
            return result
        } else {
            throw APIError.decodingError
        }
    }
}
