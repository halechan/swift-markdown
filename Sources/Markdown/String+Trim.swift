//
//  String+Trim.swift
//  SwfitOOO
//
//  Created by Hale Chan on 2016/11/19.
//  Copyright © 2016年 Hale Chan. All rights reserved.
//

extension String.CharacterView {
    func trim(_ s:String) -> String.CharacterView {
        let list = s.characters.map { item in
            return item
        }
        
        var start = self.startIndex
        while start < self.endIndex && list.contains(self[start]) {
            start = self.index(after: start)
        }
        
        var end = self.index(before: self.endIndex)
        while end >= self.startIndex && list.contains(self[end]) {
            end = self.index(before: end)
        }
        
        return self[start...end]
    }
}
