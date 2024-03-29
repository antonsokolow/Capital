//
//  CollectionChange.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 21.08.2019.
//  Copyright © 2019 Anton Sokolov. All rights reserved.
//

import Foundation


public enum ViewModelChange {
    
    /**
     `.initial` indicates that the initial run of the query has completed (if
     applicable), and the collection can now be used without performing any
     blocking work.
     */
    case initial
    
    /**
     `.update` indicates that a write transaction has been committed which
     either changed which objects are in the collection, and/or modified one
     or more of the objects in the collection.
     
     All three of the change arrays are always sorted in ascending order.
     
     - parameter deletions:     The indices in the previous version of the collection which were removed from this one.
     - parameter insertions:    The indices in the new collection which were added in this version.
     - parameter modifications: The indices of the objects in the new collection which were modified in this version.
     */
    case update(deletions: [IndexPath], insertions: [IndexPath], modifications: [IndexPath], sections: [Int])
    
    /**
     If an error occurs, notification blocks are called one time with a `.error`
     result and an `NSError` containing details about the error. This can only
     currently happen if opening the Realm on a background thread to calcuate
     the change set fails. The callback will never be called again after it is
     invoked with a .error value.
     */
    case error(Error)
}
