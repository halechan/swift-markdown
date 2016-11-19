//
//  PlainNode.swift
//  SwfitOOO
//
//  Created by Hale Chan on 2016/11/19.
//  Copyright © 2016年 Hale Chan. All rights reserved.
//

class PlainNode : Node {
    let raw: String.CharacterView
    init(_ raw: String.CharacterView) {
        self.raw = raw
    }
    
    func render() -> String {
        return String(raw)
    }
}
