//
//  RecentsList.swift
//  Blackbox
//
//  Created by Grady Haynes on 12/17/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

public struct RecentsList<Element> {
    let maxCount: Int
    private(set) var elements: [Element] = []
    private let equatingFunction: (Element, Element) -> Bool

    init(elements: [Element] = [], maxCount: Int = .max, equatingFunction: @escaping (Element, Element) -> Bool) {
        precondition(maxCount > 0)
        self.maxCount = maxCount
        self.equatingFunction = equatingFunction
        for element in elements {
            add(element)
        }
    }

    init(elements: [Element] = [], maxCount: Int = .max) where Element: Equatable {
        self.init(elements: elements, maxCount: maxCount, equatingFunction: { $0 == $1 })
    }
    
    mutating func add(_ element: Element) {
        // Remove any existing matching instances and append the new one
        let newList = elements.filter { !equatingFunction($0, element) } + [element]
        // Drop old ones as needed
        elements = Array(newList.dropFirst(max(0, newList.count - maxCount)))
    }
    
    mutating func clear() {
        elements = []
    }
}
