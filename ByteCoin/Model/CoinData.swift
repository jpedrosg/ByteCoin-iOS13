//
//  CryptoCoin.swift
//  ByteCoin
//
//  Created by João Pedro Giarrante on 20/09/20.
//  Copyright © 2020 The App Brewery. All rights reserved.
//
//   let cryptoCoin = try? newJSONDecoder().decode(CryptoCoin.self, from: jsonData)

import Foundation

// MARK: - CryptoCoin
struct CoinData: Codable {
    var time, assetIDBase, assetIDQuote: String?
    var rate: Double?

    enum CodingKeys: String, CodingKey {
        case time
        case assetIDBase = "asset_id_base"
        case assetIDQuote = "asset_id_quote"
        case rate
    }
}
