//
//  CameraViewController.swift
//  Travelers
//
//  Created by admin on 02/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit
import AVFoundation
class CameraViewController: UIViewController {
    
    @IBOutlet weak var removeButton: UIBarButtonItem!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    var selectedImage: UIImage?
    var videoURL: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //make the image view tapable
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectPhoto))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
    }
    
    //the user touched the screen to dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func handleSelectPhoto(){
        let pickerConbtroller = UIImagePickerController()
        //making the finished picking media available
        pickerConbtroller.delegate = self
        pickerConbtroller.mediaTypes = ["public.image", "public.movie"]
        
        present(pickerConbtroller, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handlePost()
    }
    
    //make the share button disabled and active
    func handlePost(){
        if selectedImage != nil{
            self.shareButton.isEnabled = true
            self.removeButton.isEnabled = true
            self.shareButton.backgroundColor = UIColor.black
        }else{
            self.shareButton.isEnabled = false
            self.removeButton.isEnabled = false
            self.shareButton.backgroundColor = UIColor.lightGray
        }
    }
    
    //touching the share button
    @IBAction func shareButton_TouchUpInside(_ sender: Any) {
        view.endEditing(true)
        ProgressHUD.show("Waiting...", interaction: false)
        
        //push the photo to the storage unit
        if let profileImag = self.selectedImage, let imageData = profileImag.jpegData(compressionQuality: 0.1) {
            let ratio = profileImag.size.width / profileImag.size.height
            HelperService.uploadDataToServer(data: imageData, videoURL: self.videoURL,ratio: ratio,caption: captionTextView.text!) {
                self.clean()
                self.tabBarController?.selectedIndex = 0
            }
        }else{
            ProgressHUD.showError("Profile Image can't be empty")
        }
    }
    @IBAction func remove_TouchUpInside(_ sender: Any) {
        clean()
        handlePost()
    }
    
    //clean all the data on the the upload method
    func clean(){
        self.captionTextView.text = ""
        self.photo.image = UIImage(named: "placeholder-photo")
        self.selectedImage = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Filter_Segue"{
            let filterVC = segue.destination as! FilterViewController
            filterVC.selectedImage = self.selectedImage
            filterVC.delegate = self
        }
    }
}
//make the picture above editable
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
            if let thumbnailImage = self.thumbnailImageForFileURL(videoURL){
                selectedImage = thumbnailImage
                photo.image = thumbnailImage
                self.videoURL = videoURL
            }
            dismiss(animated: true, completion: nil)
        }
        
        if let image = info[.originalImage] as? UIImage{
            selectedImage = image
            photo.image = image
            dismiss(animated: true) {
                self.performSegue(withIdentifier: "Filter_Segue", sender: nil)
            }
        }
    }
    
    //make a thumbnail photo for a givven url
    func thumbnailImageForFileURL(_ fileURL: URL) -> UIImage?{
        let asset = AVAsset(url: fileURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do{
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 6, timescale: 3), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        }catch let err{
            print(err)
        }
        return nil
    }
    
}
extension CameraViewController: FilterViewControllerDelegate{
    func updatePhoto(image: UIImage) {
        self.photo.image = image
        self.selectedImage = image
    }
    
    
}
