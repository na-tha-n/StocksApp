//
//  ViewModel.swift
//  CashAppStocks
//
//  Created by Ngoc Nguyen on 7/11/23.
//

import Foundation
import Combine

enum AsyncStatus {
    case initial, loading, loaded, error, success
}

class ViewModel: ObservableObject {
    @Published var stocks: StockResponse? = nil
    @Published var status: AsyncStatus = .initial

    let service : ServiceProtocol
    var cancellables = Set<AnyCancellable>()
    
    init(service : ServiceProtocol){
        self.service = service
        Task{
            await fetchStocksAsyncAwait()
        }
    }
    
    @MainActor func fetchStocksAsyncAwait(){
        status = .loading
        Task{
            do {
                let fetchedStocks = try await service.getStockAsyncAwait()
                self.stocks = fetchedStocks
                status = .success
            } catch {
                if let apiError = error as? APIError {
                    print(apiError.description)
                } else {
                    print(error.localizedDescription)
                }
                status = .error
            }
//            print(stocks ?? "No stock from View Model")
        }
    }
    
    func fetchStockFuture(){
        status = .loading
        service.getStockFuture()
            .sink { completion in
                switch completion{
                case .finished:
                    break
                case .failure(let err):
                    print(err.localizedDescription)
                    self.status = .error
                }
            } receiveValue: { [weak self] response in
                self?.stocks = response
                self?.status = .success
//                print(response)

            }
            .store(in: &cancellables)

    }
}
