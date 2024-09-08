//  diem/iOS - Workouts.swift
//  Created by Travis Luckenbaugh on 9/7/24.

import SwiftUI
import Charts

struct SalesData: Identifiable, Equatable {
    let id = UUID()
    let month: String
    let sales: Double
}

struct WorkoutsView: View {
    let data: [SalesData] = [
        SalesData(month: "Jan", sales: 1000),
        SalesData(month: "Feb", sales: 1500),
        SalesData(month: "Mar", sales: 1200),
        SalesData(month: "Apr", sales: 1800),
        SalesData(month: "May", sales: 2200),
        SalesData(month: "Jun", sales: 2100)
    ]
    
    let color = Color("AccentColor")
    @State var selectedValue: SalesData?
    
    var body: some View {
        VStack(alignment: .leading) {
            if let selectedValue {
                VStack(alignment: .leading) {
                    Text(selectedValue.month).font(.title)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Sales")
                            Text("\(selectedValue.sales)")
                        }
                    }
                }.padding()
            } else {
                Text("Monthly Sales")
                    .font(.title)
                    .padding()
            }
            Chart(data) { item in
                AreaMark(
                    x: .value("Month", item.month),
                    y: .value("Sales", item.sales)
                )
                .foregroundStyle(color.opacity(0.3))
                .interpolationMethod(.catmullRom)
                
                LineMark(
                    x: .value("Month", item.month),
                    y: .value("Sales", item.sales)
                )
                .foregroundStyle(color)
                .interpolationMethod(.catmullRom)
                
                if selectedValue == item {
                    RuleMark(
                        x: .value("Month", item.month)
                    )
                    .foregroundStyle(color)
                }
                
                PointMark(
                    x: .value("Month", item.month),
                    y: .value("Sales", item.sales)
                )
                .foregroundStyle(color)
                .symbolSize(100) // Adjust this value to change the circle size
            }
            .frame(height: 300)
            .padding()
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 0)) // Hide line
                    AxisTick(centered: true, stroke: StrokeStyle(lineWidth: 0))
                    AxisValueLabel()
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let currentX = value.location.x - geometry[proxy.plotAreaFrame].origin.x
                                    guard let month: String = proxy.value(atX: currentX) else { return }
                                    selectedValue = data.first { month == $0.month }
                                }
                        )
                }
            }
        }
    }
}
