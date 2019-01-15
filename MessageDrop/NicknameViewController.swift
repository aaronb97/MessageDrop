//
//  NicknameViewController.swift
//  MessageDrop
//
//  Created by Aaron Becker on 1/14/19.
//  Copyright © 2019 Aaron Becker. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class NicknameViewController: UIViewController {
    
    var nicknameTextField : UITextField!
    var submitButton : UIButton!
    let ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        nicknameTextField = UITextField()
        submitButton = UIButton()
        
        nicknameTextField.frame.size = CGSize(width: 200, height: 30)
        nicknameTextField.frame.origin = CGPoint(x: 20, y: 40)
        nicknameTextField.becomeFirstResponder()
        
        submitButton.setTitle("This will be my nickname.", for: .normal)
        submitButton.frame.size = CGSize(width: 200, height: 30)
        submitButton.frame.origin = CGPoint(x: 20, y: nicknameTextField.frame.origin.y + 20)
        submitButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        submitButton.setTitleColor(UIColor.blue, for: .normal)
        
        nicknameTextField.isHidden = false
        submitButton.isHidden = false
        
        self.view.addSubview(nicknameTextField)
        self.view.addSubview(submitButton)
        // Do any additional setup after loading the view.
    }
    
    @objc func buttonAction(sender: UIButton!) {
        if ((nicknameTextField.text?.count)! > 0 && (nicknameTextField.text?.count)! < 20)
        {
            let email = Auth.auth().currentUser?.email?.replacingOccurrences(of: ".", with: ",")
            ref.child("users").child(email!).setValue(["nickname": nicknameTextField.text!])
            
            let mapViewController = MapViewController()
            present(mapViewController, animated: true, completion: nil)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
