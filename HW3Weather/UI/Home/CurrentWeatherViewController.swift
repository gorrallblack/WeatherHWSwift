//
//  CurrentWeatherViewController.swift
//  HW3Weather

import UIKit
import Kingfisher

class CurrentWeatherViewController: UIViewController {
    @IBOutlet weak var weatherIconImageView : UIImageView!
    @IBOutlet weak var locationNameLabel : UILabel!
    @IBOutlet weak var temperatureLabel : UILabel!
    
    var currentWeatherViewModal : CurrentWeatherViewModal = CurrentWeatherViewModal()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.locationNameLabel.text = ""
        self.temperatureLabel.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showLoadingScreen()
        
        self.currentWeatherViewModal.fetchCurrentLocation { [weak self] successStatus, locationAddress, currentWeatherItem  in
            guard let weakSelf = self else { return }
            
                weakSelf.dismissCustomLoading()
            
            if successStatus {
                DispatchQueue.main.async {
                    
                    weakSelf.locationNameLabel.text = locationAddress
                    
                    guard let weatherCondition = currentWeatherItem?.weather?.first else {
                        weakSelf.temperatureLabel.text = String(format: "%.02lf", currentWeatherItem?.main?.temp ?? 0.0)
                        return
                    }
                    
                    let imageURlString : String = String(format: "%@%@.png", Weather_Condition_Image_Url, (weatherCondition.icon ?? ""))
                    weakSelf.weatherIconImageView.setImage(with: imageURlString)
                    weakSelf.temperatureLabel.text = String(format: "%.02lf ℃ | %@", currentWeatherItem?.main?.temp ?? 0.0, weatherCondition.weatherDescription ?? "")
                }
            }
            else {
                weakSelf.showAlertController(errorMessage: "Unable to Fetch Location")
            }
        }
    }
    
    func showAlertController(errorMessage: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error - ", message: "\(errorMessage)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
}
