//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        setLoggedIn(true)
        TMDBClient.createRequestToken(completion: handleRequestTokenResponse(success:error:))
    }
    
    @IBAction func loginViaWebsiteTapped() {
        setLoggedIn(true)
        TMDBClient.createRequestToken { (success, error) in
            if success {
                    UIApplication.shared.open(TMDBClient.Endpoints.webAuth.url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func handleRequestTokenResponse(success: Bool, error: Error?){
        if success {
            TMDBClient.login(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: self.handleLoginResponse(success:error:))
        } else {
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    func handleSessionResponse(success: Bool, error: Error?){ 
        setLoggedIn(false)
        if success {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "completeLogin", sender: nil)
            }
        }
    }
    
    func handleLoginResponse(success: Bool, error: Error?) {
        setLoggedIn(false)
        if success {
            TMDBClient.createSessionId(completion: handleSessionResponse(success:error:))
        }else {
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    func setLoggedIn(_ loggedIn: Bool) {
        if loggedIn {
            activityIndicator.startAnimating()
        }else {
            activityIndicator.stopAnimating()
        }
        
        emailTextField.isEnabled = !loggedIn
        passwordTextField.isEnabled = !loggedIn
        loginButton.isEnabled = !loggedIn
        loginViaWebsiteButton.isEnabled = !loggedIn
    }
    
    func showLoginFailure(message: String) {
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
}
