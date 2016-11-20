//
//  ListNode.swift
//  Markdown
//
//  Created by Hale Chan on 2016/11/20.
//
//

class ListItemNode: PlainNode {
    public override func render() -> String {
        return "<li>" + String(self.raw) + "</li>\n"
    }
}

class ListNode: Node {
    var level: Int = 0
    var ordered: Bool = false
    
    public override func render() -> String {
        let name = ordered ? "ol" : "ul"
        let space = level > 0 ? String(repeating: "  ", count: level) : ""
        let levelPrefix = level > 0 ? "<li>\n" : ""
        let levelSuffix = level > 0 ? "</li>\n" : ""
        let content = self.children.map { item in
            return space + "  " + item.render()
        }.joined()
        return levelPrefix + "\(space)<\(name)>\n" + content + "\(space)</\(name)>\n" + space + levelSuffix
    }
}
