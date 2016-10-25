//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Ian Campelo on 10/24/16.
//  Copyright © 2016 Ian Campelo. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate{
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String: AnyObject] )
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FiltersViewControllerDelegate?
    
    let distance: [Float] = [0.3, 0.8, 2, 3, 5]
    let sortBy: [String] = ["BestMatched", "Distance", "HighestRated"]
    
    var categories: [[String:String]] = []
    var deals: Bool!
    var distanceStates: [Bool] = [false, false, false, false, false]
    var sortByStates: [Bool] = [false, false, false]
    var switchStates = [Int:Bool]()
    var categoriesShowAll: Bool!
    var sortByShowAll: Bool!
    var distanceShowAll: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let categs = Categories()
        categories = categs.yelpCategories()
        deals = false
        categoriesShowAll = false
        sortByShowAll = false
        distanceShowAll = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
    }
    
    @IBAction func onCancelButton(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearchButton(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        
        var filters = [String:AnyObject]()
        filters["deals"] = deals as AnyObject?
        for index in 0 ..< distance.count {
            if distanceStates[index] == true {
                filters["distance"] = distance[index] as AnyObject?
            }
        }
        for index in 0 ..< sortBy.count {
            if sortByStates[index] == true {
                filters["sortRawValue"] = index as AnyObject?
            }
        }
        var selectedCategories = [String]()
        for (row, isSelected) in switchStates {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject?
        }
        delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filters)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        switch(section) {
        case 0:
            return 1
        case 1:
            return distanceShowAll == true ? distance.count : 1
        case 2:
            return sortByShowAll == true ? sortBy.count : 1
        case 3:
            return categoriesShowAll == true ? categories.count + 1 : 4
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 0:
            return "Deal"
        case 1:
            return "Distance"
        case 2:
            return "Sort by"
        case 3:
            return "Categories"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchCell
        if indexPath.section == 0 {
            cell.switchLabel.text = "With a Deal"
            cell.delegate = self
            cell.onSwitch.isOn = deals ?? false
        } else if indexPath.section == 1 {
            if distanceShowAll == false && indexPath.row == 0 {
                let optionCell = tableView.dequeueReusableCell(withIdentifier: "OptionCell") as! SwitchCell
                optionCell.optionLabel.text = "None"
                for i in 0 ..< distance.count {
                    if distanceStates[i] == true {
                        optionCell.optionLabel.text = String(format: "%.1f mi", distance[i])
                    }
                }
                optionCell.optionImageView.image = UIImage(named: "dropdown")
                return optionCell
            }
            else {
                let optionCell = tableView.dequeueReusableCell(withIdentifier: "OptionCell") as! SwitchCell
                optionCell.optionLabel.text = String(format: "%.1f mi", distance[indexPath.row])
                optionCell.optionImageView.image = distanceStates[indexPath.row] ? UIImage(named: "checked") : UIImage(named: "unchecked")
                return optionCell
            }
        } else if indexPath.section == 2 {
            if sortByShowAll == false && indexPath.row == 0 {
                let optionCell = tableView.dequeueReusableCell(withIdentifier: "OptionCell") as! SwitchCell
                optionCell.optionLabel.text = "None"
                for i in 0 ..< sortBy.count {
                    if sortByStates[i] == true {
                        optionCell.optionLabel.text = sortBy[i]
                    }
                }
                optionCell.optionImageView.image = UIImage(named: "dropdown")
                return optionCell
            } else {
                let optionCell = tableView.dequeueReusableCell(withIdentifier: "OptionCell") as! SwitchCell
                optionCell.optionLabel.text = sortBy[indexPath.row]
                optionCell.optionImageView.image = sortByStates[indexPath.row] ? UIImage(named: "checked") : UIImage(named: "unchecked")
                return optionCell
            }
        } else if indexPath.section == 3 {
            if categoriesShowAll == false && indexPath.row == 3 {
                let showAllCell = tableView.dequeueReusableCell(withIdentifier: "ShowAllCell") as! SwitchCell
                return showAllCell
            } else {
                if indexPath.row == categories.count {
                    let showAllCell = tableView.dequeueReusableCell(withIdentifier: "ShowAllCell") as! SwitchCell
                    showAllCell.showAllLabel.text = "Collapse"
                    return showAllCell
                } else {
                    cell.switchLabel.text = categories[indexPath.row]["name"]
                    cell.delegate = self
                    cell.onSwitch.isOn = switchStates[indexPath.row] ?? false
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        switch(indexPath.section) {
        case 1:
            if distanceShowAll == false {
                distanceShowAll = true
                self.tableView.reloadSections(NSIndexSet(index: 1) as IndexSet, with: UITableViewRowAnimation.fade)
            } else {
                for i in 0 ..< distance.count {
                    if i == indexPath.row {
                        distanceStates[i] = distanceStates[i] ? false : true
                    } else {
                        distanceStates[i] = false
                    }
                }
                distanceShowAll = false
                self.tableView.reloadSections(NSIndexSet(index: 1) as IndexSet, with: UITableViewRowAnimation.fade)
            }
        case 2:
            if sortByShowAll == false {
                sortByShowAll = true
                self.tableView.reloadSections(NSIndexSet(index: 2) as IndexSet, with: UITableViewRowAnimation.fade)
            } else {
                for i in 0 ..< sortBy.count {
                    if i == indexPath.row {
                        sortByStates[i] = sortByStates[i] ? false : true
                    } else {
                        sortByStates[i] = false
                    }
                }
                sortByShowAll = false
                self.tableView.reloadSections(NSIndexSet(index: 2) as IndexSet, with: UITableViewRowAnimation.fade)
            }
        case 3:
            if indexPath.row == 3 && categoriesShowAll == false {
                categoriesShowAll = true
                self.tableView.reloadSections(NSIndexSet(index: 3) as IndexSet, with: UITableViewRowAnimation.automatic)
            } else if indexPath.row == categories.count {
                categoriesShowAll = false
                self.tableView.reloadSections(NSIndexSet(index: 3) as IndexSet, with: UITableViewRowAnimation.automatic)
            }
        default:
            print("Default.")
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)!
        if indexPath.section == 0 {
            deals = value
        } else if indexPath.section != 1 && indexPath.section != 2 {
            switchStates[indexPath.row] = value
        }
    }
    
}
