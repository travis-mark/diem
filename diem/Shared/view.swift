//  diem - view.swift
//  Created by Travis Luckenbaugh on 4/7/23.

import Foundation
import WidgetKit
import SwiftUI
import Intents

struct DateWidgetView: View {
    let entry: DiemEntry
    
    var body: some View {
        VStack {
            if entry.textLabelBold == true {
                Text(applyOrdinal(entry.textLabel, entry.date))
                    .fontWeight(.bold)
                    .widgetAccentable()
            } else {
                Text(applyOrdinal(entry.textLabel, entry.date))
            }
            if entry.detailTextLabel.isEmpty == false {
                if entry.detailTextLabelBold == true {
                    Text(applyOrdinal(entry.detailTextLabel, entry.date))
                        .fontWeight(.bold)
                        .widgetAccentable()
                } else {
                    Text(applyOrdinal(entry.detailTextLabel, entry.date))
                }
            }
        }
    }
}

struct WidgetBoxModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }
}
