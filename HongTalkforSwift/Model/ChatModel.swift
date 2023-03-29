//
//  CharModel.swift
//  HongTalkforSwift
//
//  Created by 홍정민 on 2023/03/29.
//

import UIKit

@objcMembers
class ChatModel: NSObject {
    public var users: Dictionary<String,Bool> = [:] // 채팅방에 참여한 사람들
    public var comments: Dictionary<String,Comment> = [:] // 채팅방 대화 내용들
    
    public class Comment {
        public var uid: String?
        public var message: String?
    }
}
