//
//  ContentView.swift
//  diem
//
//  Created by Travis Luckenbaugh on 3/26/23.
//

import SwiftUI

func diem() -> String {
    let df = DateFormatter()
    df.dateFormat = "D"
    return df.string(from: Date())
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "sun.max.fill")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Day \(diem())")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
