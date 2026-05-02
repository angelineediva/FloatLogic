//
//  Tutorial2View.swift
//  FloatLojic
//
//  Created by Angeline on 02/05/26.
//

import SwiftUI

struct Tutorial2View : View {
    var body: some View {
        ZStack {
            Image("Background")
                           .resizable()
                           .frame(width: 349, height: 380)
                           .offset(y : -75)
            
            Image("Water")
                        .resizable()
                        .frame(width: 349, height: 242)
                        .offset(y : 20)
        }
    }
    

}

#Preview {
    Tutorial2View()
}
