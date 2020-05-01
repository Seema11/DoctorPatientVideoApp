//
//  ImagePicker.swift
//  bogo
//
//  Created by flamingo on 16/07/19.
//  Copyright © 2019 Appernaut. All rights reserved.
//

import UIKit
import Photos

public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?)
    func didSelectWithUrl(image : UIImage?, fileUrl : URL?)
}

open class ImagePicker: NSObject {
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        
        self.pickerController.delegate = self
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    public func present(from sourceView: UIView) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
//        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
//            alertController.addAction(action)
//        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage? , fileUrl : URL?) {
       // print(fileUrl)
        self.delegate?.didSelect(image: image)
        self.delegate?.didSelectWithUrl(image: image, fileUrl: fileUrl)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: {
            print("here dismissing")
        })
        
      //  self.pickerController(picker, didSelect: nil , fileUrl: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
         let imgUrl = info[UIImagePickerController.InfoKey.referenceURL] as? URL
        picker.dismiss(animated: true, completion: {
            print("here dismissing")
        })
        
        guard let image = info[.originalImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil, fileUrl: nil)
        }
        self.pickerController(picker, didSelect: image, fileUrl: imgUrl)
    }
}

extension ImagePicker: UINavigationControllerDelegate {
    
}
