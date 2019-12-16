//
//  Double+Ext.swift
//  BinanceAssignment
//
//  Created by 謝飛飛 on 2019/12/15.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import Foundation

extension Double
{
    func ceiling(toDecimal decimal: Int) -> Double
    {
        let numberOfDigits = abs(pow(10.0, Double(decimal)))
        if self.sign == .minus
        {
            return Double(Int(self * numberOfDigits)) / numberOfDigits
        }
        else
        {
            return Double(ceil(self * numberOfDigits)) / numberOfDigits
        }
    }
    
    func rounding(toDecimal decimal: Int) -> Double
    {
        let numberOfDigits = pow(10.0, Double(decimal))
        return (self * numberOfDigits).rounded(.toNearestOrAwayFromZero) / numberOfDigits
    }
}
