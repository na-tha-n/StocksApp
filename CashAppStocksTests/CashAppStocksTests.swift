//
//  CashAppStocksTests.swift
//  CashAppStocksTests
//
//  Created by Ngoc Nguyen on 7/11/23.
//

import XCTest
@testable import CashAppStocks
import Combine

enum FileName: String {
    case getStocksFailureEmpty
    case getStocksFailureMalformed
    case getStocksSuccess
}
final class CashAppStocksTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGetStocksAsyncAwaitSuccess() async throws{
        // Expectation: The sectionPosts should be populated correctly
        // Set up any necessary mock objects or data
        let exp = XCTestExpectation(description: "fetch successfully")
        let viewModel = ViewModel(service: MockService(fileName: .getStocksSuccess))
        
        // Call the function being tested
        await viewModel.fetchStocksAsyncAwait()
        viewModel.$stocks
            .dropFirst()
            .sink { stockResponse in
                //                print(stockResponse ?? "no stock from test")
                XCTAssertFalse(stockResponse?.stocks.isEmpty ?? true, "Stocks array should not be empty")
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [exp], timeout: 5.0)
    }
    
    func testGetStocksAsyncAwaitFail() async throws{
        // Expectation: The sectionPosts should be populated correctly
        // Set up any necessary mock objects or data
        let exp = XCTestExpectation(description: "fetch fail")
        let viewModel = ViewModel(service: MockService(fileName: .getStocksFailureEmpty))
        
        // Call the function being tested
        await viewModel.fetchStocksAsyncAwait()
        viewModel.$stocks
            .dropFirst()
            .sink { stockResponse in
                print(stockResponse ?? "no stock from test")
                XCTAssertTrue(stockResponse?.stocks.isEmpty ?? false, "Stocks array should be empty")
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [exp], timeout: 5.0)
    }
    
    func testGetStocksFutureSuccess(){
        // Expectation: The sectionPosts should be populated correctly
        // Set up any necessary mock objects or data
        let exp = XCTestExpectation(description: "fetch successfully")
        let viewModel = ViewModel(service: MockService(fileName: .getStocksSuccess))
        
        // Call the function being tested
        viewModel.fetchStockFuture()
        
        viewModel.$stocks
            .sink { stockResponse in
                XCTAssertTrue(stockResponse?.stocks.first?.name.contains("500") ?? false, "Fail the test")
                exp.fulfill()
            }
            .store(in: &cancellables)
        wait(for: [exp], timeout: 5.0)
        
    }
    
    func testGetStocksFutureFail(){
        // Expectation: The sectionPosts should be populated correctly
        // Set up any necessary mock objects or data
        let exp = XCTestExpectation(description: "fetch fail")
        let viewModel = ViewModel(service: MockService(fileName: .getStocksFailureEmpty))
        
        // Call the function being tested
        viewModel.fetchStockFuture()
        
        viewModel.$stocks
            .sink { stockResponse in
                XCTAssertTrue(stockResponse?.stocks.isEmpty ?? false, "Fail the test")
                exp.fulfill()
            }
            .store(in: &cancellables)
        wait(for: [exp], timeout: 5.0)
        
    }
}

class MockService : ServiceProtocol{
    let fileName: FileName
    
    init(fileName: FileName) {
        self.fileName = fileName
    }
    
    private func loadMockData(_ file: String) -> URL? {
            return Bundle(for: type(of: self)).url(forResource: file, withExtension: "json")
        }
        
    func getStockAsyncAwait() async throws -> StockResponse {
        guard let url = self.loadMockData(fileName.rawValue) else { throw APIError.invalidURL }
        
        let data = try! Data(contentsOf: url)

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let stockResponse = try decoder.decode(StockResponse.self, from: data)
//            print(stockResponse)
            return stockResponse
        } catch {
            throw APIError.decodingError
        }
    }
    
    func getStockFuture() -> Future<StockResponse, Error>{
        return Future{[weak self] promise in
            guard let self = self, let url = Bundle(for: type(of: self)).url(forResource: fileName.rawValue, withExtension: "json")
            else {
                promise(.failure(APIError.invalidURL))
                return
            }
            let data = try! Data(contentsOf: url)
            do{
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let stockResponse = try decoder.decode(StockResponse.self, from: data)
//                print(stockResponse)
                promise(.success(stockResponse))
            } catch {
                promise(.failure(APIError.decodingError))
            }
        }
    }
}

