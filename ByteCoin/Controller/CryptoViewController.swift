//
//  ViewController.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import UIKit

class CryptoViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionViewCrypto: UICollectionView!
    @IBOutlet weak var pickerViewCurrency: UIPickerView!
    var coinManager : CoinManager = CoinManager()
    var cryptoCoins : [CoinModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting Picker
        pickerViewCurrency.dataSource = self
        pickerViewCurrency.delegate = self
        
        // Setting CollectionView
        collectionViewCrypto.dataSource = self
        collectionViewCrypto.delegate = self
        collectionViewCrypto.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:))))
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension CryptoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cryptoCoins.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionViewCrypto.dequeueReusableCell(withReuseIdentifier: "CryptoCell", for: indexPath)
        
        // cell rounded section
        cell.layer.cornerRadius = 15.0
        cell.layer.borderWidth = 5.0
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.masksToBounds = true
        
        
        
        
        // cell info
        if let cryptoCell = cell as? CryptoCollectionViewCell{
            let cryptoCoin = cryptoCoins[indexPath.row]
            
            // Currency Symbol
            let locales: NSArray = NSLocale.availableLocaleIdentifiers as NSArray
            for localeID in locales as! [NSString] {
                let locale = NSLocale(localeIdentifier: localeID as String)
                let code = locale.object(forKey: NSLocale.Key.currencyCode) as? String
                if code == cryptoCoin.currency ?? "BRL" {
                    let symbol = locale.object(forKey: NSLocale.Key.currencySymbol) as? String
                    cryptoCell.lblPrice.text = String(format: "\(symbol ?? "") %.2f", cryptoCoin.price ?? 0)
                    cryptoCell.lblTicket.text = cryptoCoin.ticket ?? ""
                break
                }
            }
            
            cryptoCell.imgMoney.image = cryptoCoin.icon
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7.5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width/3.0 - 5
        let cellHeight = cellWidth * 0.8
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        guard let collectionView = collectionViewCrypto else {
            return
        }
        
        switch gesture.state {
        case .began:
            guard let targetIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                return
            }
            collectionView.beginInteractiveMovementForItem(at: targetIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = cryptoCoins.remove(at: sourceIndexPath.row)
        cryptoCoins.insert(item, at: destinationIndexPath.row)
    }
}


// MARK: - CoinManagerDelegate

extension CryptoViewController: CoinManagerDelegate {
    func didRecieveCoinData(_ coinManager: CoinManager, _ coinModel: CoinModel) {
        if coinModel.ticket != nil {
            cryptoCoins.append(coinModel)
            DispatchQueue.main.async { [unowned self] in
                collectionViewCrypto.reloadData()
            }
        }
    }
    
    func didFailWithError(_ error: Error) {
        print("error! ", error)
    }
    
    
}


// MARK: - UIPickerViewDataSource, UIPickerViewDelegate

extension CryptoViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coinManager.currencyArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Calling Manager
        coinManager.delegate = self
        for ticket in coinManager.coinArray {
            coinManager.fetchCryptoQuotation(ticket: ticket, currency: coinManager.currencyArray[row] as String)
        }
        cryptoCoins.removeAll()
        DispatchQueue.main.async { [unowned self] in
            collectionViewCrypto.reloadData()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attString = NSAttributedString(string: coinManager.currencyArray[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
            return attString
    }
    
    
    
}
