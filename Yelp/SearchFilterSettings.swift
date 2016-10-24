//
//  SearchFilterSettings.swift
//  Yelp
//
//  Created by Edwin Wong on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import Foundation

struct SearchFilterSettings{
    
    var searchText: String?
    var categories = [String]()
    var sortBy: Int? // Default Best matched
    var distance: Double? // radius filter
    var isOfferingADeal: Bool
    
    init() {
        searchText = nil
        isOfferingADeal = false
    }
}
