//
//  Extensions+UIButton.swift
//  NYCParkLocator
//
//  Created by Leandro Wauters on 8/25/21.
//

import UIKit

extension UIButton {
    
    public func roundButton() {
        layer.cornerRadius =
        frame.height / 2
        clipsToBounds = true
    }
    
    public func addTextColor() {
        setTitleColor(Constants.categoryButtonSecondaryColor, for: .normal)
    }
    
    public func setupAsApplyButton() {
        backgroundColor = Constants.categoryButtonSecondaryColor
       setTitleColor(Constants.categoryButtonPrimaryColor, for: .normal)
    }

    public func enableButton() {
        isEnabled = true
        alpha = 1.0
    }
    
    public func disableButton() {
        isEnabled = false
        alpha = 0.5
    }
    
    public func setAsFilterButton(title: String, tag: Int) {
        isHidden = false
        self.tag = tag
        setTitle(title, for: .normal)
        backgroundColor = Constants.categoryButtonPrimaryColor
        setTitleColor(Constants.categoryButtonSecondaryColor, for: .normal)
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.font = UIFont.systemFont(ofSize: 13)
    }
    
    public func addCount(count: Int) {
        setTitle("Filter (\(count))", for: .normal)
        titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    public func removeCount() {
        setTitle("Filter", for: .normal)
    }
    public func didSelect() {
        backgroundColor = Constants.categoryButtonSecondaryColor
        setTitleColor(Constants.categoryButtonPrimaryColor, for: .normal)
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
    }
    
    public func didDeselect() {
        backgroundColor = Constants.categoryButtonPrimaryColor
        setTitleColor(Constants.categoryButtonSecondaryColor, for: .normal)
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
    }
}
