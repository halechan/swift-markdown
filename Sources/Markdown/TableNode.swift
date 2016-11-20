//
//  TableNode.swift
//  SwfitOOO
//
//  Created by Hale Chan on 2016/11/19.
//  Copyright © 2016年 Hale Chan. All rights reserved.
//

enum ParseError: Error {
    case invalid
}

class TableNode : Node {
    enum Alignment {
        case Left;
        case Center;
        case Right;
        
        func style() -> String {
            let result: String
            switch self {
            case .Center:
                result = "style='text-align: center'"
            case .Right:
                result = "style='text-align: right'"
            default:
                result = "style='text-align: left'"
            }
            
            return result
        }
    }
    
    var headers:[Node] = []
    var aligns:[Alignment] = []
    var rows:[[Node]] = []
    
    func append(_ line:String.CharacterView) -> Bool {
        
        return false
    }
    
    func valid() -> Bool {
        return headers.count > 0 && aligns.count > 0 && rows.count > 0
    }
    
    func renderHeader() -> String {
        var content = "  <thead>\n    <tr>\n"
        for index in 0..<self.aligns.count {
            let style = self.aligns[index].style()
            let item = self.headers[index]
            content += "      <th \(style)>" + item.render() + "</th>\n"
        }
        return content + "    </tr>\n  </thead>\n"
    }
    
    func renderRow(_ row: [Node]) -> String {
        var content = "    <tr>\n"
        for index in 0..<self.aligns.count {
            let style = self.aligns[index].style()
            if index >= row.count {
                content += "      <th \(style)>" + "</th>\n"
            } else {
                let item = row[index]
                content += "      <th \(style)>" + item.render() + "</th>\n"
            }
        }
        return content + "    </tr>\n"
    }
    
    override func  render() -> String {
        let head = renderHeader()
        let rows = self.rows.map { row in
            return renderRow(row)
            }.joined()
        
        return "<table>\n" + head + "  <tbody>\n" + rows + "  </tbody>\n" + "</table>"
    }
}

func parseAlign(_ item : String.CharacterView) -> TableNode.Alignment? {
    var start = item.startIndex
    var end = item.index(before: item.endIndex)
    
    func isEmptyChar(_ c:Character) -> Bool {
        return c == " " || c == "\t" || c == "\n"
    }
    
    while start < item.endIndex && isEmptyChar(item[start]) {
        start = item.index(after: start)
    }
    
    while end >= item.startIndex && isEmptyChar(item[end]) {
        end = item.index(before: end)
    }
    
    if end >= start {
        let hasPrefix = item[start] == ":"
        if hasPrefix {
            start = item.index(after: start)
        }
        
        let hasSuffix = item[end] == ":"
        if hasSuffix {
            end = item.index(before: end)
        }
        
        var valid = false
        while start <= end {
            if item[start] == "-" {
                valid = true
                start = item.index(after: start)
            } else {
                valid = false
                break
            }
        }
        
        if valid {
            var align = TableNode.Alignment.Left
            if hasPrefix && hasSuffix {
                align = TableNode.Alignment.Center
            } else if hasSuffix {
                align = TableNode.Alignment.Right
            }
            
            return align
        }
    }
    
    return nil
}

func parseAligns(_ l : String.CharacterView) -> [TableNode.Alignment]? {
    do {
        try l.forEach { char in
            if !(char == " " || char == "\t" || char == ":" || char == "|" || char == "-" || char == "\n") {
                throw ParseError.invalid
            }
        }
    } catch {
        return nil
    }
    
    let list = l.split(separator: "|")
    if list.count < 2 {
        return nil
    }
    
    var aligns: [TableNode.Alignment] = []
    for item in list {
        if let align = parseAlign(item) {
            aligns.append(align)
        } else {
            return nil
        }
    }
    
    return aligns
}
