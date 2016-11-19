//
//  String+Trim.swift
//  SwfitOOO
//
//  Created by Hale Chan on 2016/11/19.
//  Copyright © 2016年 Hale Chan. All rights reserved.
//

//extension String {
//    func trim(_ s:String) -> String {
//        let list = self.characters.map { item in
//            return String(item)
//        }
//        
//        var start = 0
//        while start < list.count && s.contains(list[start]) {
//            start += 1
//        }
//        
//        var end = list.count - 1
//        while end >= 0 && s.contains(list[end]) {
//            end -= 1
//        }
//        
//        if end >= start {
//            return list[start...end].joined()
//        }
//        
//        return ""
//    }
//}
