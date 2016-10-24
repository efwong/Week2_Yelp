//
//  FiltersEnum.swift
//  Yelp
//
//  Created by Edwin Wong on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import Foundation

enum FiltersSortEnum:Int{
    
    case bestMatch=0, distance=1, highestRated=2
    var title:String{
        switch self{
        case .bestMatch: return "Best Match"
        case .distance: return "Distance"
        case .highestRated: return "Highest Rated"
        //default: return ""
        }
    }
    
}

enum FiltersDistanceEnum:Int{
    case auto = 0, pointThreeMile, oneMile, fiveMile, twentyMile
    var title:String{
        switch self{
            case .auto: return "Auto"
            case .pointThreeMile: return "0.3 mile"
            case .oneMile: return "1 mi"
            case .fiveMile: return "5 mi"
            case .twentyMile: return "20 mi"
        //    default: return ""
        }
    }
    var getValue:Double{
        switch self{
        case .auto: return 0
        case .pointThreeMile: return 0.3
        case .oneMile: return 1
        case .fiveMile: return 5
        case .twentyMile: return 20
        //default: return 0
        }
    }
    
    static func getFilterDistanceEnumByDouble(value:Double) -> FiltersDistanceEnum{
        switch value{
            case 0:
                return self.auto
            case 0.3:
                return self.pointThreeMile
            case 1:
                return self.oneMile
            case 5:
                return self.fiveMile
            case 20:
                return self.twentyMile
            default:
                return self.auto
        }
    }
}

enum FilterType:String{
    case deals="Deals", distance = "Distance", sortBy = "SortBy", category = "Category"
}
