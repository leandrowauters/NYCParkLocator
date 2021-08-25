//
//  FilterViewController.swift
//  NYCParkLocator
//
//  Created by Leandro Wauters on 8/25/21.
//

import UIKit

protocol FilterDelegate: AnyObject {
    func didSelectCategories(categories: [String])
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
        applyButton.layer.cornerRadius = applyButton.frame.height / 2
        applyButton.clipsToBounds = true
    }
    private func setupButtons() {
        resetButton.setTitleColor(Constants.categoryButtonSecondaryColor, for: .normal)
        cancelButton.setTitleColor(Constants.categoryButtonSecondaryColor, for: .normal)
        applyButton.backgroundColor = Constants.categoryButtonSecondaryColor
        applyButton.setTitleColor(Constants.categoryButtonPrimaryColor, for: .normal)
        if selectedCategories.count == 0 {
            applyButton.isEnabled = false
            applyButton.alpha = 0.5
        } else {
            applyButton.isEnabled = true
            applyButton.alpha = 1.0
        }
    }
    private func setupCategoryButtons() {
        for i in 0...Park.parksTypesToFilter.count - 1 {
            let category = Park.parksTypesToFilter[i]
            let button = CategoryButtons[i]
            button.isHidden = false
            button.tag = i
            button.setTitle(category, for: .normal)
            button.backgroundColor = Constants.categoryButtonPrimaryColor
            button.setTitleColor(Constants.categoryButtonSecondaryColor, for: .normal)

        }
    }
    
    @IBAction func categoryButtonPressed(_ sender: UIButton) {
        let category = Park.parksTypesToFilter[sender.tag]

        if selectedCategories.contains(category) {
            selectedCategories.removeAll(where: {$0 == category})
            sender.backgroundColor = Constants.categoryButtonPrimaryColor
            sender.setTitleColor(Constants.categoryButtonSecondaryColor, for: .normal)
            sender.layer.cornerRadius = sender.frame.height / 2
            sender.clipsToBounds = true
            
        } else {
            print(sender.tag)
            print(category)
            selectedCategories.append(category)
            for button in CategoryButtons {
                if button == sender {
                    //NOT SELECTED
                    button.backgroundColor = Constants.categoryButtonSecondaryColor
                    button.setTitleColor(Constants.categoryButtonPrimaryColor, for: .normal)
                    button.layer.cornerRadius = button.frame.height / 2
                    button.clipsToBounds = true
                }
                
            }
        }
        print("Number of Categories:  \(selectedCategories.count)")
        if selectedCategories.count == 0 {
            applyButton.isEnabled = false
            applyButton.alpha = 0.5
        } else {
            applyButton.isEnabled = true
            applyButton.alpha = 1.0
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
     dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        selectedCategories.removeAll()
    }
    @IBAction func didSelectApply(_ sender: Any) {
        filterDelegate?.didSelectCategories(categories: selectedCategories)
    }
    
}

