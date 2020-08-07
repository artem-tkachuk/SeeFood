//
//  ViewController.swift
//  SeeFood
//
//  Created by Artem Tkachuk on 8/6/20.
//  Copyright © 2020 Artem Tkachuk. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    //MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true   //TODO extend the app
    }
    
    //MARK: - detect()
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML model failed")
        }
    
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process the image")
            }
        
            if let firstResults = results.first {
                if firstResults.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                    self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
                    self.navigationController?.navigationBar.barTintColor = UIColor.green
                } else {
                    self.navigationItem.title = "Not hotdog!"
                    self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
                    self.navigationController?.navigationBar.barTintColor = UIColor.red
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    //MARK: - cameraPressed()
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

//MARK: - UIImagePickerController
extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage")
            }
            
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}



