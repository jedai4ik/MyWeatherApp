//
//  ViewController.swift
//  MyWeatherApp
//
//  Created by Timophey Ivanenko on 29.04.2023.
//

import UIKit
import CoreLocation

class MainScreenViewModel {
  // MARK: Properties
  private var searchTask: DispatchWorkItem?
  var weatherService = WeatherService()
  var reloadUI: () -> Void = { }
  var cities: [City] = [
    City(name: "Current location", lat: nil, lon: nil, country: nil, state: nil, weather: nil)
  ]
  var currentCity: City?
  
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
  
  private func fetchWeatherData(name: String, latitude: Double, longitude: Double) {
    self.weatherService.weatherFor(latitude: latitude, longitude: longitude) { result in
      switch result {
      case .success(let weather):
        for i in 0..<(self.cities.count) {
          if self.cities[i].name == name {
            self.cities[i].weather = weather
            break
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
    }
  }
  
  
}

class ViewController: UIViewController {
  // MARK: Properties
  @IBOutlet weak var scrollView: UIScrollView?
  @IBOutlet weak var searchButton: UIButton!
  @IBOutlet weak var pageControl: UIPageControl?
  
  
  var viewModel = MainScreenViewModel()
  var slides: [DetailWeatherPage] = []
  let locationManager = CLLocationManager()
  
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    locationManager.requestLocation()
    
    
    if let pageControl = pageControl {
      view.bringSubviewToFront(pageControl)
    }
    viewModel.reloadUI = { [weak self] in
      self?.updateView()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    scrollView?.contentSize.height = 1.0
    updateView()
    pageControl?.currentPage = 0
  }
  
  // MARK: Fucntions
  private func updateView() {
    slides = createSlides()
    setupSlideScrollView(slides: slides)
    pageControl?.numberOfPages = slides.count
   
  }
  
  private func createSlides() -> [DetailWeatherPage] {
    return viewModel.cities.map({ city in
      let slide:DetailWeatherPage = Bundle.main.loadNibNamed("DetailWeatherPage", owner: self, options: nil)?.first as! DetailWeatherPage
      slide.cityLabel.text = city.name
      if let temp = city.weather?.main.temp {
        slide.temperature.text = String(temp.kelvinToCelcius()) + "°C"
      }
      if let id = city.weather?.weather[0].id {
        slide.imageView.image = UIImage(systemName: getImage(conditionId: id))
      }
      return slide
    })
  }
  
  private func getImage(conditionId: Int) -> String {
    switch conditionId {
    case 200...232:
      return "cloud.bolt"
    case 300...321:
      return "cloud.drizzle"
    case 500...531:
      return "cloud.rain"
    case 600...622:
      return "cloud.snow"
    case 701...781:
      return "cloud.fog"
    case 800:
      return "sun.max"
    case 801...804:
      return "cloud.bolt"
    default:
      return "cloud"
    }
  }
    
  @IBAction func barButtonTapped(_ sender: Any) {
    print("tapped")
    if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
      viewController.citiesManager = viewModel
      if let navigator = navigationController {
        navigator.pushViewController(viewController, animated: true)
      }
    }
  }
}

// MARK: - UIScrollViewDelegate

extension ViewController: UIScrollViewDelegate {
  func setupSlideScrollView(slides : [DetailWeatherPage]) {
    if let scrollView = scrollView {
      scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
      scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
      scrollView.isPagingEnabled = true
      for i in 0 ..< slides.count {
        slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.addSubview(slides[i])
      }
    }
  }
  
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
    pageControl?.currentPage = Int(pageIndex)
    viewModel.updateWeatherDataWithText(city: viewModel.cities[Int(pageIndex)])
  }
}

//MARK: - CLLocationManagerDelegate


extension ViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      locationManager.stopUpdatingLocation()
      let lat = location.coordinate.latitude
      let lon = location.coordinate.longitude
      viewModel.updateWeatherDataWithCoord(latitude: lat, longitude: lon)
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}


