//
//  CoinModel.swift
//  ByteCoin
//
//  Created by João Pedro Giarrante on 20/09/20.
//  Copyright © 2020 The App Brewery. All rights reserved.
//

import UIKit

struct CoinModel {
    let price: Double?
    let ticket: String?
    let currency: String?
    var icon: UIImage {
        return getIcon(from: ticket)
    }
    
    
    
    init(ticket: String?, price: Double?, currency: String?) {
        self.ticket = ticket
        self.price = price
        self.currency = currency
    }
    
    
    // Computer Property
    func getIcon(from ticket: String?) -> UIImage {
        guard let safeTicket = ticket else {
            return UIImage.init(named: "Default Icon") ?? UIImage.init()
        }
        
        guard let image = UIImage.init(named: safeTicket) else {
            return UIImage.init(named: "Default Icon") ?? UIImage.init()
        }
        
        return image
    }
}
