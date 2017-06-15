//
//  FriendTableViewCell.swift
//  CarFinder
//
//  Created by alexander boswell on 6/15/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import UIKit

class FriendTableViewCell : UITableViewCell {
    
    @IBOutlet weak var nameTextField: UILabel!
    
    @IBOutlet weak var emailTextField: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
