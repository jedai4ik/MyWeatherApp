//
//  SearchViewController.swift
//  MyWeatherApp
//
//  Created by Timophey Ivanenko on 29.04.2023.
//

import UIKit

class SearchViewController: ViewController {
  
  // MARK: Properties
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var searchTableView: UITableView!
  private var searchResultList: [City] = []
  private var searchTask: DispatchWorkItem?
  var citiesManager: DataManager?
  var weatherService = WeatherService()
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchBar.delegate = self
    setupTableView()
  }
  
  // MARK: Function
  
  private func setupTableView() {
    searchTableView.register(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: "SearchCell")
//    searchTableView.delegate = self
    searchTableView.dataSource = self
  }
  
  private func performSearch(text: String) {
    searchTask?.cancel()
    searchTask = DispatchWorkItem { [weak self] in
      self?.weatherService.searchText(text, limit: 9) { result in
        switch result {
        case .success(let cities):
          self?.searchResultList = cities
          self?.searchTableView.reloadData()
        case .failure(let error):
          print("Failed to search for cities: \(error.localizedDescription)")
        }
      }
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: searchTask!)
  }
  
  
}


// MARK: - Extensions

extension SearchViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    performSearch(text: searchText)
  }
}


extension SearchViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    searchTableView.deselectRow(at: indexPath, animated: true)
  }
}


extension SearchViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchResultList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: SearchCell = searchTableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
    if indexPath.row < searchResultList.count {
      cell.configure(for: searchResultList[indexPath.row])
    }
    cell.addCity = { [weak self] city in
      self?.citiesManager?.addCity(city: city)
    }
    return cell
  }
  
  
}
