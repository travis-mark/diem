//  diem/iOS - TextFileView.swift
//  Created by Travis Luckenbaugh on 6/29/24.
//  TODO: TL 6/29/24 Create File Template

import SwiftUI

struct TextFileView: View {
    let contents: String
    
    init(contents: String) {
        self.contents = contents
    }
    
    init(url: URL) {
        do {
            self.contents = try String(contentsOf: url)
        } catch {
            self.contents = error.localizedDescription
        }
    }
    
    var body: some View {
        Text(contents)
    }
}

#Preview {
    VStack {
        TextFileView(contents: "Hello, World!")
        TextFileView(url: URL(string: "http://bad.site/404")!)
        TextFileView(url: Bundle.main.url(forResource: "health", withExtension: "csv")!)
    }
}
