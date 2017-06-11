//
//  UserTableViewCell.swift
//  CarFinder
//
//  Created by alexander boswell on 6/10/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import UIKit

class UserTableViewCell : UITableViewCell {
    
    // MARK: UI Elements
    @IBOutlet weak var nameTextField: UILabel!
    
    @IBOutlet weak var emailTextField: UILabel!
    
    // MARK: Overridden
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
