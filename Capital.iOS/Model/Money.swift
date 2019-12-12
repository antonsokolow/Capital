//
//  Money.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 29/01/2019.
//  Copyright © 2019 Anton Sokolov. All rights reserved.
//

import Foundation

enum Currency: String, CaseIterable {
    case AED
    case AFN
    case ALL
    case AMD
    case ANG
    case AOA
    case ARS
    case AUD
    case AWG
    case AZN
    case BAM
    case BBD
    case BDT
    case BGN
    case BHD
    case BIF
    case BMD
    case BND
    case BOB
    case BRL
    case BSD
    case BTC
    case BTN
    case BWP
    case BYN
    case BYR
    case BZD
    case CAD
    case CDF
    case CHF
    case CLF
    case CLP
    case CNY
    case COP
    case CRC
    case CUC
    case CUP
    case CVE
    case CZK
    case DJF
    case DKK
    case DOP
    case DZD
    case EGP
    case ERN
    case ETB
    case EUR
    case FJD
    case FKP
    case GBP
    case GEL
    case GGP
    case GHS
    case GIP
    case GMD
    case GNF
    case GTQ
    case GYD
    case HKD
    case HNL
    case HRK
    case HTG
    case HUF
    case IDR
    case ILS
    case IMP
    case INR
    case IQD
    case IRR
    case ISK
    case JEP
    case JMD
    case JOD
    case JPY
    case KES
    case KGS
    case KHR
    case KMF
    case KPW
    case KRW
    case KWD
    case KYD
    case KZT
    case LAK
    case LBP
    case LKR
    case LRD
    case LSL
    case LTL
    case LVL
    case LYD
    case MAD
    case MDL
    case MGA
    case MKD
    case MMK
    case MNT
    case MOP
    case MRO
    case MUR
    case MVR
    case MWK
    case MXN
    case MYR
    case MZN
    case NAD
    case NGN
    case NIO
    case NOK
    case NPR
    case NZD
    case OMR
    case PAB
    case PEN
    case PGK
    case PHP
    case PKR
    case PLN
    case PYG
    case QAR
    case RON
    case RSD
    case RUB
    case RWF
    case SAR
    case SBD
    case SCR
    case SDG
    case SEK
    case SGD
    case SHP
    case SLL
    case SOS
    case SRD
    case STD
    case SVC
    case SYP
    case SZL
    case THB
    case TJS
    case TMT
    case TND
    case TOP
    case TRY
    case TTD
    case TWD
    case TZS
    case UAH
    case UGX
    case USD
    case UYU
    case UZS
    case VEF
    case VND
    case VUV
    case WST
    case XAF
    case XAG
    case XAU
    case XCD
    case XDR
    case XOF
    case XPF
    case YER
    case ZAR
    case ZMK
    case ZMW
    case ZWL
}

struct ExchangeRate: Hashable {
    let currency: Currency
    let rate: Decimal
    
    var inverseRate: Decimal {
        get{
            return 1/rate
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(currency)
    }

}

func ==(lhs: ExchangeRate, rhs: ExchangeRate) -> Bool {
    return lhs.currency == rhs.currency
}

struct Money: Comparable {
    let money: (Decimal, Currency)
    
    init(amt: Int, currency: Currency) {
        money = (Decimal(amt), currency)
        
    }
    
    init(amt: Decimal, currency: Currency) {
        money = (amt, currency)
    }
    
    init(amt: Double, currency: Currency) {
        let amount: Decimal = Decimal(string: String(format: "%.2f", amt)) ?? 0
        money = (amount, currency)
        
    }
    
    var amount: Decimal {
        get {
            let double = (money.0 as NSDecimalNumber).doubleValue
            return Decimal(round(100*double)/100)
        }
    }
    
    var amountInBaseCurrency: Decimal {
        get {
            let curr_exchange_rate = Money.exchange_rates.filter { (er) -> Bool in
                return (er.currency == self.currency)
            }
            
            guard let er = curr_exchange_rate.first else {
                return amount
            }
            
            return self.amount * er.inverseRate
            
//            if er.currency == self.currency {
//                return self.amount * er.rate
//            }
//            else{
//                return self.amount * er.inverseRate
//            }
        }
    }
    
    var currency: Currency {
        get{
            return money.1
        }
    }
    
    static var baseCurrencyCode: String {
        get {
            if let currencyCode = Locale.current.currencyCode {
                return currencyCode
            } else {
                return "RUB"
            }
        }
    }
    
    static var baseCurrency: Currency {
        get {
            if let currencyCode = Locale.current.currencyCode, let currency = Currency(rawValue: currencyCode) {
                return currency
            } else {
                return Currency.RUB
            }
        }
    }
}


extension Money {
    static var exchange_rates = ExchangeRates.shared.exchange_rates
    
    var formattedString: String {
        //return Formatter.stringFormatters.string(for: self) ?? ""
        
        let formatter = NumberFormatter()
        formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
        formatter.numberStyle = .currency
        formatter.currencyCode = self.currency.rawValue
        //formatter.currencySymbol = self.currency.rawValue
        if let formattedAmount = formatter.string(from: self.amount as NSNumber) {
            return ("\(formattedAmount)")
        } else {
            return ("\(self)")
        }
    }
}



extension Money: CustomStringConvertible{
    var description: String {
        get{
            return "\(amount) \(currency)"
        }
    }
}


extension ExchangeRate: CustomStringConvertible{
    var description: String {
        get{
            return "\(currency)-\(Money.baseCurrency): \(rate)"
        }
    }
}

func ==(lhs:Money, rhs:Money)->Bool{
    if lhs.amount == rhs.amount &&
        lhs.currency == rhs.currency {
        return true
    }
    
    return false
}

func <(lhs:Money, rhs:Money)->Bool{
    if lhs.currency == rhs.currency && lhs.amount < rhs.amount{
        return true
    }
    
    return false
}


func *(lhs: Money, rhs: Money)->Money{
    if lhs.currency == rhs.currency{
        let amount = lhs.amount * rhs.amount
        
        return Money(amt: amount, currency: lhs.currency)
    }
    
    return Money(amt: 0.0, currency: lhs.currency)
}

func *(lhs:Money, rhs: Decimal)->Money{
    let amount = lhs.amount * rhs
    return Money(amt: amount, currency: lhs.currency)
}

func *(lhs:Decimal, rhs: Money)->Money{
    let amount = lhs * rhs.amount
    return Money(amt: amount, currency: rhs.currency)
}

func /(lhs:Money, rhs:Money)->Money{
    if lhs.currency == rhs.currency, rhs.amount != 0.00 {
        let amount = lhs.amount / rhs.amount
        
        return Money(amt: amount, currency: lhs.currency)
    }
    
    return Money(amt: 0.0, currency: lhs.currency)
    
}

func /(lhs:Money, rhs: Decimal)->Money{
    if rhs != 0.00{
        let amount = lhs.amount / rhs
        return Money(amt: amount, currency: lhs.currency)
    }
    
    return Money(amt: 0.00, currency: lhs.currency)
}

func /(lhs:Decimal, rhs: Money)->Money{
    if rhs.amount != 0.00{
        let amount = lhs / rhs.amount
        return Money(amt: amount, currency: rhs.currency)
    }
    
    return Money(amt: 0.00, currency: rhs.currency)
}


func +(lhs:Money, rhs:Money) -> Money {
    if lhs.currency == rhs.currency {
        let amount = lhs.amount + rhs.amount
        
        return Money(amt: amount, currency: lhs.currency)
    }
    
//    let rub_usd = ExchangeRate(currencyOne: Money.baseCurrency, currencyTwo: .USD, rate: 0.015218)
//    let rub_eur = ExchangeRate(currencyOne: Money.baseCurrency, currencyTwo: .EUR, rate: 0.013435)
//    Money.exchange_rates.insert(rub_usd)
//    Money.exchange_rates.insert(rub_eur)
    let sum = lhs.amountInBaseCurrency + rhs.amountInBaseCurrency
    return Money(amt: sum, currency: Money.baseCurrency)
    
}

func +(lhs:Money, rhs: Decimal)->Money{
    let amount = lhs.amount + rhs
    return Money(amt: amount, currency: lhs.currency)
}

func +(lhs:Decimal, rhs: Money)->Money{
    let amount = lhs + rhs.amount
    return Money(amt: amount, currency: rhs.currency)
}


func -(lhs:Money, rhs:Money)->Money{
    if lhs.currency == rhs.currency{
        let amount = lhs.amount - rhs.amount
        
        return Money(amt: amount, currency: lhs.currency)
    }
    
    return Money(amt: 0.0, currency: lhs.currency)
    
}

func -(lhs:Money, rhs: Decimal)->Money{
    let amount = lhs.amount - rhs
    return Money(amt: amount, currency: lhs.currency)
}

func -(lhs:Decimal, rhs: Money)->Money{
    let amount = lhs - rhs.amount
    return Money(amt: amount, currency: rhs.currency)
}

