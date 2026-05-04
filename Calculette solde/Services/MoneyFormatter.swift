//
//  MoneyFormatter.swift
//  Calculette solde
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

import Foundation

struct MoneyFormatter {
    let locale: Locale

    private let decimalFormatter: NumberFormatter
    private let currencyFormatter: NumberFormatter

    init(locale: Locale = .autoupdatingCurrent) {
        self.locale = locale
        self.decimalFormatter = Self.makeDecimalFormatter(locale: locale)
        self.currencyFormatter = Self.makeCurrencyFormatter(locale: locale)
    }

    func parseDecimal(_ text: String) -> Decimal? {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return nil }

        if let number = decimalFormatter.number(from: trimmedText) {
            return number.decimalValue
        }

        let normalizedText = trimmedText
            .replacingOccurrences(of: "\u{00A0}", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")

        return Decimal(string: normalizedText, locale: Locale(identifier: "en_US_POSIX"))
    }

    func wholeNumber(from value: Decimal) -> Int? {
        var roundedValue = Decimal()
        var mutableValue = value
        NSDecimalRound(&roundedValue, &mutableValue, 0, .plain)

        guard roundedValue == value else { return nil }
        return NSDecimalNumber(decimal: value).intValue
    }

    func formatCurrency(_ amount: Decimal?) -> String {
        guard let amount else { return "-" }

        let number = NSDecimalNumber(decimal: amount)
        return currencyFormatter.string(from: number) ?? number.stringValue
    }
}

private extension MoneyFormatter {
    static func makeDecimalFormatter(locale: Locale) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true
        return formatter
    }

    static func makeCurrencyFormatter(locale: Locale) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        formatter.generatesDecimalNumbers = true
        return formatter
    }
}
