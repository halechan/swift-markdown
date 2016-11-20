//
//  Markdown.swift
//  Hello
//
//  Created by Hale Chan on 2016/11/9.
//
//

import cmark

public class Markdown {
    public class func convert(_ s:String) -> String? {
        return self.gfm(s)
//        var buffer: String?
//        do {
//            try s.withCString { p in
//                guard let htmlBuf = cmark_markdown_to_html(p, Int(strlen(p)), 0) else {
//                    throw MarkdownError.failed
//                }
//                
//                buffer = String(cString: htmlBuf)
//                free(htmlBuf)
//            }
//        } catch {}
//        
//        if (buffer != nil) {
//            buffer = self.gfm(buffer!)
//        }
//        
//        return buffer
    }
    
    class func gfm(_ s: String) -> String {
        let scanner = Scanner(s)
        var nodes:[Node] = []
        
        var parsing = true
        while parsing {
            if let line = scanner.readLine() {
                
                if line.contains("|") {
                    if let nextLine = scanner.readLine() {
                        if let aligns = parseAligns(nextLine) {
                            var rows: [[Node]] = []
                            while let nextLine = scanner.readLine() {
                                if nextLine.contains("|") {
                                    let row = nextLine.split(separator: "|").map { item in
                                        return PlainNode(item.trim(" \t\n"))
                                    }
                                    rows.append(row)
                                } else {
                                    scanner.moveToPreviousLine()
                                    break
                                }
                            }
                            
                            let table = TableNode()
                            table.aligns = aligns
                            
                            table.headers = line.split(separator: "|").map { item in
                                return PlainNode(item.trim(" \t\n"))
                            }
                            
                            table.rows = rows
                            
                            nodes.append(table)
                        } else {
                            let node = PlainNode(line)
                            nodes.append(node)
                            scanner.moveToPreviousLine()
                        }
                    }
                    else {
                        let node = PlainNode(line)
                        nodes.append(node)
                    }
                } else {
                    let node = PlainNode(line)
                    nodes.append(node)
                }
            } else {
                parsing = false
            }
        }
        
        let html = nodes.map { item in
            return item.render()
        }.joined()
        
        return html
    }
}
