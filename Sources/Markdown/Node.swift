//
//  Node.swift
//  SwfitOOO
//
//  Created by Hale Chan on 2016/11/19.
//  Copyright © 2016年 Hale Chan. All rights reserved.
//

public protocol NodeProtocol {
    func render() -> String
}

public class Node : NodeProtocol {
    var children: [Node] = []
    
    public func render() -> String {
        return children.map { item in
            return item.render()
        }.joined()
    }
}
