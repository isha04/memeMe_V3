//
//  ViewController.swift
//  memeMe_V3.0
//
//  Created by amarjeet on 23/12/17.
//  Copyright © 2017 amarjeet. All rights reserved.
//

import UIKit


class memeCreate: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var images = [UIImage]()
    var titles: [String]!
    var imagesDirectoryPath: String!
    
    var selectedTextField: UITextField?
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    
    func getImages() {
        images = []
        // Create a new path for the new images folder
        imagesDirectoryPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(imagePicker)")
        var objcBool:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: imagesDirectoryPath!, isDirectory: &objcBool)
        // If the folder with the given path doesn't exist already, create it
        if isExist == false{
            do{
                try FileManager.default.createDirectory(atPath: imagesDirectoryPath!, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Something went wrong while creating a new folder")
            }
        }
        print("imagesdirectory path is:: \(imagesDirectoryPath)")
    }

    
    let memeTextAttributes:[String:Any] = [
        NSAttributedStringKey.strokeColor.rawValue:  UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.gray,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -5]
    
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topText.defaultTextAttributes = memeTextAttributes
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        topText.textAlignment = .center
        bottomText.defaultTextAttributes = memeTextAttributes
        bottomText.textAlignment = .center
        topText.delegate = self
        bottomText.delegate = self
        shareButton.isEnabled = false
        getImages()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    
    @IBAction func cameraClick(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        shareButton.isEnabled = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func galleryClick(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func tappedOnCancel(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        shareButton.isEnabled = true
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photo.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func generateMemedImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return memedImage
    }
    
    
    func saveImage(photo: UIImage) {
        var imageName = (NSDate().description).replacingOccurrences(of: " ", with: "")
        imageName = (imageName as NSString).appendingPathComponent("/\(imageName).png")
        let imagePath = imagesDirectoryPath + imageName
        let data = UIImagePNGRepresentation(photo)
        let success = FileManager.default.createFile(atPath: imagePath, contents: data, attributes: nil)
        self.refreshTable()
        print("imageName is:::: \(imageName)")
        print("success is \(success)")
    }
    
    func refreshTable(){
        do{
            images.removeAll()
            titles = try FileManager.default.contentsOfDirectory(atPath: imagesDirectoryPath)
            for image in titles{
                let data = FileManager.default.contents(atPath: (imagesDirectoryPath as NSString).appendingPathComponent("/\(image)"))
                let image = UIImage(data: data!)
                images.append(image!)
            }
            tableViewController().tableView.reloadData()
        }catch{
            print("Error")
        }
    }
    
    
    @IBAction func sharePhoto(_ sender: Any) {
        let memeToShare = generateMemedImage()
        let activity = UIActivityViewController(activityItems: [memeToShare], applicationActivities: nil)
        activity.completionWithItemsHandler = { (activity, success, items, error) in
            
            if success {
                self.saveImage(photo: memeToShare)
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        present(activity, animated: true, completion:nil)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextField = textField
        if selectedTextField?.text == "TOP" || selectedTextField?.text == "BOTTOM" {
            selectedTextField?.text = ""
        }
        textField.becomeFirstResponder()
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == topText && textField.text! == "" {
            textField.text = "TOP"
        }
        if textField == bottomText && textField.text! == "" {
            textField.text = "BOTTOM"
        }
    }
    
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    
    
    @objc func keyboardWillDisappear(_ notification:Notification) {
        self.view.frame.origin.y = 0
    }
    
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if selectedTextField == bottomText {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    
    
}

