//
//  TutorialView.swift
//  FloatLojic
//
//  Created by Feivel on 30/04/26

import SwiftUI
struct TutorialView: View {
    
    @StateObject private var vm = TutorialViewModel()
    
    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .frame(width: 349, height: 380)
                .offset(y: -75) //ini peletakan mau lebih naik / turun, kalau ada X berarti peletakan kiri / kanan
            
            Image("Water")
                .resizable()
                .frame(width: 349, height: 442)
                .offset(y: -75)
            
            Image("BobberFull")
                .resizable()
                .frame(width: 40, height: 80)
                .offset(x: vm.offsetX, y: vm.offsetY - 20)
            
            //Ini Air di depan bobber nya buat nutupin
            Image("airnew")
                .resizable()
                .frame(width: 349, height: 470)
                .offset(x: -5, y: -70)
            
            
            
        }
        
        //Kalau mau coba animate bisa ganti 'vm.animate[nama]'
        .onTapGesture {
            vm.animateNibble()
        }
    }
}

#Preview {
    TutorialView()
}
