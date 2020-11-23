//
//  ThirdViewController.swift
//  AR Ruler
//
//  Created by Rhea Mahesh on 7/20/18.
//  Copyright © 2018 Rhea Mahesh. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreML
import Vision
import VisualRecognition

class ThirdViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func cameraButton(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }

    fileprivate let apiKey = "Z320w7R1Qw1CSZODxiKkvuUBvRjbhf2cE3-pbHNHvmOV"
    fileprivate let version = "2019-04-09" // use today's date for the most recent version
    fileprivate var visualRecognition: VisualRecognition?

    fileprivate let classifierID = "HypothyroidismModel_134018882"
    fileprivate let failure = { (error: Error) in print(error) }

    fileprivate let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.lightGray
        visualRecognition = VisualRecognition(version: self.version, apiKey: apiKey)
        
        visualRecognition?.updateLocalModel(classifierID: classifierID, failure: failure) {
            print("model updated")
        }
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imagePicked = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.image = imagePicked
            visualRecognition?.classifyWithLocalModel(image: imagePicked, classifierIDs: [classifierID], failure: failure) { classifiedImages in
                self.firstIndex(classifiedImages: classifiedImages)
                  print(classifiedImages)
            }
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
  
    func firstIndex(classifiedImages: ClassifiedImages) {
        let className = classifiedImages.images.first?.classifiers.first?.classes.first?.className
        
        DispatchQueue.main.async {
            self.navigationItem.title = className
        }
    }
}

