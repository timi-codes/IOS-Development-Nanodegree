//
//  ViewController.swift
//  MemeMe
//
//  Created by Timi Tejumola on 18/03/2020.
//  Copyright © 2020 Timi Tejumola. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var shareToolBar: UIToolbar!
    @IBOutlet weak var imagePickerToolBar: UIToolbar!
    
    var memedImage: UIImage?
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 30)!,
        NSAttributedString.Key.strokeWidth: -5,
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        
        topTextField.borderStyle = .none
        bottomTextField.borderStyle = .none

        topTextField.delegate = self
        bottomTextField.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotification()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = false

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    @IBAction func pickAnImageAlbum(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let cameraController = UIImagePickerController()
        cameraController.delegate = self
        cameraController.sourceType = .camera
        present(cameraController, animated: true, completion: nil)
    }
    
    @IBAction func sharePressed(_ sender: Any) {
        let meme = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            self.memedImage = meme
            self.save()
        }
        present(activityViewController, animated: true)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }

    func subscribeToKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func save() {
        _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage!)
    }
    
    func generateMemedImage() -> UIImage {
        shareToolBar.isHidden = true
        imagePickerToolBar.isHidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        shareToolBar.isHidden = false
        imagePickerToolBar.isHidden = false

        return memedImage
    }
}


extension ViewController : UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            imagePickerView.image = image
            imagePickerView.contentMode = .scaleToFill
            shareButton.isEnabled = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if topTextField.text!.isEmpty {
            topTextField.text = "TOP"
        }else if bottomTextField.text!.isEmpty {
            bottomTextField.text = "BOTTOM"
        }
        return true
    }
}

