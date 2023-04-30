//
//  DataManager.swift
//  MyWeatherApp
//
//  Created by Timophey Ivanenko on 30.04.2023.
//

import Foundation
import RealmSwift


// MARK: - Realm objects

class CityObject: Object {
  @objc dynamic var name: String = ""
  @objc dynamic var lat: Double = 0.0
  @objc dynamic var lon: Double = 0.0
  @objc dynamic var country: String?
  @objc dynamic var state: String?
  @objc dynamic var temperature: Double = 0.0
  @objc dynamic var iconID: Int = 0
  @objc dynamic var weather: WeatherObject?
  
  override static func primaryKey() -> String? {
    return "name"
  }
}

class WeatherObject: Object {
  @objc dynamic var temperature: Double = 0.0
  @objc dynamic var descriptionText: String = ""
  @objc dynamic var iconID: Int = 0
  let cities = LinkingObjects(fromType: CityObject.self, property: "weather")
  override static func primaryKey() -> String? {
    return "iconID"
  }
}

extension CityObject {
  convenience init(city: City) {
    self.init()
    self.name = city.name ?? ""
    self.lat = city.lat ?? 0.0
    self.lon = city.lon ?? 0.0
    self.country = city.country
    self.state = city.state
    self.temperature = city.weather?.main.temp ?? 0.0
  }
}

// MARK: - DATA MANAGER


class DataManager {
  // MARK: Properties
  var weatherService = WeatherService()
  var reloadUI: () -> Void = { }
  var cities: [City] = []
  var currentCity: City?
  let realm = try! Realm()
  
  // MARK: Init
  init() {
    fetchFromCash()
    configCurrentLocation()
  }
  
  // MARK: Functions
  
  func updateWeatherDataWithText(city: City) {
    if city.name != currentCity?.name {
      currentCity = city
      if let lat = city.lat, let lon = city.lon {
        fetchWeatherData(name: city.name ?? "", latitude: lat, longitude: lon)
      }
    }
  }
  
  func updateWeatherDataWithCoord(latitude: Double, longitude: Double) {
    fetchWeatherData(name: "Current location", latitude: latitude, longitude: longitude)
  }
  
  private func fetchFromCash() {
    let realmCities = realm.objects(CityObject.self)
    for city in realmCities {
      let cashedCity = City(name: city.name, lat: city.lat, lon: city.lon, country: nil, state: nil, weather: Weather(city: city))
      cities.append(cashedCity)
    }
  }
  
  private func configCurrentLocation() {
    if cities.count == 0 {
      let currentLocation = City(name: "Current location", lat: nil, lon: nil, country: nil, state: nil, weather: nil)
      addCity(city: currentLocation)
      reloadUI()
    }
  }
  
  private func fetchWeatherData(name: String, latitude: Double, longitude: Double) {
    self.weatherService.weatherFor(latitude: latitude, longitude: longitude) { result in
      switch result {
      case .success(let weather):
        for i in 0..<(self.cities.count) {
          if self.cities[i].name == name {
            self.cities[i].weather = weather
            let cityObject = self.realm.object(ofType: CityObject.self, forPrimaryKey: self.cities[i].name)
            if cityObject != nil {
              try! self.realm.write {
                cityObject?.temperature = weather.main.temp
                cityObject?.iconID = weather.weather[0].id
              }
            }
          }
        }
        self.reloadUI()
      case .failure(let error):
        print("Failed to search for weather: \(error.localizedDescription)")
      }
    }
  }
  
  func addCity(city: City) {
    if !cities.contains(where: {$0.name == city.name}) {
      cities.append(city)
      let realmCity = CityObject(city: city)
      do {
        try realm.write {
          realm.add(realmCity)
        }
      } catch let error as NSError {
        print("Failed to add city: \(error.localizedDescription)")
      }
    }
  }
}
