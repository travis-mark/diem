//  diem - view.swift
//  Created by Travis Luckenbaugh on 4/7/23.

import Foundation
import WidgetKit
import SwiftUI
import Intents

indirect enum Expr {
    case symbol(String)
    case number(NSNumber)
    case string(String)
    case cell(Expr, Expr)
    case null
}

extension Expr: CustomStringConvertible {
    var description: String {
        switch (self) {
        case .symbol(let symbol):
            return symbol
        case .number(let number):
            return number.description
        case .string(let string):
            return string
        case .null:
            return "()"
        case .cell(let head, let tail):
            return "(\(head.description) \(unroll(tail).map({ $0.description }).joined(separator: " ")))"
        }
    }
}

extension Expr: Identifiable {
    var id: String {
        return self.description
    }
}


func unroll(_ list: Expr, _ collection: [Expr] = []) -> [Expr] {
    switch list {
    case .null: return collection
    case .cell(let head, let tail): return unroll(tail, collection + [head])
    default: return collection + [list]
    }
}

struct ExprView: View {
    let expr: Expr
    var body: some View {
        switch (expr) {
        case .symbol(let symbol):
            return AnyView(Text(symbol))
        case .number(let number):
            return AnyView(Text(number.description))
        case .string(let string):
            return AnyView(Text(string))
        case .null:
            return AnyView(Text("()"))
        case .cell(let head, let tail):
            switch head {
            case .symbol("vstack"):
                return AnyView(VStack {
                    ForEach(unroll(tail)) { expr in
                        ExprView(expr: expr)
                    }
                })
            case .symbol("nsdateformat"):
                if case let .string(format) = tail {
                    return AnyView(Text(string(from: Date(), format: format)))
                }
            default: break
            }
            return AnyView(Text(expr.description))
        }
    }
}

struct DateView: View {
    let date: Date
    var body: some View {
        VStack {
            Text(string(from: date, format: "MMMM"))
                .fontWeight(.bold)
                .widgetAccentable()
            Text(string(from: date, format: "d"))
        }
    }
}

struct DayView: View {
    let date: Date
    var body: some View {
        VStack {
            Text(string(from: date, format: "F").toOrdinal)
                .fontWeight(.bold)
                .widgetAccentable()
            Text(string(from: date, format: "EEE"))
        }
    }
}

struct YearDayView: View {
    let date: Date
    var body: some View {
        VStack {
            Text("Day")
                .fontWeight(.bold)
                .widgetAccentable()
            Text(string(from: date, format: "D"))
        }
    }
}

struct YearWeekView: View {
    let date: Date
    var body: some View {
        VStack {
            Text("Week")
                .fontWeight(.bold)
                .widgetAccentable()
            Text(string(from: date, format: "ww"))
        }
    }
}

struct DateInlineView: View {
    let date: Date
    var body: some View {
        Text("\(string(from: date, format: "MMM d")) - \(string(from: date, format: "F EEEE").toOrdinalAll)")
    }
}


struct YearInlineView: View {
    let date: Date
    var body: some View {
        Text(string(from: date, format: "'Day' D - 'Week' ww"))
    }
}

struct EverythingView: View {
    let date: Date
    var body: some View {
        VStack {
            Text("\(string(from: date, format: "MMM d")) - \(string(from: date, format: "F EEE").toOrdinalAll)")
                .fontWeight(.bold)
                .widgetAccentable()
            Text("\(string(from: date, format: "'Day' D - 'Week' ww"))")
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
