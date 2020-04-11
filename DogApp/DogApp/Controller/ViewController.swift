//
//  ViewController.swift
//  DogApp
//
//  Created by Timi Tejumola on 10/04/2020.
//  Copyright © 2020 Timi Tejumola. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var breeds : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        DogAPI.requestAllBreeds(completion: handleAllBreedsRessponse(breeds:error:))
    }
       
    func handleAllBreedsRessponse(breeds: [String], error: Error?){
        self.breeds = breeds
        DispatchQueue.main.async {
            self.pickerView.reloadAllComponents()
        }
    }
    
    func handleRandomImageResponse(dogImage: DogImage?, error: Error?){
        guard let dogImageUrl = URL(string: dogImage?.message ?? "") else { return }
        DogAPI.requestImageFile(url: dogImageUrl, completion: self.handleRandomFileResponse(image:error:))
    }
    
    func handleRandomFileResponse(image: UIImage?, error: Error?){
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return breeds.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let url = DogAPI.Endpoint.randowImageForBreed(breeds[row]).url
        print(url)
        DogAPI.requestRandomImage(url: url, completion: handleRandomImageResponse(dogImage:error:))
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return breeds[row]
    }
}
