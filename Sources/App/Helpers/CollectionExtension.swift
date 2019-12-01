//
//  CollectionExtension.swift
//  App
//
//  Created by Ilya Sysoi on 12/1/19.
//

import Foundation

extension Collection {
    func choose(_ number: Int) -> ArraySlice<Element> { shuffled().prefix(number) }
}
