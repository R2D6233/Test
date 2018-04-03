//
//  ViewController.swift
//  Test Project
//
//  Created by Admin on 03.04.18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import CoreData
import Photos
import PhotosUI

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
    
    var managedObjectContext:NSManagedObjectContext!
    let imagePickerController = UIImagePickerController()
    var image:UIImage!
    var date:Date!
    
    @IBOutlet weak var chooseButtonOutlet: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        nameTextField.delegate = self
        descriptionTextField.delegate = self
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil) { (nc) in
            self.view.frame.origin.y = -200
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil) { (nc) in
            self.view.frame.origin.y = 0
        }
        
        self.view.setGradientBackground(colorOne: UIColor(red: 84/255, green: 150/255,  blue: 255/255, alpha: 1), colorTwo: UIColor(red: 135/255, green: 57/255, blue: 229/255, alpha: 1))
        
        chooseButtonOutlet.layer.borderWidth = 1
        chooseButtonOutlet.layer.borderColor = UIColor.white.cgColor
        chooseButtonOutlet.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    @IBAction func chooseImageButton(_ sender: UIButton) {
        
        let actionSheet = UIAlertController(title: "Photo source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            } else {
                print("Camera not available")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        /*if let asset = info[UIImagePickerControllerPHAsset] as? PHAsset, let creationDate = asset.creationDate {
            print(String(creationDate.timeIntervalSinceNow.description))
            self.date = creationDate
        }*/
        
        if let assetURL = info[UIImagePickerControllerReferenceURL] as? URL {
            let asset = PHAsset.fetchAssets(withALAssetURLs: [(assetURL as URL)], options: nil)
            if let result = asset.firstObject {
                self.date = result.creationDate
                print(date)
            }
        }
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: true, completion: {
                self.photoImageView.image = image
                self.image = image
            })
            print("imageer")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        
        if nameTextField.text != "" && descriptionTextField.text != "" && image != nil {
            let presentItem = Present(context: managedObjectContext)
            presentItem.name = nameTextField.text
            presentItem.title = descriptionTextField.text
            presentItem.date = date as Date
            presentItem.image = NSData(data: UIImagePNGRepresentation(image)!) as Data
            
            do {
                try self.managedObjectContext.save()
                self.navigationController?.popToRootViewController(animated: true)
            } catch {
                print(error)
            }
        } else {
            let alert = UIAlertController(title: "Message", message: "Choose a photo and fill in all the fields!!!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength: Int = (textField.text?.count ?? 0) + string.count - range.length
        return (newLength > 30) ? false : true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
        return true
    }
    
}
