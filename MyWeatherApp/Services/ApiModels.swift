//
//  ApiModels.swift
//  MyWeatherApp
//
//  Created by Timophey Ivanenko on 30.04.2023.
//

import Foundation

struct City: Codable {
  let name: String?
  let lat: Double?
  let lon: Double?
  let country: String?
  let state: String?
  var weather: Weather?
}

struct Coord: Codable {
  let lat: Double
  let lon: Double
}

struct Weather: Codable {
  let weather: [WeatherDetail]
  let main: Main
  let wind: Wind
}

extension Weather {
  init(city: CityObject) {
    self.weather = [WeatherDetail(main: "", description: "", id: city.iconID)]
    self.wind = Wind(speed: 0.0)
    self.main = Main(temp: city.temperature, humidity: 0)
  }
}

struct WeatherDetail: Codable {
  let main: String
  let description: String
  let id: Int
}

struct Main: Codable {
  let temp: Double
  let humidity: Int
}

struct Wind: Codable {
  let speed: Double
}
