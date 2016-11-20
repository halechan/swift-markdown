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
        
        if start == self.endIndex {
            return self[start..<self.endIndex]
        }
        
        var end = self.index(before: self.endIndex)
        while end > self.startIndex && list.contains(self[end]) {
            end = self.index(before: end)
        }
        
        return self[start...end]
    }
    
    func hasPrefix(_ prefix: String) -> Bool {
        let pattern = prefix.characters
        
        if pattern.count > self.count {
            return false
        }
        
        var index1 = self.startIndex
        for index0 in pattern.indices {
            if pattern[index0] != self[index1] {
                return false
            }
            index1 = self.index(after: index1)
        }
        
        return true
    }
}
