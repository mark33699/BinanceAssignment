//
//  String+Ext.swift
//  BinanceAssignment
//
//  Created by 謝飛飛 on 2019/12/16.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import Foundation

extension String
{
    func substring(cut index: Int) -> String
    {
        let end = self.index(self.endIndex, offsetBy: -index)
        let newString = self[self.startIndex..<end]
        return String(newString)
    }
}
