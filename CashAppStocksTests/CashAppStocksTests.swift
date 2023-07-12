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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGetStocksSuccess(){
        let exp = XCTestExpectation(description: "testing success")
        
        let viewModel = ViewModel(service: MockService(fileName: .getStocksSuccess))
        viewModel.fetchStocks()
        
        // Use DispatchQueue to introduce delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            //Assertion checks
            XCTAssertEqual(viewModel.stocks?.stocks.first?.ticker, "^GSPC")
            exp.fulfill()
        }

        // Wait for the expectation to be fulfilled
        wait(for: [exp], timeout: 5.0)
    }
    
    func testGetStocksFailureEmpty(){
        let exp = XCTestExpectation(description: "testing failure empty")

        let viewModel = ViewModel(service: MockService(fileName: .getStocksFailureEmpty))
        viewModel.fetchStocks()
        
        // Use DispatchQueue to introduce delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            //Assertion checks
            XCTAssertEqual(viewModel.stocks?.stocks.count, 0)
            exp.fulfill()
        }

        // Wait for the expectation to be fulfilled
        wait(for: [exp], timeout: 5.0)
    }
    
    func testGetStocksFailureMalformed(){
        let exp = XCTestExpectation(description: "testing failure malformed")

        let viewModel = ViewModel(service: MockService(fileName: .getStocksFailureMalformed))
        viewModel.fetchStocks()
        
        // Use DispatchQueue to introduce delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Check the status
            switch viewModel.status {
            case .error(_):
                // success, do nothing
                break
            default:
                XCTFail("Expected .error status")
            }
            exp.fulfill()
        }

        // Wait for the expectation to be fulfilled
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
        
    func getStock() async throws -> StockResponse {
        guard let url = self.loadMockData(fileName.rawValue) else { throw APIError.invalidURL }
        let data = try! Data(contentsOf: url)

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let stockResponse = try decoder.decode(StockResponse.self, from: data)
            return stockResponse
        } catch {
            throw APIError.decodingError
        }
    }
}
