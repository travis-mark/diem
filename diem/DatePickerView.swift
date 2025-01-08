//  diem/iOS - DatePickerView.swift
//  Created by Travis Luckenbaugh on 1/7/25.

import SwiftUI

struct DatePickerView: View {
    @Binding var date: Date
    
    var body: some View {
        HStack {
            Button() {
                date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .bold))
            }.padding(22)
            DatePicker(
                "",
                selection: $date,
                displayedComponents: .date
            ).onChange(of: date, initial: false) { _, newDate  in
                date = newDate
            }
            .frame(maxWidth: .infinity)
            .labelsHidden()
            Button() {
                date = Calendar.current.date(byAdding: .day, value: +1, to: date)!
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 24, weight: .bold))
            }.padding(22)
        }
    }
}
