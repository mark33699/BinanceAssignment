//
//  Array+Ext.swift
//  BinanceAssignment
//
//  Created by iOS_Mark on 2019/12/13.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return (0 <= index && index < count) ? self[index] : nil
    }
}
