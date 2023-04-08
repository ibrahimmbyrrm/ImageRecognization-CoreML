//
//  ViewController.swift
//  ImageRecognixation-CoreML
//
//  Created by İbrahim Bayram on 8.04.2023.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var sonucLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func changeClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
        guard let ciImage = CIImage(image: imageView.image!) else {return}
        recognizeImage(image: ciImage)
    }
    
    func recognizeImage(image : CIImage) {
        // 1) Request
        // 2) Handler
        
        guard let model = try? VNCoreMLModel(for: MobileNetV2().model) else {return}
        let request = VNCoreMLRequest(model: model) { (vnRequest, error) in
            guard let results = vnRequest.results as? [VNClassificationObservation] else {return}
            let topResult = results.first
            DispatchQueue.main.async {
                let confidenceLevel = (topResult?.confidence ?? 0) * 100
                let rounded = Int(confidenceLevel * 100 / 100)
                self.sonucLabel.text = "\(rounded)% it is a \(topResult!.identifier)"
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            }catch {
                print(error)
            }
        }
       
        
    }
    

}

