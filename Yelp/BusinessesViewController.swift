//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate, UISearchBarDelegate {
    
    var searchBar: UISearchBar!
    var businesses: [Business]!
    var searchSettings: SearchFilterSettings = SearchFilterSettings()
    
    @IBOutlet weak var tableView: UITableView!

    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // implement searchbar
        self.searchBar = UISearchBar()
        // Initialize the UISearchBar
        self.searchBar.delegate = self
        
        // Add SearchBar to the NavigationBar
        self.searchBar.sizeToFit()
        self.navigationItem.titleView = searchBar
        
        // set filter button color
        filterButton.customView?.layer.borderColor = UIColor.white.cgColor
        filterButton.customView?.layer.borderWidth = 1.0
        
        //self.navigationController?.navigationBar.barTintColor = UIColor.red
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        self.searchSettings.searchText = "restaurant"
        self.searchSettings.distance = 0 //auto
        self.searchSettings.sortBy = 0 // auto
        doSearchBySettings()
        
//        Business.searchWithTerm(term: "", completion: { (businesses: [Business]?, error: Error?) -> Void in
//            
//            self.businesses = businesses
//            self.tableView.reloadData()
//            
//            if let businesses = businesses {
//                for business in businesses {
//                    print(business.name!)
//                    print(business.address!)
//                }
//            }
//            
//            }
//        )
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil{
            return businesses!.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        
        return cell
    }
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToFiltersModal"{
            if let navigationVC = segue.destination as? UINavigationController{
                if let filtersVC = navigationVC.topViewController as? FiltersViewController{
                    filtersVC.delegate = self
                    filtersVC.prevSettings = self.searchSettings
                }
                
            }
        }
    }
    
    // MARK: FiltersViewControllerDelegate methods
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        for (key, value) in filters{
            if key == FilterType.category.rawValue{
                if let categories = value as? [String] {
                    self.searchSettings.categories = categories
                }
            }else if key == FilterType.sortBy.rawValue{
                if let sortBy = value as? Int {
                    self.searchSettings.sortBy = sortBy
                }
            }else if key == FilterType.distance.rawValue{
                if let distance = value as? Double {
                    self.searchSettings.distance = distance
                }
            }else if key == FilterType.deals.rawValue{
                if let hasDeals = value as? Bool{
                    self.searchSettings.isOfferingADeal = hasDeals
                }
            }
        }
        doSearchBySettings()
    }
    
    // MARK: Search bar methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchSettings.searchText = searchBar.text
        doSearchBySettings()
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        doSearchBySettings()
        self.searchBar.resignFirstResponder()
    }
    
    func doSearchBySettings(){
        var sortByYelp:YelpSortMode? = nil
        var distanceInMeters: Double? = nil
        if let sortBy = self.searchSettings.sortBy{
            sortByYelp = YelpSortMode(rawValue: sortBy)
        }
        if let miles = self.searchSettings.distance{
            if miles > 0{ // leave 0 miles as auto
                let result:Double = miles * 1609.34
                distanceInMeters = result
            }
        }
        Business.searchWithTerm(term: (self.searchSettings.searchText)!, sort: sortByYelp, categories: self.searchSettings.categories, distance: distanceInMeters, deals: self.searchSettings.isOfferingADeal){
            (businesses: [Business]?, error:Error?)->Void in
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
}
