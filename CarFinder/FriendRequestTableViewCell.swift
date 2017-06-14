//
//  File.swift
//  CarFinder
//
//  Created by alexander boswell on 6/13/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import UIKit

class FriendRequestTableViewCell : UITableViewCell {
    
    // MARK: UI Elements
    
    @IBOutlet weak var nameTextField: UILabel!
    
    @IBOutlet weak var emailTextField: UILabel!
    
    @IBOutlet weak var button: UIButton!
    

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
