//
//  HxNode.swift
//  Markdown
//
//  Created by Hale Chan on 2016/11/20.
//
//

class HxNode: Node {
    var level : Int = 0
    
    init(level : Int, content: Node) {
        super.init()
        self.level = level
        self.children = [content]
    }
    
    override func render() -> String {
        let hx = "h\(level)"
        return "<\(hx)>" + super.render() + "</\(hx)>"
    }
}
