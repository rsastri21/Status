//
//  RoundedTextFieldStyle.swift
//  Status
//
//  Created by Rohan Sastri on 3/30/25.
//

import SwiftUI
import Foundation

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical)
            .padding(.horizontal, 24)
            .background(Color(UIColor.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
