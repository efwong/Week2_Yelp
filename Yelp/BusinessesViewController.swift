//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate, UISearchBarDelegate,UIScrollViewDelegate, NVActivityIndicatorViewable {
    
    var searchBar: UISearchBar!
    var businesses: [Business]!
    var searchSettings: SearchFilterSettings = SearchFilterSettings()
    var currentPage: Int = 1
    var businessCountIncrement:Int = 20 // how many businesses to fetch each time
    var totalBusinessCount: Int = 10
    var loadingView: NVActivityIndicatorView?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    // Keep track of data loading for infinite scroll
    var isMoreDataLoading = false
    
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
        
        self.searchSettings.searchText = ""
        self.searchSettings.distance = 0 //auto
        self.searchSettings.sortBy = 0 // Best Matched
        doSearchBySettings(page: 1)
        
        // add footer to table view for infinite scroll
        self.loadingView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), type: NVActivityIndicatorType.ballPulse, color: Helper.globalRed)
        self.tableView.tableFooterView = loadingView
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
        }else if segue.identifier == "toBusinessDetail"{
            // triggered by tapping business cell
            if let businessCell = sender as? BusinessCell{
                if let detailsVC = segue.destination as? BusinessDetailViewController{
                    detailsVC.business = businessCell.business
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
        doSearchBySettings(page: 1)
    }
    
    // MARK: Search bar methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchSettings.searchText = searchBar.text
        doSearchBySettings(page: 1) // reset search to page 1
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchSettings.searchText = ""
        doSearchBySettings(page: 1) // reset search to page 1
        self.searchBar.resignFirstResponder()
    }
    
    // Page == 1 signifies resetting paging
    // Will save self.currentPage =1
    func doSearchBySettings(page:Int){
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
        let offset = getOffset(page: page)
        // only fetch more when the page's offset is less than the total # of businesses or if doReset is true
        if offset < self.totalBusinessCount || page == 1 {
            if page > 1{
                // only show scrolling loading animation on > first page
                self.loadingView?.startAnimating()
            }else{
                self.showUILoadingBlocker() // show ui blocker
            }
            Business.searchWithTerm(term: (self.searchSettings.searchText)!, sort: sortByYelp, categories: self.searchSettings.categories, distance: distanceInMeters, deals: self.searchSettings.isOfferingADeal, limit: self.businessCountIncrement, offset: offset){
                (businesses: [Business]?, total: Int, error:Error?)->Void in
                if page <= 1{
                    self.businesses = businesses
                    self.stopAnimating() // hide ui blocker
                }else{
                    if let bussinessArr = businesses{
                        self.businesses?.append(contentsOf: bussinessArr)
                    }
                    // only show scrolling loading animation on > first page
                    self.loadingView?.stopAnimating()
                }
                self.totalBusinessCount = total
                self.currentPage = page
                self.isMoreDataLoading = false
                
                self.tableView.reloadData()
            }
        }
    }
    
    // Get # of businesses up to current page
    // eg. page 1-> 0, page 2-> 20
    func getOffset(page: Int) -> Int{
        return (page-1)*self.businessCountIncrement
    }
    
    // MARK: Infinite Scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                
                isMoreDataLoading = true
                
                // Code to load more results
                doSearchBySettings(page: self.currentPage+1)
            }
        }
    }
    
    // MARK: UI BLOCKER
    // Show UIBlocker when waiting for network
    func showUILoadingBlocker(){
        self.startAnimating(CGSize(width: 100, height: 100), message: nil, type: NVActivityIndicatorType.ballRotateChase, color: UIColor.white, minimumDisplayTime: 500)
    }
}
