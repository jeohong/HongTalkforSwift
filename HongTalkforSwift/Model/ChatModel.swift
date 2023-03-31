//
//  CharModel.swift
//  HongTalkforSwift
//
//  Created by 홍정민 on 2023/03/29.
//

import ObjectMapper

@objcMembers
class ChatModel: Mappable {
    public var users: Dictionary<String,Bool> = [:] // 채팅방에 참여한 사람들
    public var comments: Dictionary<String,Comment> = [:] // 채팅방 대화 내용들
    
    required init?(map: ObjectMapper.Map) {
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        users <- map["users"]
        comments <- map["comments"]
    }
    
    public class Comment: Mappable {
        public var uid: String?
        public var message: String?
        public var timestamp: Int?
        public var readUsers: Dictionary<String,Bool> = [:]

        public required init?(map: ObjectMapper.Map) {
            
        }
        
        public func mapping(map: ObjectMapper.Map) {
            uid <- map["uid"]
            message <- map["message"]
            timestamp <- map["timestamp"]
            readUsers <- map["readUsers"]
        }
        
    }
}
