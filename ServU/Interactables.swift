//
//  Interactables.swift
//  ServU
//
//  Created by Amber Still on 7/3/25.
//

import SwiftUI

struct BasicButtonView: View{
    var text: String
    var textColor: Color
    var backgroundColor: Color
    
    var body: some View{
        Text(text)
            .font(.system(size: 24))
            .foregroundColor(textColor)
            .padding()
            .frame(width: 200, height: 50)
            .background(backgroundColor)
            .cornerRadius(10)    }
}

