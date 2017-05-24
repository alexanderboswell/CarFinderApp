//
//  PinTableViewCell.swift
//  CarFinder
//
//  Created by alexander boswell on 5/23/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import UIKit

class PinTableViewCell : UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
