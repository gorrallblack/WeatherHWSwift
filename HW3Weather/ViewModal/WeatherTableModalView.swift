//
//  WeatherTableModalView.swift

import Foundation
import CoreLocation
import LocationManagerSwift

class WeatherTableModalView {
    
    var weatherDict : Dictionary<String, Any>?
        
    func getSectionCount() -> Int {
        return self.weatherDict?.count ?? 0
    }
    
    func setUpWeatherModal(completionHandler: @escaping(_ successStatus: Bool)-> Void) {
        self.checkInUser()
        self.fetchUpdateLocation { successStatus, weatherDataDict in
            if successStatus {
                self.weatherDict = weatherDataDict
                completionHandler(true)
            }
            else {
                self.weatherDict = Dictionary<String, Any>()
                completionHandler(false)
            }
        }
    }
    
    func checkInUser() {
        if (!TYLoginDataModel.sharedLoginDataModel().checkLogin()) {
            let uuid = UUID().uuidString
            TYLoginDataModel.sharedLoginDataModel().loginWithUser(username: uuid)
            let user = CoreUser(username: uuid, timestamp: Int64(Date().millisecondsSince1970))
            FirebaseManager.getInstance().saveUser(user: user) { error in
                print(error)
            }
        }
    }
    
    func fetchUpdateLocation(completionHandler: @escaping(_ successStatus: Bool, _  weatherDataDict: Dictionary<String, Any>?) -> Void) {
        LocationManagerSwift.shared.updateLocation { (latitude, longitude, status, error) in
            if error == nil {
                print("latitude is \(latitude)")
                print("longitude is \(longitude)")
                // reverse geo coding using Apple or Google API's
                LocationManagerSwift.shared.reverseGeocodeLocation(type: .APPLE) {[weak self](countryOptional, state, cityOptional, reverseGecodeInfo, placemark, error) in
                    guard let weakSelf = self else { return }
                    if error == nil {
                        if let country = countryOptional,
                            let city = cityOptional {
                            let log = LocationLog(userId: TYLoginDataModel.sharedLoginDataModel().username as String,
                                                  city: city,
                                                  country: country,
                                                  latitude: latitude,
                                                  longitude: longitude,
                                                  timestamp: Int64(Date().millisecondsSince1970))
                            FirebaseManager.getInstance().saveLocationLog(log: log) { _ in
                                
                            }
                            
                            weakSelf.getWeeklyForecast(city: city, country: country) { successStatus, weatherData in
                                print("weatherData is \(weatherData)")
                                completionHandler(true, weatherData)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getWeeklyForecast(city: String, country: String,
                           completionHandler: @escaping(_ successStatus: Bool, _  weatherDataDict: Dictionary<String, Any>?) -> Void) {
        let query = "https://api.openweathermap.org/data/2.5/forecast?q=\(city),\(country)&units=metric&APPID=\(OPEN_WEATHER_APP_ID)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: query!)! as URL,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10.0)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { data, response, error in
            guard error == nil else {
                print("Error: \(error!)")
                completionHandler(false, Dictionary<String, Any>())
                return
            }
            
            guard let jsonData = data else {
                print("No data")
                completionHandler(false, Dictionary<String, Any>())
                return
            }
            
            do {
                let welcome = try? JSONDecoder().decode(WeatherData.self, from: jsonData)
                guard let welcomeItem = welcome else {
                    return
                }
                
                guard let listItems = welcomeItem.list else {
                    return
                }
                
                let groupDic = Dictionary(grouping: listItems) { (pendingCamera) -> String in
                    let userDateString = self.formatSubmissionStartDate(date: pendingCamera.dtTxt ?? "")
                    return userDateString
                }
                
                print("sortedDict is \(groupDic)")
                completionHandler(true, groupDic)
                
            } catch {
                print("JSONDecoder error : \(error)")
                completionHandler(false, Dictionary<String, Any>())
            }
        }
            
        dataTask.resume()
        print("Data is loaded")
    }

    func formatSubmissionStartDate(date: String) -> String {
       let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"

       let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd"

        let dateObj: Date? = dateFormatterGet.date(from: date)
        return dateFormatter.string(from: dateObj!)
    }
    
    func getAllKeys() -> [String] {
        var myKeys: [String] = self.weatherDict?.map{ String($0.key) } ?? [String]()
            myKeys = myKeys.sorted()
        return myKeys
    }
    
    func getListForKey(dictKey: String) -> [List] {
        guard let listArray = self.weatherDict?[dictKey] else {
            return [List]()
        }
        
        return listArray as! [List]
    }
    
    func sectionHeader(section: Int) -> String {
        let sectionTitleArray = self.getAllKeys()
        return sectionTitleArray[section]
    }
    
}
