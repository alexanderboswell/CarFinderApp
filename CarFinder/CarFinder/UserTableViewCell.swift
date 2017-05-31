//
//  UsersTableViewCell.swift
//  CarFinder
//
//  Created by alexander boswell on 5/25/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
