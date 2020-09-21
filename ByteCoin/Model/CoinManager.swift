//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didRecieveCoinData(_ coinManager: CoinManager, _ coinModel: CoinModel)
    func didFailWithError(_ error: Error)
}

struct CoinManager {
    var delegate: CoinManagerDelegate?
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/"
    let apiKey = "8C16581E-1EEB-47A7-B7A8-808D1D9BB5F6"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    let coinArray = ["BTC", "ETH", "USDT", "XRP", "BCH", "DOT", "BNB", "LINK", "CRO", "LTC", "ADA", "EOS", "USDC", "TRX", "NEO", "DAI", "ZEC", "UNI", "THETA", "TUSD", "ONT", "MKR", "DGB"]
    
    
    func fetchCryptoQuotation(ticket: String, currency: String) {
        let urlString = "\(baseURL)\(ticket)/\(currency)?apiKey=\(apiKey)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        
        var urlFinalString = urlString
        
        // Treating Spaces
        if let noSpacesUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
            urlFinalString = noSpacesUrlString
        }
        
        // 1. Create a URL
        if let url = URL(string: urlFinalString) {
            
            // 2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            // 3. Give the session a Task
            let task = session.dataTask(with: url) { (data, response, error) in
                // I am inside an Closure!
                if let safeError = error {
                    self.delegate?.didFailWithError(safeError)
                    return
                }
                
                if let safeData = data {
                    // Explicit 'self' cause we are inside an Closure
                    if let coinModel = self.parseJSON(safeData){
                        self.delegate?.didRecieveCoinData(self, coinModel)
                    }
                }
            }
            
            // 4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ coinData: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        do {
            // Using a Codable Struct to parse automatically
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let ticket = decodedData.assetIDBase
            let currency = decodedData.assetIDQuote
            let price = decodedData.rate
            let coinModel =  CoinModel(ticket: ticket, price: price, currency: currency)
            return coinModel
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }

}
