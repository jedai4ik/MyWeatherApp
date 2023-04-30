//
//  WeatherApi.swift
//  MyWeatherApp
//
//  Created by Timophey Ivanenko on 29.04.2023.
//

import Foundation
import Alamofire

class WeatherService {
  private let openWeatherMapApiKey = "398dffccde8b1daac18d99f3c3b68dcb"
  private let openWeatherMapBaseUrl = "https://api.openweathermap.org/data/2.5/"
  private let openWeatherMapBaseUrlForText = "https://api.openweathermap.org/geo/1.0/direct"
  
  func searchText(_ text: String, limit: Int, completion: @escaping (Result<[City], Error>) -> Void) {
    let url = "\(openWeatherMapBaseUrlForText)?q=\(text)&limit=\(limit)&appid=\(openWeatherMapApiKey)"
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
