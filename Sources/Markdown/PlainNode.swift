//
//  PlainNode.swift
//  SwfitOOO
//
//  Created by Hale Chan on 2016/11/19.
//  Copyright © 2016年 Hale Chan. All rights reserved.
//

class PlainNode : Node {
    var raw: String.CharacterView
    var hasNewLine = false

    init(_ raw: String.CharacterView, _ hasNewLine:Bool = false) {
        self.raw = raw
        self.hasNewLine = hasNewLine;
    }
    
    func render() -> String {
        return String(raw) + (self.hasNewLine ? "\n" : "")
    }
}
