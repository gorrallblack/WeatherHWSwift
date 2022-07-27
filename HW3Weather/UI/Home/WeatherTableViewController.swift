//
//  weatherTableViewController.swift

import UIKit
import CoreLocation
import LocationManagerSwift

class WeatherTableViewController: UITableViewController {
    
    var weatherTableModalView : WeatherTableModalView = WeatherTableModalView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showLoadingScreen()
        self.weatherTableModalView.setUpWeatherModal {[weak self] reloadStatus in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.dismissCustomLoading()
            if reloadStatus {
                DispatchQueue.main.async {
                    weakSelf.tableView.reloadData()
                }
            }
        }
    }
            
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.weatherTableModalView.getSectionCount()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dictKey = self.weatherTableModalView.sectionHeader(section: section)
        return self.weatherTableModalView.getListForKey(dictKey: dictKey).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCustomCell", for: indexPath) as! weatherTableViewCell
            cell.selectionStyle = .none
        
        let dictKey = self.weatherTableModalView.sectionHeader(section: indexPath.section)
        let listArray = self.weatherTableModalView.getListForKey(dictKey: dictKey)
        let listItem = listArray[indexPath.row]

        // Configure the cell...
        cell.tempValue.text = "\(listItem.main?.temp ?? 0.0)°C"
        guard let weatherItem = listItem.weather?.first else {
            return cell
        }
        
        cell.cityName.text = "\(weatherItem.main ?? "")"
        
        let imageURlString : String = String(format: "%@%@.png", Weather_Condition_Image_Url, (weatherItem.icon ?? ""))
        cell.weatherImage.setImage(with: imageURlString)
        
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.backgroundColor = UIColor(white: 1, alpha: 0.8)

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       return self.weatherTableModalView.sectionHeader(section: section)
    }
    
}
