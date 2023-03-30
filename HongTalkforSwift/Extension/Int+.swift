//
//  Int+.swift
//  HongTalkforSwift
//
//  Created by 홍정민 on 2023/03/30.
//

import Foundation

extension Int {
    var toDayTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = Date(timeIntervalSince1970: Double(self) / 1000)
        
        return dateFormatter.string(from: date)
    }
}
