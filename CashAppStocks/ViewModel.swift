//
//  ViewModel.swift
//  CashAppStocks
//
//  Created by Ngoc Nguyen on 7/11/23.
//

import Foundation
enum AsyncStatus {
    case initial, loading, loaded, error(APIError), success
}

class ViewModel: ObservableObject {
    @Published var stocks: StockResponse? = nil
    @Published var status: AsyncStatus = .initial

    let service : ServiceProtocol
    
    init(service : ServiceProtocol){
        self.service = service
    }
    
    
    func fetchStocks(){
        Task{
            do {
                let fetchedStocks = try await service.getStock()
                stocks = fetchedStocks
                status = .success
            } catch {
                if let apiError = error as? APIError {
                    print(apiError.description)
                    status = .error(apiError)
                } else {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
