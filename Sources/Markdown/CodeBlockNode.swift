//
//  CodeBlockNode.swift
//  Markdown
//
//  Created by Hale Chan on 2016/11/20.
//
//

class CodeBlockNode: Node {
    let language:String
    let content:String
    init(content:String = "", language: String = "none") {
        if language.characters.count > 0 {
            self.language = language
        } else {
            self.language = "none"
        }
        
        self.content = content
    }
    
    public override func render() -> String {
        return "<pre><code class=\"language-\(self.language)\">" + self.content + "</code></pre>\n"
    }
}
