//
//  UITableViewExtension.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 21.08.2019.
//  Copyright © 2019 Anton Sokolov. All rights reserved.
//

import UIKit

// Чудо экстеншен который обновляет данные в таблице
// при изменении модели
// Подсмотрено на презентации Realm
extension UITableView {
    func applyChanges(changes: ViewModelChange) {
        switch changes {
        case .initial:
            // Results are now populated and can be accessed without blocking the UI
            reloadData()
        case .update(let deletions, let insertions, let modifications, let sections):
            // Query results have changed, so apply them to the UITableView
            beginUpdates()
            for section in sections {
                reloadSections(IndexSet(section...section), with: .automatic)
            }
            insertRows(at: insertions,
                       with: .automatic)
            deleteRows(at: deletions,
                       with: .automatic)
            reloadRows(at: modifications,
                       with: .automatic)
            endUpdates()
            
        case .error(let error):
            // An error occurred while opening the Realm file on the background worker thread
            fatalError("\(error)")
        }
    }
}
