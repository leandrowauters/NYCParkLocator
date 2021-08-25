//
//  FilterViewController.swift
//  NYCParkLocator
//
//  Created by Leandro Wauters on 8/25/21.
//

import UIKit

protocol FilterDelegate: AnyObject {
    func didSelectCategories()
}

class FilterViewController: UIViewController {

    @IBOutlet var CategoryButtons: [UIButton]!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    
    var selectedCategories = [String]()
 
    weak var filterDelegate: FilterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCategoryButtons()
        setupButtons()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        applyButton.roundButton()
        setupCategoryButtons()
    }
    private func setupButtons() {
        resetButton.addTextColor()
        cancelButton.addTextColor()
        applyButton.setupAsApplyButton()
//        if selectedCategories.count == 0 {
//            applyButton.disableButton()
//        } else {
//            applyButton.enableButton()
//        }
    }
    
    private func setupCategoryButtons() {
        
        for i in 0...Park.parksTypesToFilter.count - 1 {
            let category = Park.parksTypesToFilter[i]
            let button = CategoryButtons[i]
            button.setAsFilterButton(title: category, tag: i)
            if selectedCategories.contains(button.currentTitle ?? String()) {
                button.didSelect()
            }
        }
    }
    
    @IBAction func categoryButtonPressed(_ sender: UIButton) {
        let category = Park.parksTypesToFilter[sender.tag]

        if selectedCategories.contains(category) {
            selectedCategories.removeAll(where: {$0 == category})
            sender.didDeselect()
        } else {
            print(sender.tag)
            print(category)
            selectedCategories.append(category)
            for button in CategoryButtons {
                if button == sender {
                    button.didSelect()
                }
                
            }
        }
        print("Number of Categories:  \(selectedCategories.count)")
//        if selectedCategories.count == 0 {
//            applyButton.disableButton()
//        } else {
//            applyButton.enableButton()
//        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
     dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        selectedCategories.removeAll()
        setupCategoryButtons()
    }
    @IBAction func didSelectApply(_ sender: Any) {
        
            UserDefaultsHelper.saveFilterCategories(categories: selectedCategories)
            print("SAVE CATEGORIE FILTER: \(selectedCategories)")
        
        filterDelegate?.didSelectCategories()
        dismiss(animated: true, completion: nil)
    }
    
}

