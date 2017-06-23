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
    
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    var buttonFunc: (() -> (Void))!
    
    // MARK: Overridden
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func buttonTapped(_ sender: UIButton) {
        buttonFunc()
    }
    func setFunction(_ function: @escaping () -> Void) {
        self.buttonFunc = function
    }
}
