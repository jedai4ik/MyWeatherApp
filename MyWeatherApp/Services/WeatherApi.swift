//
//  WeatherApi.swift
//  MyWeatherApp
//
//  Created by Timophey Ivanenko on 29.04.2023.
//

import Foundation
import Alamofire

struct OpenWeather {
  static let baseURL = "https://api.openweathermap.org/"
  static let apiKey = "3a5fabe12f5bccdfca69c983db89f6bb"
}


class WeatherService {
  private let openWeatherMapApiKey = "398dffccde8b1daac18d99f3c3b68dcb"
  private let openWeatherMapBaseUrl = "https://api.openweathermap.org/data/2.5/"
  private let openWeatherMapBaseUrlForText = "https://api.openweathermap.org/geo/1.0/direct"
  
  func searchText(_ text: String, limit: Int, completion: @escaping (Result<[City], Error>) -> Void) {
    let url = "\(openWeatherMapBaseUrlForText)?q=\(text)&limit=\(limit)&appid=\(openWeatherMapApiKey)"
    print(url)
    AF.request(url).validate().responseDecodable(of: [City].self) { response in
      switch response.result {
      case .success(let citiesResponse):
        completion(.success(citiesResponse))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  func weatherFor(latitude: Double, longitude: Double, completion: @escaping (Result<Weather, Error>) -> Void) {
    let url = "\(openWeatherMapBaseUrl)weather?lat=\(latitude)&lon=\(longitude)&appid=\(openWeatherMapApiKey)"
    AF.request(url).validate().responseDecodable(of: Weather.self) { response in
      switch response.result {
      case .success(let weather):
        completion(.success(weather))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}

struct CitiesResponse: Decodable {
  let list: [City]
}

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
