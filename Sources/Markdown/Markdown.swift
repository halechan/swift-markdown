//
//  Markdown.swift
//  Hello
//
//  Created by Hale Chan on 2016/11/9.
//
//

import cmark

public enum MarkdownError: Error {
    case failed
}

public class Line {
    let raw: String
    init(_ s: String) {
        raw = s
    }
}

class Scanner {
    var lines: [String.CharacterView] = []
    var index: Int = 0
    init(_ s: String) {
        lines = s.characters.split(separator: "\n")
    }
    
    func next() -> String.CharacterView? {
        if index < lines.count {
            let line = lines[index]
            index += 1
            return line
        }
        return nil
    }
}

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
            if let line = scanner.next() {
                if line.contains("|") {
                    if let aligns = parseAligns(scanner.next()!) {
                        var rows: [[Node]] = []
                        while let nextLine = scanner.next() {
                            if nextLine.contains("|") {
                                let row = nextLine.split(separator: "|").map { item in
                                    return PlainNode(item)
                                }
                                rows.append(row)
                            } else {
                                scanner.index -= 1
                                break
                            }
                        }
                        
                        let table = TableNode()
                        table.aligns = aligns
                        table.headers = line.split(separator: "|").map { item in
                            return PlainNode(item)
                        }
                        table.rows = rows
                        
                        nodes.append(table)
                    } else {
                        let node = PlainNode(line)
                        nodes.append(node)
                        scanner.index -=  1
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
        
        return html;
    }
}
