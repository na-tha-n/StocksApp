//
//  ContentView.swift
//  CashAppStocks
//
//  Created by Ngoc Nguyen on 7/11/23.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var viewModel = ViewModel(service: Service())
    @State var service = Service()
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.blue]), startPoint: .topLeading, endPoint: .bottom)
                .ignoresSafeArea()
            VStack{
                NavigationTopView()
                

                ScrollView {
                    switch viewModel.status{
                    case .initial:
                        Text("Stock List")
                    case .loading:
                        ProgressView()
                            .frame(width: 400, height: 400)
                            .scaleEffect(5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    case .success:
                        if let stocks = viewModel.stocks {
                            LazyVStack(alignment: .leading){
                                ForEach(stocks.stocks, id: \.ticker){ stock in
                                    StockCell(stock: stock)
                                }
                            }
                        }
                    case .error:
                        Text("Error Occur")
                    }
                    
                }
                .padding(.horizontal, 10)
                .onAppear{
                    viewModel.fetchStocksAsyncAwait()
//                    service.getStockFuture()
//                    viewModel.fetchStockFuture()
                }
//                .overlay(
//                    RoundedRectangle(cornerRadius: 15)
//                        .stroke(Color.red, lineWidth: 2)
//                )
                NavigationBottomView()

            }
        }
    }
}

struct NavigationTopView: View{
    var body: some View{
        HStack{
            Text("Stocks Market")
                .foregroundColor(Color.white)
                .font(.largeTitle)
                .bold()
            Spacer()
            Image(systemName: "magnifyingglass")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
            Image(systemName: "square.grid.4x3.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .foregroundColor(Color.white)
        .background(Color.white.opacity(0.2))
    }
}

struct NavigationBottomView: View{
    var body: some View{
        VStack{
            Spacer()
            HStack{
                Spacer()
                Image(systemName: "chart.bar")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "dot.radiowaves.up.forward")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "bell")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(10)
            .foregroundColor(Color.white)
            .background(Color.white.opacity(0.2))
        }
        .frame(height: 30)
        .ignoresSafeArea()
    }
}

struct StockCell: View{
    let stock: Stock
    var body: some View {
        VStack{
            HStack{
                ZStack {
                    // Circle with random gradient
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [.random, .random]), startPoint: .top, endPoint: .bottomTrailing))
                        .frame(width: 75, height: 75)
                    // Stock ticker
                    Text(stock.ticker)
                        .foregroundColor(.white)
                        .bold()
                }
                .padding(2)
                
                VStack(alignment: .leading) {
                    Text(stock.name)
                        .font(.title3)
                        .bold()
                        .lineLimit(1)
                    Spacer()
                    HStack{
                        Text(stock.currency + " " + String(formatCurrency(amount: Double(stock.currentPriceCents))))
                        
                        Spacer()
                        if let quantity = stock.quantity {
                            Text("Qty: " + String(quantity))
                        }
                    }
                    Spacer()
                    Text(String(formatDate(timestamp: Double( stock.currentPriceTimestamp))))
                }
                
                Spacer()
            }
            .padding()
        }
        .foregroundColor(Color.white)
        .background(Color.white.opacity(0.2))
        .cornerRadius(20)
//        .overlay(
//            RoundedRectangle(cornerRadius: 15)
//                .stroke(Color.red, lineWidth: 2)
//        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

//Helper
extension Color {
    static var random: Color {
        return Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
    }
}

func formatDate(timestamp: Double) -> String {
    let date = Date(timeIntervalSince1970: timestamp/1000)
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    return formatter.string(from: date)
}

func formatCurrency(amount: Double) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    numberFormatter.locale = Locale.current
    return numberFormatter.string(from: NSNumber(value: amount)) ?? ""
}
