//
//  SwitchCell.swift
//  Yelp
//
//  Created by Ian Campelo on 10/24/16.
//  Copyright © 2016 Ian Campelo. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate{
    @objc optional func switchCell(switchCell: SwitchCell, didChangeValue: Bool)
}

class SwitchCell: UITableViewCell {
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var optionImageView: UIImageView!
    @IBOutlet weak var showAllLabel: UILabel!
    
    weak var delegate: SwitchCellDelegate?
    
    var onChecked = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func switchValueChanged(sender: AnyObject) {
        delegate?.switchCell?(switchCell: self, didChangeValue: onSwitch.isOn)
    }
}
