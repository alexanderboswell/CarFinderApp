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
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var declineButton: UIButton!

    var buttonFunc: (() -> (Void))!
    
    var buttonFuncDecline: (() -> (Void))!
    
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
    @IBAction func declineButtonTapped(_ sender: UIButton) {
        buttonFuncDecline()
    }
    func setFunction(_ function: @escaping () -> Void) {
        self.buttonFunc = function
    }
    func setFunctionDecline(_ function: @escaping () -> Void) {
        self.buttonFuncDecline = function
    }
}
