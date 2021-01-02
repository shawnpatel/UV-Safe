//
//  UVVisionViewController.swift
//  UV Safe
//
//  Created by Shawn Patel on 11/18/17.
//  Copyright © 2017 Shawn Patel. All rights reserved.
//

import UIKit
import CoreML
import Vision

class UVVisionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var infoStack: UIStackView!
    @IBOutlet weak var skinCancer: UIButton!
    @IBOutlet weak var riskLevel: UILabel!
    @IBOutlet weak var aboutButton: UIBarButtonItem!
    
    let activityView = UIActivityIndicatorView(style: .large)
    
    var request: VNCoreMLRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.overrideUserInterfaceStyle = .dark
        
        riskLevel.isHidden = true
        
        skinCancer.layer.cornerRadius = 10
        skinCancer.layer.borderWidth = 2
        skinCancer.layer.borderColor = UIColor.white.cgColor
        skinCancer.backgroundColor = Constants.UV_SAFE_YELLOW
        skinCancer.setTitleColor(Constants.UV_SAFE_RED, for: .normal)
        
        activityView.center = self.infoStack.center
        activityView.isHidden = true
        activityView.hidesWhenStopped = true
        activityView.backgroundColor = UIColor.black
        activityView.layer.cornerRadius = 20
        self.view.addSubview(activityView)
        
        self.skinCancer.titleLabel?.numberOfLines = 1
        self.skinCancer.titleLabel?.adjustsFontSizeToFitWidth = true
        self.skinCancer.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhoto(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        activityView.isHidden = false
        activityView.startAnimating()
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            logoImageView.isHidden = true
            infoStack.isHidden = true
            imageView.isHidden = false
            
            imageView.image = pickedImage
            
            detect2(image: CIImage(image: pickedImage)!)
            
            /*let fileManager = FileManager.default
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            let imagePath = documentsPath?.appendingPathComponent("image.jpg")
            
            try! UIImageJPEGRepresentation(pickedImage, 0.3)?.write(to: imagePath!)
            
            randomNumber = Int(arc4random_uniform(UINT32_MAX))
            
            let storageRef = Storage.storage().reference()
            let imageRef = storageRef.child("image" + String(randomNumber) + ".jpg")
            
            // Upload Image
            let uploadTask = imageRef.putFile(from: imagePath!, metadata: nil) { metadata, error in
                if let error = error {
                    print(error)
                } else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    let downloadURL = metadata!.downloadURL()
                    self.downloadPath = downloadURL
                    
                    // Run Visual Recognition
                    self.customVision()
                }
            }
            
            uploadTask.observe(.progress) { snapshot in
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                self.progressBar.progress = Float(percentComplete)
            }*/
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: SkinCancerClassifier().model) else {
            fatalError("Can't load SkinCancerClassifier model.")
        }
        
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                    fatalError("Unexpected result type from VNCoreMLRequest.")
            }
            
            DispatchQueue.main.async { [weak self] in
                UserDefaults.standard.set(topResult.confidence, forKey: "percentage")
                UserDefaults.standard.set(topResult.identifier, forKey: "tag")
                
                if topResult.confidence <= 0.33 {
                    self?.skinCancer.setTitle("Low Risk", for: .normal)
                } else if topResult.confidence >= 0.90 {
                    self?.skinCancer.setTitle("High Risk", for: .normal)
                } else {
                    self?.skinCancer.setTitle("Medium Risk", for: .normal)
                }
                
                self?.activityView.stopAnimating()
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
    func detect2(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: SkinCancerClassifier2().model) else {
            fatalError("Can't load SkinCancerClassifier2 model.")
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                    fatalError("Unexpected result type from VNCoreMLRequest.")
            }
            
            DispatchQueue.main.async { [weak self] in
                UserDefaults.standard.set(topResult.confidence, forKey: "percentage")
                UserDefaults.standard.set(topResult.identifier, forKey: "tag")
                
                if topResult.identifier == "Benign" {
                    self?.skinCancer.setTitle("Low Risk", for: .normal)
                } else if topResult.identifier == "Malignant" {
                    if topResult.confidence >= 0.85 {
                        self?.skinCancer.setTitle("High Risk", for: .normal)
                    } else if topResult.confidence >= 0.50 {
                        self?.skinCancer.setTitle("Medium Risk", for: .normal)
                    } else {
                        self?.skinCancer.setTitle("Low Risk", for: .normal)
                    }
                }
                
                self?.activityView.stopAnimating()
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
    /*func customVision() {
        if credits >= 1 {
            credits -= 1
            UserDefaults.standard.set(credits, forKey: "credits")
            DispatchQueue.main.async {
                self.scans.setTitle("Scans: " + String(self.credits), for: .normal)
            }
            
            let parameters: Parameters = [
                "Url": String(describing: downloadPath!)
            ]
        
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "Prediction-key": "05389f3819aa4f79ab153d8ea89fc6f3"
            ]
        
            let url = "https://southcentralus.api.cognitive.microsoft.com/customvision/v1.0/Prediction/99fc16ad-1867-42fe-9480-ac653e2f4387/url"
        
            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.data != nil {
                    do {
                        let json = try JSON(data: response.data!)
                        let tag = json["Predictions"][0]["Tag"].string
                        let probability = json["Predictions"][0]["Probability"].double
                        UserDefaults.standard.set(tag, forKey: "tag")
                        UserDefaults.standard.set(probability!, forKey: "percentage")
                        
                        DispatchQueue.main.async {
                            self.skinCancer.setTitle(String(Int(probability! * 100)) + "% " + tag! + "*", for: .normal)
                            
                            if probability! <= 0.25 {
                                self.riskLevel.text = "Minimal Risk!*"
                            } else if probability! <= 0.50 {
                                self.riskLevel.text = "Medium Risk!*"
                            } else if probability! <= 0.75 {
                                self.riskLevel.text = "High Risk!*"
                            } else {
                                self.riskLevel.text = "Very High Risk!*"
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
                self.deleteImage()
            }
        } else {
            let alertController = UIAlertController(title: "Not Enough Credits!", message: "Please get more credits in order to scan your skin!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            self.deleteImage()
        }
    }*/
    
    /*func watsonVisualRecognition() {
        if credits >= 1 {
            credits -= 1
            UserDefaults.standard.set(credits, forKey: "credits")
            DispatchQueue.main.async {
                self.scans.setTitle("Scans: " + String(self.credits), for: .normal)
            }
            
            let url = URL(string: "https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classify?api_key=" + apiKey + "&url=" + String(describing: downloadPath!) + "&classifier_ids=SkinCancer_1770798045" + "&version=" + version)
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                if error != nil {
                    print("Check internet connection!")
                } else {
                    if let content = data {
                        do {
                            let myJSON = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                            
                            if let images = myJSON["images"] as? NSArray {
                                if let innerImages = images[0] as? NSDictionary {
                                    if let classifiers = innerImages["classifiers"] as? NSArray {
                                        if classifiers.count > 0 {
                                            if let innerClassifiers = classifiers[0] as? NSDictionary {
                                                if let classes = innerClassifiers["classes"] as? NSArray {
                                                    if let innerClasses = classes[0] as? NSDictionary {
                                                        if let className = innerClasses["class"] as? String {
                                                            if let score = innerClasses["score"] as? NSNumber {
                                                                let percentage = String(format: "%.0f", Float(truncating: score) * 100)
                                                                UserDefaults.standard.set(Float(truncating: score), forKey: "percentage")
                                                                UserDefaults.standard.set(className, forKey: "className")
                                                                DispatchQueue.main.async {
                                                                    self.skinCancer.setTitle(percentage + "% " + className + "*", for: .normal)
                                                                    
                                                                    if Float(truncating: score) <= 0.25 {
                                                                        self.riskLevel.text = "Minimal Risk!*"
                                                                    } else if Float(truncating: score) <= 0.50 {
                                                                        self.riskLevel.text = "Medium Risk!*"
                                                                    } else if Float(truncating: score) <= 0.75 {
                                                                        self.riskLevel.text = "High Risk!*"
                                                                    } else {
                                                                        self.riskLevel.text = "Very High Risk!*"
                                                                    }
                                                                }
                                                                self.deleteImage()
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            DispatchQueue.main.async {
                                                self.skinCancer.setTitle("No Match!*", for: .normal)
                                                self.riskLevel.text = "No Risk!*"
                                                
                                                UserDefaults.standard.removeObject(forKey: "percentage")
                                                UserDefaults.standard.removeObject(forKey: "className")
                                            }
                                            self.deleteImage()
                                        }
                                    }
                                }
                            }
                        } catch {
                            return
                        }
                    }
                }
            }
            task.resume()
        } else {
            let alertController = UIAlertController(title: "Not Enough Credits!", message: "Please get more credits in order to scan your skin!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            self.deleteImage()
        }
    }*/
    
    @IBAction func skinCancerButton(_ sender: UIButton) {
        if skinCancer.currentTitle != "Match*" {
            let alertController = UIAlertController(title: "Continue to Cancer.org?", message: "Learn about skin cancer along with diagnosis and treatment options.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.open(url: "https://www.cancer.org/cancer/skin-cancer.html")
            }))
            self.present(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Scan your skin!", message: "You have to scan your skin to access the analysis.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func open(url: String) {
        if let url = NSURL(string: url) {
            UIApplication.shared.open(url as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
    
    /*func deleteImage() {
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("image" + String(randomNumber) + ".jpg")
        
        imageRef.delete { error in
            if let error = error {
                print(error)
            }
        }
    }*/
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
