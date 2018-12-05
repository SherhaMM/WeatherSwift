//
//  ViewController.swift
//  WeatherSwift
//
//  Created by Makcim Mikhailov on 12.11.18.
//  Copyright © 2018 Makcim Mikhailov. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DataEnteredDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "cityListSegue" {
            let secondController = segue.destination as! NewViewController
            secondController.delegate = self
        }
    }
    func userDidEnterInformation(info: String){
        seguedCity = info
    }
    
    @IBAction func gestureTap(_ sender: Any) {
        searchBar.resignFirstResponder()
    }
    var lastEnteredValue: String = ""
    var whicTemp = true
    @IBOutlet weak var tempSwitch: UISegmentedControl!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var feelsLikeLaber: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var onTapGestureRecognizer: UITapGestureRecognizer!

    var seguedCity: String?
  
    @IBAction func onTapGestureRecognized(sender: AnyObject) {
        searchBar.resignFirstResponder()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        decodeJs()
        searchBar.delegate = self
          showWeatherMainMethod(enteredValue: "Odessa ua")
    }
    @IBAction func indexChanged(_ sender: Any) {
        switch tempSwitch.selectedSegmentIndex
        {
        case 1:
            whicTemp = false;
        default:
            whicTemp = true;
        }
        showWeatherMainMethod(enteredValue: lastEnteredValue)
        
    }
    override func viewWillAppear(_ animated: Bool) {
       if seguedCity != nil {
            showWeatherMainMethod(enteredValue: seguedCity!)
        }
       
    }

    func showWeatherMainMethod(enteredValue:String) {
        //     let urlString = "https://api.apixu.com/v1/forecast.json?key=a7461be9f2344489ad985746181211&q=\(searchBar.text!.replacingOccurrences(of: " ", with: "%20"))"
        lastEnteredValue = enteredValue
        let urlString = "https://api.apixu.com/v1/forecast.json?key=a7461be9f2344489ad985746181211&q=\(enteredValue.replacingOccurrences(of: " ", with: "%20"))"
        
        let url = URL(string: urlString)
        
        var cityName: String?
        var windKpm: Double?
        var feelsLike: Double?
        var humidity: Double?
        var temperature: Double?
        var windMph: Double?
        var feelsLikeF: Double?
        var temperatureF: Double?
        var errorHasOccured: Bool = false
        
        let task = URLSession.shared.dataTask(with: url!) { ( data, response, error) in
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                if let _ = json["error"]{
                    errorHasOccured = true
                }
                
                
                if let current = json["current"] {
                    windKpm = current["wind_kph"] as? Double
                    feelsLike = current["feelslike_c"] as? Double
                    humidity =  current["humidity"] as? Double
                    temperature = current["temp_c"] as? Double
                    temperatureF = current["temp_f"] as? Double
                    feelsLikeF = current["feelslike_f"] as? Double
                    windMph = current["wind_mph"] as? Double
                }
                if let location = json["location"] {
                    cityName = location["name"] as? String
                }
                
                if let forecast = json["forecast"]  {
                    if let forecastday = forecast["forecastday"]{
                        //  print(forecastday)
                        
                    }
                    //     maxTemperature = forecast as? Double
                    // minTemperature = day["mintemp_c"] as? Double
                    
                    //          }
                    
                }
                DispatchQueue.main.async {
                    if(errorHasOccured){
                        self.cityLabel.text = "Choose another city"
                        self.temperatureLabel.isHidden = true
                    }
                        
                    else{
                         self.temperatureLabel.isHidden = false
                         self.cityLabel.text = cityName
                         self.humidityLabel.text = "\(humidity ?? 0)"
                        
                        if self.whicTemp {
                            self.feelsLikeLaber.text = "\(feelsLike ?? 0)°C"
                            self.windSpeedLabel.text = "\(windKpm ?? 0)km/h"
                            self.temperatureLabel.text = "\(temperature!)°C"
                        } else {
                            self.feelsLikeLaber.text = "\(feelsLikeF ?? 0)°F"
                            self.windSpeedLabel.text = "\(windMph ?? 0)mph/h"
                            self.temperatureLabel.text = "\(temperatureF!)°F"
                        }
                    }
                }
            }
            catch let jsonError {
                print(jsonError)
            }
        }
        
        task.resume()
        
       
    }
}

    
    
    
    

struct Forecast: Decodable {
    var forecast: Forecasty
    var current: Current
    
    struct Current: Decodable {
        var temp_c: Double
    }
    
struct Forecasty: Decodable {
    var forecastday: [ForecastDay]
    
    struct ForecastDay: Decodable {
        var day: Day
        var astro: Astro
        
        struct Astro: Decodable {
            var sunrise: String
            var sunset: String
        }
 
        struct Day: Decodable {
            var maxtemp_c: Double
            var mintemp_c: Double
            var avgtemp_c: Double
            var condition: Cond
            
               struct Cond: Decodable {
                var text: String
                }
            }
 
        }
    }

}
func decodeJs(){
    let urlString = "https://api.apixu.com/v1/forecast.json?key=a7461be9f2344489ad985746181211&q=paris"
    
    let url = URL(string: urlString)
    let task1 = URLSession.shared.dataTask(with: url!) { ( data, response, error) in
        
    do{
     //   let weatherArray: Forecast = try JSONDecoder().decode(Forecast.self , from: myJSONArray.data(using: .utf8)!)
          let weatherArray: Forecast = try JSONDecoder().decode(Forecast.self , from: data!)
    //   debugPrint(weatherArray)
        //  print(weatherArray)
        print(weatherArray)
    }
    catch {
        print(error)
    }
}
     task1.resume()
}

extension ViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        print(searchBar.text!)
        showWeatherMainMethod(enteredValue: searchBar.text!)
        
    
     }
}
