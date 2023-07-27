//
//  Service.swift
//  CashAppStocks
//
//  Created by Ngoc Nguyen on 7/11/23.
//

import Foundation
import Combine
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
    func getStockAsyncAwait() async throws -> StockResponse
    func getStockFuture() -> Future<StockResponse, Error>
    
}

class Service : ServiceProtocol{
    let endpoint = "https://storage.googleapis.com/cash-homework/cash-stocks-api/portfolio.json"
    var cancellables = Set<AnyCancellable>()
    func getStockAsyncAwait() async throws -> StockResponse{
        //Prepare URL
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
        } catch {
            throw APIError.decodingError
        }
        
        //Handle empty result case
        if let result = result {
            if result.stocks.isEmpty {
                throw APIError.emptyData
            }
            return result
        } else {
            throw APIError.decodingError
        }
    }
    
    func getStockFuture() -> Future<StockResponse, Error> {
        return Future{[weak self] promise in
            guard let self = self, let url = URL(string: endpoint)
            else {
                promise(.failure(APIError.invalidURL))
                return
            }
            //change decoding strategy from snake case to camel case
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            URLSession.shared.dataTaskPublisher(for: url)
                .map{$0.data}
                .decode(type: StockResponse.self, decoder: decoder)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion{
                    case .finished:
                        break
                    case .failure(let err):
//                        print("\(err.localizedDescription)")
                        promise(.failure(err))
                    }
                } receiveValue: { response in
//                    print(response)
                    promise(.success(response))
                }
                .store(in: &self.cancellables)
        }
    }
}
