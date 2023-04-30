//
//  TableViewCell.swift
//  MyWeatherApp
//
//  Created by Timophey Ivanenko on 29.04.2023.
//

import UIKit

class SearchCell: UITableViewCell {
  
  @IBOutlet weak var cityTitle: UILabel!
  @IBOutlet weak var citySubtitle: UILabel!
  
  var location: City?
  var addCity: ((City) -> Void)?
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  func configure(for location: City) {
    self.location = location
    setupLabels()
  }
  
  private func setupLabels() {
    cityTitle.text = location?.name
    let state = location?.state ?? ""
    let country = location?.country ?? ""
    citySubtitle.text = state
    if state.isEmpty {
      citySubtitle.text = country
    } else {
      citySubtitle.text = state + ", " + country
    }
  }
  @IBAction func addCityButtonAction(_ sender: Any) {
    print("tapped")
    if let city = location {
      addCity?(city)
    }
  }
  
}
