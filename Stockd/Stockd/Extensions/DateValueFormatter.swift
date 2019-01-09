//
//  DateValueFormatter.swift
//  Stockd
//
//  Created by J on 1/8/19.
//  Copyright © 2019 J. All rights reserved.
//

import Foundation
import Charts
public class DateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "MM/dd"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
