//
//  ViewController.swift
//  BackendCaseStudies
//
//  Created by Isabel  Lee on 14/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ViewController: UIViewController {

    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["email", "user_friends", "read_custom_friendlists"]
    }

}

extension ViewController: FBSDKLoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logged out")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print("Some error occured: \(error)")
        } else {
            print("Logged in")
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, taggable_friends"]).start { (connection, result, err) in
                
                if err != nil {
                    print("Failed to start graph request:", err ?? "Unknown Error")
                    return
                }
                //print(result ?? "No results")
                let parsedResults = result as! [String: Any]
                let data = parsedResults["taggable_friends"] as! [String:Any]
                let friends = data["data"] as! [Any]
                for friend in friends{
                    let friendInfo = friend as! [String:Any]
                    print(friendInfo["name"]!)
                }
                
                let paging = data["paging"]! as? [String:Any]
                let cursors = paging?["cursors"] as? [String:Any]
                let nextCursor = cursors?["after"] as? String
                
                if let nextCursor = nextCursor
                {
                    print("Going on to the next page")
                    self.nextPage(cursor: nextCursor)
                }
            }
        }
    }
    
    func nextPage(cursor: String) {
        let new = "/me/taggable_friends?limit=25&after=" + cursor
        
        FBSDKGraphRequest(graphPath: new, parameters: [:]).start { (connection, result, err) in
            
            if err != nil {
                print("Failed to start graph request:", err ?? "Unknown Error")
                return
            }
            //print(result ?? "No results")
            let data = result as! [String: Any]
            let friends = data["data"] as! [Any]
            for friend in friends{
                let friendInfo = friend as! [String:Any]
                print(friendInfo["name"]!)
            }
        }
    }
}


