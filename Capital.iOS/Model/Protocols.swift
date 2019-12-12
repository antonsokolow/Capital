//
//  Protocols.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 15.08.2019.
//  Copyright © 2019 Anton Sokolov. All rights reserved.
//

import Foundation

/**
 * Описывает сущность которая может сохранять данные в Core Data и
 * отображаться в виде формы
 */
protocol Item: class {
    associatedtype T: ItemType
    var itemType: T { get }
    func create(type: T, properties: PropertyContainer)
    func update(properties: PropertyContainer)
    func getProperties() -> PropertyContainer
}

protocol ItemType: CaseIterable {
    var name: String { get }
    var cells: [Field] { get }
    var rawValue: String { get }
}

protocol HeaderDelegate {
    func callHeader(idx: Int)
    func addItem(idx: Int)
}

protocol SelectIcon {
    func selectIcon(name: String)
}

protocol SelectValueDelegate {
    var properties: PropertyContainer { get set }
    func update(indexPath: IndexPath)
}

protocol DeleteValueDelegate {
    func deleteValue(category: Category)
    var updateIndexPath: IndexPath? {get set}
}

protocol SetTitle {
    func setTitle(title: String)
    var budgetController: BudgetViewController? { get set }
}


protocol PushController {
    static func storyboardInstance() -> PushController?
}
