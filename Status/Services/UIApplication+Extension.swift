//
//  UIApplication+Extension.swift
//  Status
//
//  Created by Rohan Sastri on 3/30/25.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
