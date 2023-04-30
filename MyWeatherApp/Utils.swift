//
//  Utils.swift
//  MyWeatherApp
//
//  Created by Timophey Ivanenko on 30.04.2023.
//

import UIKit

extension Double {
  func kelvinToCelcius() -> Int {
    return Int(self - 273.15)
  }
}

extension UIButton {

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = true
        super.touchesBegan(touches, with: event)
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = false
        super.touchesEnded(touches, with: event)
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = false
        super.touchesCancelled(touches, with: event)
    }

}
