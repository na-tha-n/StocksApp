//
//  ViewModel.swift
//  CashAppStocks
//
//  Created by Ngoc Nguyen on 7/11/23.
//

import Foundation
import Combine

enum AsyncStatus {
    case initial, loading, error, success
}

class ViewModel: ObservableObject {
    @Published var stocks: StockResponse? = nil
    @Published var status: AsyncStatus = .loading

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
                //Sleep for 10s to see loading progress view
                try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
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
