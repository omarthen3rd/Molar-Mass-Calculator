//
//  ViewController.swift
//  PTable
//
//  Created by Omar Abbasi on 2016-11-27.
//  Copyright © 2016 Omar Abbasi. All rights reserved.
//

import UIKit
import SwiftyJSON
import Spring

extension Double {
    
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    let reuseIdentifier = "cell"
    var elements = [Element]()
    var filteredElements = [Element]()
    var listOfNumbers = [Double]()
    var tapCount = 0
    var selectedRow = 0
    var newSelected = 0
    var searchController = UISearchController(searchResultsController: nil)
    
    var stringElements = [Character]()
    var elementsCount: [Character:Int] = [:]
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBarPlaceholder: UIView!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var countSpring: SpringLabel!
    @IBAction func clearButton(_ sender: Any) {
        
        listOfNumbers.removeAll()
        tapCount = 0
        countLabel.text = ""
        sumLabel.text = "0.0"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        getElements()
        readElements("H20")
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchBarPlaceholder.addSubview(searchController.searchBar)
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true

    }
    
    func getElements() {
        
        let filePath = Bundle.main.path(forResource: "pt", ofType: "json")
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        let json = JSON(data: jsonData!)
        
        let unsorted = json["PERIODIC_TABLE"]["ATOM"].array!
        let sorted = unsorted.sorted { $0["ATOMIC_NUMBER"].doubleValue < $1["ATOMIC_NUMBER"].doubleValue }
        for anElement in sorted {
            
            let atomicNumber = anElement["ATOMIC_NUMBER"].stringValue
            let roundedWeight = Double(anElement["ATOMIC_WEIGHT"].doubleValue).roundTo(places: 2)
            let newElement : Element = Element(name: anElement["SYMBOL"].stringValue, fullName: anElement["NAME"].stringValue, atomicMass: String(roundedWeight), number: atomicNumber)
            elements.append(newElement)
            
        }
    }
    
    func readElements(_ string: String) {
        
        var letters = CharacterSet.letters
        
        for element in string.characters {
            
        }
        
        for item in stringElements {
            
            elementsCount[item] = (elementsCount[item] ?? 0) + 1
            
        }
        
        print(elementsCount)
        
    }
    
    func filterContentForSearchText(searchText: String) {
        
        filteredElements = elements.filter({ (Element) -> Bool in
            return Element.fullName.lowercased().contains(searchText.lowercased())
        })
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if searchController.isActive {
            return self.filteredElements.count
        }
        
        return self.elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        let object : Element
        
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        
        if searchController.isActive {
            object = filteredElements[indexPath.row]
        } else {
            object = elements[indexPath.row]
        }
        
        cell.numberLabel.text = object.number
        cell.symbolLabel.text = object.name
        cell.massLabel.text = object.atomicMass
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        
        newSelected = indexPath.row
        
        if newSelected == selectedRow {
            
            selectedRow = newSelected
            tapCount += 1
            countLabel.text = cell.symbolLabel.text! + " - " + "\(tapCount)"
            
        } else if newSelected != selectedRow && tapCount > 0 {
            
            tapCount = 0
            tapCount += 1
            selectedRow = newSelected
            countLabel.text = cell.symbolLabel.text! + " - " + "\(tapCount)"
            
        } else {
            
            selectedRow = newSelected
            tapCount += 1
            countLabel.text = cell.symbolLabel.text! + " - " + "\(tapCount)"
            
        }
        
        let number = Double(cell.massLabel.text!)
        listOfNumbers.append(number!)
        let sum = listOfNumbers.reduce(0, +)
        sumLabel.text = String(Double(sum).roundTo(places: 2))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

}

extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
