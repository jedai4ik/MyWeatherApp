//
//  ViewController.swift
//  MyWeatherApp
//
//  Created by Timophey Ivanenko on 29.04.2023.
//

import UIKit
import CoreLocation


 // MARK: - MainScreenViewController

class ViewController: UIViewController {
  // MARK: Properties
  @IBOutlet weak var scrollView: UIScrollView?
  @IBOutlet weak var searchButton: UIButton!
  @IBOutlet weak var pageControl: UIPageControl?
  
  
  var dataManager: DataManager = DataManager()
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
    dataManager.reloadUI = { [weak self] in
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
    return dataManager.cities.map({ city in
      let slide:DetailWeatherPage = Bundle.main.loadNibNamed("DetailWeatherPage", owner: self, options: nil)?.first as! DetailWeatherPage
      slide.cityLabel.text = city.name
      if let temp = city.weather?.main.temp {
        slide.temperature.text = String(temp.kelvinToCelcius()) + "°C"
      }
      if let id = city.weather?.weather[0].id {
        slide.imageView.image = UIImage(systemName: id.getImage())
      }
      return slide
    })
  }
  
  // MARK: Navifation
  @IBAction func barButtonTapped(_ sender: Any) {
    if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
      viewController.citiesManager = dataManager
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
    dataManager.updateWeatherDataWithText(city: dataManager.cities[Int(pageIndex)])
  }
}

//MARK: - CLLocationManagerDelegate


extension ViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      locationManager.stopUpdatingLocation()
      let lat = location.coordinate.latitude
      let lon = location.coordinate.longitude
      dataManager.updateWeatherDataWithCoord(latitude: lat, longitude: lon)
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}


