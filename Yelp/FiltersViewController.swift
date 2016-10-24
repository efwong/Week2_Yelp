//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Edwin Wong on 10/22/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate{
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters:[String:AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate:FiltersViewControllerDelegate?
    var prevSettings:SearchFilterSettings?
    
    let tableStructure : [[Int]] = [[0],[0,1,2,3,4], [0,1,2]]
    
    // section indexes
    let distanceSectionIndex = 1
    let sortBySectionIndex = 2
    let categorySectionIndex = 3
    
    // store type of sections
    let sectionType = [FilterType.deals, FilterType.distance, FilterType.sortBy, FilterType.category]
    
    var categories:[[String:String]]!
    var distanceFilter: FiltersDistanceEnum?
    var sortByFilter: FiltersSortEnum?
    var hasDeals:Bool = false
    
    var switchStates = [Int:[Int:Bool]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeSwitchStates()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 50
        
        categories = yelpCategories()
        // Do any additional setup after loading the view.
        loadPrevSettings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    // reset values to default state
    @IBAction func onClearButton(_ sender: AnyObject) {
        initializeSwitchStates()
        distanceFilter = FiltersDistanceEnum.auto
        sortByFilter = FiltersSortEnum.bestMatch
        self.switchStates[distanceSectionIndex]?[FiltersDistanceEnum.auto.rawValue] = true
        self.switchStates[sortBySectionIndex]?[FiltersSortEnum.bestMatch.rawValue] = true
        hasDeals = false
        self.tableView.reloadData()
    }
    
    @IBAction func onSearchButton(_ sender: AnyObject) {
        var filters = [String: AnyObject]()
        
        // get selected categories coded string
        var selectedCategories = [String]()
        
        // update categories
        if let switchCategories = switchStates[categorySectionIndex]{
            for (row, isSelected) in switchCategories{
                if isSelected{
                    selectedCategories.append(categories[row]["code"]!)
                }
            }
        }
        // send back selected categories if count > 0
        if selectedCategories.count > 0{
            filters[FilterType.category.rawValue] = selectedCategories as AnyObject?
        }
        if sortByFilter != nil{
            filters[FilterType.sortBy.rawValue] = sortByFilter!.rawValue as AnyObject?
        }
        if distanceFilter != nil{
            filters[FilterType.distance.rawValue] = distanceFilter!.getValue as AnyObject?
        }
        filters[FilterType.deals.rawValue] = hasDeals as AnyObject?
        
        delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filters)
        dismiss(animated: true, completion: nil)
    }

    // MARK: table view methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionType.count // 4 sections for deals, Distance, sortBy and category
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sectionType[section] == FilterType.deals{
            return nil
        }else{
            return sectionType[section].rawValue
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < sectionType.count {
            if sectionType[section] == FilterType.category{
                // special case categories -> list all categories
                return categories.count
            }else{
                return tableStructure[section].count
            }
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
        
        if sectionType[indexPath.section] == FilterType.category{
            cell.filterType = FilterType.category
            cell.switchLabel.text = categories[indexPath.row]["name"]
            cell.onSwitch.setOn(switchStates[indexPath.section]?[indexPath.row] ?? false, animated: false)
        }else if sectionType[indexPath.section] == FilterType.sortBy{
            if let sortEnum = FiltersSortEnum(rawValue: tableStructure[indexPath.section][indexPath.row]) {
                cell.filterType = FilterType.sortBy
                cell.switchLabel.text = sortEnum.title
                cell.switchValue = sortEnum.rawValue
                cell.onSwitch.setOn(switchStates[indexPath.section]?[indexPath.row] ?? false, animated: false)
            }
        }else if sectionType[indexPath.section] == FilterType.distance{
            if let distanceEnum = FiltersDistanceEnum(rawValue: tableStructure[indexPath.section][indexPath.row]) {
                cell.filterType = FilterType.distance
                cell.switchLabel.text = distanceEnum.title
                cell.switchValue = distanceEnum.rawValue
                cell.onSwitch.setOn(switchStates[indexPath.section]?[indexPath.row] ?? false, animated: false)
            }
        }else if sectionType[indexPath.section] == FilterType.deals{
            cell.filterType = FilterType.deals
            cell.switchLabel.text = "Offering a Deal"
            cell.switchValue = nil
            cell.onSwitch.setOn(hasDeals, animated: false)
        }
        
        cell.delegate = self
        
        return cell
    }
    
    
    // MARK: SwitchCell delegate
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        if let indexPath = self.tableView.indexPath(for: switchCell){
            if switchCell.filterType == FilterType.distance{
                // turn off all other distance switches
                turnOffAllCellsBySection(indexPath.section)
                if switchCell.switchValue != nil && switchCell.switchValue! > 0 {
                    // distance 0 means auto
                    distanceFilter = FiltersDistanceEnum(rawValue: switchCell.switchValue!)
                }
                switchStates[indexPath.section]?[indexPath.row] = value
                self.tableView.reloadData()
                
            } else if switchCell.filterType == FilterType.sortBy{
                // turn off all other sortBy switches
                turnOffAllCellsBySection(indexPath.section)
                sortByFilter = FiltersSortEnum(rawValue: switchCell.switchValue!)
                switchStates[indexPath.section]?[indexPath.row] = value
                self.tableView.reloadData()
                
            } else if switchCell.filterType == FilterType.deals {
                hasDeals = value
            }else{
                switchStates[indexPath.section]?[indexPath.row] = value
            }
        }
    }
    
    // turn off all cells in a section
    func turnOffAllCellsBySection(_ section:Int){
        if let switchStatesSection = switchStates[section] {
            for (index,_) in switchStatesSection{
                switchStates[section]?[index] = false
            }
        }
    }
    
    // initialize switch states
    func initializeSwitchStates(){
        for (index,_) in sectionType.enumerated(){
            switchStates[index] = [Int:Bool]()
        }
    }
    
    // MARK: yelp categories
    func yelpCategories() -> [[String:String]]{
        let categories = [["name" : "Afghan", "code": "afghani"],
                          ["name" : "African", "code": "african"],
                          ["name" : "American, New", "code": "newamerican"],
                          ["name" : "American, Traditional", "code": "tradamerican"],
                          ["name" : "Arabian", "code": "arabian"],
                          ["name" : "Argentine", "code": "argentine"],
                          ["name" : "Armenian", "code": "armenian"],
                          ["name" : "Asian Fusion", "code": "asianfusion"],
                          ["name" : "Asturian", "code": "asturian"],
                          ["name" : "Australian", "code": "australian"],
                          ["name" : "Austrian", "code": "austrian"],
                          ["name" : "Baguettes", "code": "baguettes"],
                          ["name" : "Bangladeshi", "code": "bangladeshi"],
                          ["name" : "Barbeque", "code": "bbq"],
                          ["name" : "Basque", "code": "basque"],
                          ["name" : "Bavarian", "code": "bavarian"],
                          ["name" : "Beer Garden", "code": "beergarden"],
                          ["name" : "Beer Hall", "code": "beerhall"],
                          ["name" : "Beisl", "code": "beisl"],
                          ["name" : "Belgian", "code": "belgian"],
                          ["name" : "Bistros", "code": "bistros"],
                          ["name" : "Black Sea", "code": "blacksea"],
                          ["name" : "Brasseries", "code": "brasseries"],
                          ["name" : "Brazilian", "code": "brazilian"],
                          ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                          ["name" : "British", "code": "british"],
                          ["name" : "Buffets", "code": "buffets"],
                          ["name" : "Bulgarian", "code": "bulgarian"],
                          ["name" : "Burgers", "code": "burgers"],
                          ["name" : "Burmese", "code": "burmese"],
                          ["name" : "Cafes", "code": "cafes"],
                          ["name" : "Cafeteria", "code": "cafeteria"],
                          ["name" : "Cajun/Creole", "code": "cajun"],
                          ["name" : "Cambodian", "code": "cambodian"],
                          ["name" : "Canadian", "code": "New)"],
                          ["name" : "Canteen", "code": "canteen"],
                          ["name" : "Caribbean", "code": "caribbean"],
                          ["name" : "Catalan", "code": "catalan"],
                          ["name" : "Chech", "code": "chech"],
                          ["name" : "Cheesesteaks", "code": "cheesesteaks"],
                          ["name" : "Chicken Shop", "code": "chickenshop"],
                          ["name" : "Chicken Wings", "code": "chicken_wings"],
                          ["name" : "Chilean", "code": "chilean"],
                          ["name" : "Chinese", "code": "chinese"],
                          ["name" : "Comfort Food", "code": "comfortfood"],
                          ["name" : "Corsican", "code": "corsican"],
                          ["name" : "Creperies", "code": "creperies"],
                          ["name" : "Cuban", "code": "cuban"],
                          ["name" : "Curry Sausage", "code": "currysausage"],
                          ["name" : "Cypriot", "code": "cypriot"],
                          ["name" : "Czech", "code": "czech"],
                          ["name" : "Czech/Slovakian", "code": "czechslovakian"],
                          ["name" : "Danish", "code": "danish"],
                          ["name" : "Delis", "code": "delis"],
                          ["name" : "Diners", "code": "diners"],
                          ["name" : "Dumplings", "code": "dumplings"],
                          ["name" : "Eastern European", "code": "eastern_european"],
                          ["name" : "Ethiopian", "code": "ethiopian"],
                          ["name" : "Fast Food", "code": "hotdogs"],
                          ["name" : "Filipino", "code": "filipino"],
                          ["name" : "Fish & Chips", "code": "fishnchips"],
                          ["name" : "Fondue", "code": "fondue"],
                          ["name" : "Food Court", "code": "food_court"],
                          ["name" : "Food Stands", "code": "foodstands"],
                          ["name" : "French", "code": "french"],
                          ["name" : "French Southwest", "code": "sud_ouest"],
                          ["name" : "Galician", "code": "galician"],
                          ["name" : "Gastropubs", "code": "gastropubs"],
                          ["name" : "Georgian", "code": "georgian"],
                          ["name" : "German", "code": "german"],
                          ["name" : "Giblets", "code": "giblets"],
                          ["name" : "Gluten-Free", "code": "gluten_free"],
                          ["name" : "Greek", "code": "greek"],
                          ["name" : "Halal", "code": "halal"],
                          ["name" : "Hawaiian", "code": "hawaiian"],
                          ["name" : "Heuriger", "code": "heuriger"],
                          ["name" : "Himalayan/Nepalese", "code": "himalayan"],
                          ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
                          ["name" : "Hot Dogs", "code": "hotdog"],
                          ["name" : "Hot Pot", "code": "hotpot"],
                          ["name" : "Hungarian", "code": "hungarian"],
                          ["name" : "Iberian", "code": "iberian"],
                          ["name" : "Indian", "code": "indpak"],
                          ["name" : "Indonesian", "code": "indonesian"],
                          ["name" : "International", "code": "international"],
                          ["name" : "Irish", "code": "irish"],
                          ["name" : "Island Pub", "code": "island_pub"],
                          ["name" : "Israeli", "code": "israeli"],
                          ["name" : "Italian", "code": "italian"],
                          ["name" : "Japanese", "code": "japanese"],
                          ["name" : "Jewish", "code": "jewish"],
                          ["name" : "Kebab", "code": "kebab"],
                          ["name" : "Korean", "code": "korean"],
                          ["name" : "Kosher", "code": "kosher"],
                          ["name" : "Kurdish", "code": "kurdish"],
                          ["name" : "Laos", "code": "laos"],
                          ["name" : "Laotian", "code": "laotian"],
                          ["name" : "Latin American", "code": "latin"],
                          ["name" : "Live/Raw Food", "code": "raw_food"],
                          ["name" : "Lyonnais", "code": "lyonnais"],
                          ["name" : "Malaysian", "code": "malaysian"],
                          ["name" : "Meatballs", "code": "meatballs"],
                          ["name" : "Mediterranean", "code": "mediterranean"],
                          ["name" : "Mexican", "code": "mexican"],
                          ["name" : "Middle Eastern", "code": "mideastern"],
                          ["name" : "Milk Bars", "code": "milkbars"],
                          ["name" : "Modern Australian", "code": "modern_australian"],
                          ["name" : "Modern European", "code": "modern_european"],
                          ["name" : "Mongolian", "code": "mongolian"],
                          ["name" : "Moroccan", "code": "moroccan"],
                          ["name" : "New Zealand", "code": "newzealand"],
                          ["name" : "Night Food", "code": "nightfood"],
                          ["name" : "Norcinerie", "code": "norcinerie"],
                          ["name" : "Open Sandwiches", "code": "opensandwiches"],
                          ["name" : "Oriental", "code": "oriental"],
                          ["name" : "Pakistani", "code": "pakistani"],
                          ["name" : "Parent Cafes", "code": "eltern_cafes"],
                          ["name" : "Parma", "code": "parma"],
                          ["name" : "Persian/Iranian", "code": "persian"],
                          ["name" : "Peruvian", "code": "peruvian"],
                          ["name" : "Pita", "code": "pita"],
                          ["name" : "Pizza", "code": "pizza"],
                          ["name" : "Polish", "code": "polish"],
                          ["name" : "Portuguese", "code": "portuguese"],
                          ["name" : "Potatoes", "code": "potatoes"],
                          ["name" : "Poutineries", "code": "poutineries"],
                          ["name" : "Pub Food", "code": "pubfood"],
                          ["name" : "Rice", "code": "riceshop"],
                          ["name" : "Romanian", "code": "romanian"],
                          ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
                          ["name" : "Rumanian", "code": "rumanian"],
                          ["name" : "Russian", "code": "russian"],
                          ["name" : "Salad", "code": "salad"],
                          ["name" : "Sandwiches", "code": "sandwiches"],
                          ["name" : "Scandinavian", "code": "scandinavian"],
                          ["name" : "Scottish", "code": "scottish"],
                          ["name" : "Seafood", "code": "seafood"],
                          ["name" : "Serbo Croatian", "code": "serbocroatian"],
                          ["name" : "Signature Cuisine", "code": "signature_cuisine"],
                          ["name" : "Singaporean", "code": "singaporean"],
                          ["name" : "Slovakian", "code": "slovakian"],
                          ["name" : "Soul Food", "code": "soulfood"],
                          ["name" : "Soup", "code": "soup"],
                          ["name" : "Southern", "code": "southern"],
                          ["name" : "Spanish", "code": "spanish"],
                          ["name" : "Steakhouses", "code": "steak"],
                          ["name" : "Sushi Bars", "code": "sushi"],
                          ["name" : "Swabian", "code": "swabian"],
                          ["name" : "Swedish", "code": "swedish"],
                          ["name" : "Swiss Food", "code": "swissfood"],
                          ["name" : "Tabernas", "code": "tabernas"],
                          ["name" : "Taiwanese", "code": "taiwanese"],
                          ["name" : "Tapas Bars", "code": "tapas"],
                          ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
                          ["name" : "Tex-Mex", "code": "tex-mex"],
                          ["name" : "Thai", "code": "thai"],
                          ["name" : "Traditional Norwegian", "code": "norwegian"],
                          ["name" : "Traditional Swedish", "code": "traditional_swedish"],
                          ["name" : "Trattorie", "code": "trattorie"],
                          ["name" : "Turkish", "code": "turkish"],
                          ["name" : "Ukrainian", "code": "ukrainian"],
                          ["name" : "Uzbek", "code": "uzbek"],
                          ["name" : "Vegan", "code": "vegan"],
                          ["name" : "Vegetarian", "code": "vegetarian"],
                          ["name" : "Venison", "code": "venison"],
                          ["name" : "Vietnamese", "code": "vietnamese"],
                          ["name" : "Wok", "code": "wok"],
                          ["name" : "Wraps", "code": "wraps"],
                          ["name" : "Yugoslav", "code": "yugoslav"]]
        return categories
    }
    
    func loadPrevSettings(){
        // preload distance
        if let distance = prevSettings?.distance {
            self.distanceFilter = FiltersDistanceEnum.getFilterDistanceEnumByDouble(value: distance)
            if let index = self.distanceFilter?.rawValue{
                self.switchStates[distanceSectionIndex]?[index] = true
            }
        }
        
        // preload sort
        if let sortBy = prevSettings?.sortBy {
            self.sortByFilter = FiltersSortEnum(rawValue: sortBy)
            self.switchStates[sortBySectionIndex]?[sortBy] = true
        }
        
        if let isOfferingADeal = prevSettings?.isOfferingADeal{
            self.hasDeals = isOfferingADeal
        }
        
        if prevSettings?.categories != nil && (prevSettings?.categories.count)! > 0{
            // load category dictionary for parsing
            var categoryDict = [String:Int]()
            for (index, categoryObj) in self.categories.enumerated(){
                let code:String = categoryObj["code"]!
                categoryDict[code] = index
            }
            
            for category in (self.prevSettings?.categories)! {
                if categoryDict[category] != nil{
                    let index:Int = categoryDict[category]!
                    switchStates[categorySectionIndex]?[index] = true
                }
//                for (index, stringDict) in self.categories.enumerated(){
//                    if category == stringDict["code"]{
//                        switchStates[categorySectionIndex]?[index] = true
//                        break
//                    }
//                }
            }
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
