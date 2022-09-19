//
//  ViewController.swift
//  hotdog-nothotdog-ios
//
//  Created by robertsimoes on 9/19/22.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func cameraClicked(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        imageView.image = img
        
        guard let ciImage = CIImage(image: img!) else { fatalError("failed to convert ci image") }
        
        detect(image: ciImage)
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else { fatalError("failed to create model")}
        
        let req = VNCoreMLRequest(model: model) { (request, error) in
            guard let res = request.results as? [VNClassificationObservation] else {
                fatalError("model failed to proc error")
            }
            
            if let firstRes = res.first {
                if firstRes.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                    self.navigationItem.titleView?.tintColor = .green
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                    self.navigationItem.titleView?.tintColor = .red
                }
            }
            
            print(res)
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([req])
        } catch {
            print(error)
        }
    }
}
