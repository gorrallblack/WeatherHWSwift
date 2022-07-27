//
//  CurrentWeatherViewModal.swift

import Foundation
import UIKit
import CoreLocation
import LocationManagerSwift

class CurrentWeatherViewModal {
    
    func fetchCurrentLocation(completionHandler: @escaping(_ successStatus : Bool,
                                                           _ locationName : String?,
                                                           _ currentWeatherItem : CurrentWeather?) -> Void) {
        LocationManagerSwift.shared.updateLocation { [weak self] (latitude, longitude, status, error) in
            guard let weakSelf = self else { return }
            if error == nil {
                print("latitude is \(latitude)")
                print("longitude is \(longitude)")
                // reverse geo coding using Apple or Google API's
                LocationManagerSwift.shared.reverseGeocodeLocation(type: .APPLE) {[weak self](countryOptional, state, cityOptional, reverseGecodeInfo, placemark, error) in
                    if error == nil {
                        if let country = countryOptional,
                            let city = cityOptional {
                            let log = LocationLog(userId: TYLoginDataModel.sharedLoginDataModel().username as String, city: city, country: country, latitude: latitude, longitude: longitude, timestamp: Int64(Date().millisecondsSince1970))
                            FirebaseManager.getInstance().saveLocationLog(log: log) { _ in
                                
                            }
                            
                            weakSelf.getCurrentWeather(city: city, country: country) { successStatus, currentWeatherItem in
                                let cityName : String = String(format: "%@ %@", city, country)
                                completionHandler(successStatus, cityName , currentWeatherItem)
                            }
                        }
                    }
                    else {
                        completionHandler(false, "", nil)
                    }
                }
            }
        }
    }
    
    func getCurrentWeather(city: String, country: String, completionHandler: @escaping(_ successStatus : Bool,
                                                                                       _ currentWeatherItem : CurrentWeather?) -> Void) {
        let query = "https://api.openweathermap.org/data/2.5/weather?q=\(city),\(country)&units=metric&APPID=\(OPEN_WEATHER_APP_ID)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: query!)! as URL,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10.0)
            request.httpMethod = "GET"
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { data, response, error in
            guard error == nil else {
                print("Error: \(error!)")
                
                completionHandler(false,  nil)
                return
            }
            
            guard let jsonData = data else {
                print("No data")
                
                completionHandler(false,  nil)
                return
            }
            
            do {
                let currentWeather = try? JSONDecoder().decode(CurrentWeather.self, from: jsonData)
                    completionHandler(true , currentWeather)

            } catch {
                print("JSONDecoder error : \(error)")
                completionHandler(false,  nil)
            }
        }
            
        dataTask.resume()
        
        print("Data is loaded")
    }

    
}
