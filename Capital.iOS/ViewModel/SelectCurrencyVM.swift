//
//  SelectCurrencyVM.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 28.08.2019.
//  Copyright © 2019 Anton Sokolov. All rights reserved.
//

import Foundation

class SelectCurrencyVM {
    private var data = [[CurrencyRate]]()
    
    func prepareData() {
        data.append(DataStore.shared.getCurrencyRates().filter { $0.isFavorite == true })
        data.append(DataStore.shared.getCurrencyRates())
    }
    
    func numberOfSections() -> Int {
        return data.count
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return data[section].count
    }
    
    func titleForHeaderInSection(section: Int) -> String {
        if(section == 0) {
            return NSLocalizedString("Favorites", comment: "")
        }
        return NSLocalizedString("ALL_CURRENCY", comment: "")
    }
    
    func getCurrencyListCellVM(at indexPath: IndexPath) -> CurrencyListCellVM {
        let viewModel = CurrencyListCellVM(currencyRate: data[indexPath.section][indexPath.row])
        viewModel.reload = self.relodData
        return viewModel
    }
    
    func getValue(at indexPath: IndexPath) -> CurrencyRate {
        return data[indexPath.section][indexPath.row]
    }
    
    // Обновляет список Избранное
    func relodData(currencyRate: CurrencyRate) {
        var modifications = [IndexPath]()
        var insertions = [IndexPath]()
        var deletions = [IndexPath]()
        guard let reload = self.reload else { return }
        
        if(!currencyRate.isFavorite) {
            if let index = data[0].firstIndex(where: {$0.objectID == currencyRate.objectID}) {
                data[0].remove(at: index)
                deletions.append(IndexPath(row: index, section: 0))
            }
        } else {
            data[0].append(currencyRate)
            insertions.append(IndexPath(row: data[0].count-1, section: 0))
        }
        
        if let index = data[1].firstIndex(where: {$0.objectID == currencyRate.objectID}) {
            modifications.append(IndexPath(row: index, section: 1))
        }
        let changes = ViewModelChange.update(deletions: deletions, insertions: insertions, modifications: modifications, sections: [])
        reload(changes)
    }
    
    var reload: ((_ changes: ViewModelChange) -> Void)?
}
