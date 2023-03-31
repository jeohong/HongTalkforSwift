//
//  NotificationModel.swift
//  HongTalkforSwift
//
//  Created by 홍정민 on 2023/03/30.
//

import ObjectMapper

@objcMembers
// TODO: 노티피케이션 모델 수정 -> Message { token, Notification { title, body, data } }
class NotificationModel: Mappable {
    public var to: String?
    public var notification: Notification = Notification()
    public var data: Data = Data()
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        to <- map["to"]
        notification <- map["notification"]
        data <- map["data"]
    }
    
    class Notification: Mappable {
        public var title: String?
        public var body: String?
        
        init() {
            
        }
        
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            title <- map["title"]
            body <- map["body"]
        }
    }
    
    class Data: Mappable {
        public var title: String?
        public var body: String?
        
        init() {
            
        }
        
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            title <- map["title"]
            body <- map["body"]
        }
    }
}
