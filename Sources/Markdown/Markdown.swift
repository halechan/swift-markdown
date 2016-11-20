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
        var buffer: String?
        do {
            try s.withCString { p in
                guard let htmlBuf = cmark_markdown_to_html(p, Int(strlen(p)), 0) else {
                    throw MarkdownError.failed
                }
                
                buffer = String(cString: htmlBuf)
                free(htmlBuf)
            }
        } catch {}
        
        if (buffer != nil) {
            buffer = self.gfm(buffer!)
        }
        
        return buffer
    }
    
    class func gfm(_ s: String) -> String {
        let scanner = Scanner(s)
        var nodes:[Node] = []
        
        var parsing = true
        while parsing {
            if let line = scanner.readLine() {
                if line.contains("|") {
                    if let aligns = parseAligns(scanner.readLine()!) {
                        var rows: [[Node]] = []
                        while let nextLine = scanner.readLine() {
                            if nextLine.contains("|") {
                                let row = nextLine.split(separator: "|").map { item in
                                    return PlainNode(item.trim(" \t"))
                                }
                                rows.append(row)
                            } else {
                                scanner.moveToPreviousLine()
                                break
                            }
                        }
                        
                        let table = TableNode()
                        table.aligns = aligns
                        
                        var cleanLine = line;
                        
                        if String(cleanLine).hasPrefix("<p>") {
                            cleanLine = line.suffix(from: line.index(line.startIndex, offsetBy: 3))
                        }
                        
                        table.headers = cleanLine.split(separator: "|").map { item in
                            return PlainNode(item.trim(" \t"))
                        }
                        
                        table.rows = rows
                        
                        if let lastItem = table.rows.last?.last as? PlainNode {
                            if lastItem.render().hasSuffix("</p>") {
                                lastItem.raw = lastItem.raw.prefix(lastItem.raw.count - 4)
                            }
                        }
                        
                        nodes.append(table)
                    } else {
                        let node = PlainNode(line, true)
                        nodes.append(node)
                        scanner.moveToPreviousLine()
                    }
                } else {
                    let node = PlainNode(line, true)
                    nodes.append(node)
                }
            } else {
                parsing = false
            }
        }
        
        let html = nodes.map { item in
            return item.render()
        }.joined()
        
        return html;
    }
}
