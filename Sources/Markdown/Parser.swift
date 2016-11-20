//
//  Parser.swift
//  Markdown
//
//  Created by Hale Chan on 2016/11/20.
//
//

public class Parser {
    public static let WhiteSpace = " \t\n"
    
    typealias Line = String.CharacterView
    
    var scanner: Scanner
    public var rootNode: Node
    
    public func parse() {
        while var line = self.scanner.readLine() {
            if let hx = parserHx(line) {
                self.rootNode.children.append(hx)
            } else if let table = parseTable(line) {
                self.rootNode.children.append(table)
            } else if let codeBlock = parseCodeBlock(line) {
                self.rootNode.children.append(codeBlock)
            } else {
                self.rootNode.children.append(PlainNode(line))
            }
        }
    }
    
    public init(_ s: String) {
        scanner = Scanner(s)
        rootNode = Node()
        self.parse()
    }
    
    func parseInline(_ s: String.CharacterView) -> Node? {
        return nil
    }
    
    func parserHx(_ startLine: Line) -> HxNode? {
        let lineScanner = Scanner(startLine)
        
        if let index = lineScanner.next ({ $0 != "#"}) {
            let level = lineScanner.buffer.distance(from: lineScanner.buffer.startIndex, to: index)
            if level == 0 {
                return nil
            }
            
            let content = startLine.suffix(from: index).trim(Parser.WhiteSpace)
            return HxNode(level: level, content: PlainNode(content))
        }
        
        return nil
    }
    
    func parseTable(_ startLine: Line) -> TableNode? {
        if !startLine.contains("|") {
            return nil
        }
        
        let line = startLine
        let scanner = self.scanner
        
        if let nextLine = scanner.readLine() {
            if let aligns = parseAligns(nextLine) {
                var rows: [[Node]] = []
                while let nextLine = scanner.readLine() {
                    if nextLine.contains("|") {
                        let row = nextLine.split(separator: "|").map { item in
                            return PlainNode(item.trim(Parser.WhiteSpace))
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
                    return PlainNode(item.trim(Parser.WhiteSpace))
                }
                
                table.rows = rows
                
                return table
            }
            
            scanner.moveToPreviousLine()
        }
        
        return nil
    }
    
    func parseCodeBlock(_ startLine: Line) -> Node? {
        if !startLine.hasPrefix("```") {
            return nil
        }
        
        var language: String?
        if startLine.count > 3 {
            let langIndex = startLine.index(startLine.startIndex, offsetBy: 3)
            language = String(startLine[langIndex..<startLine.endIndex].trim(Parser.WhiteSpace))
        }
        
        let codeStartIndex = self.scanner.nextIndex
        let codeEndIndex = self.scanner.next("```") ?? self.scanner.buffer.endIndex
        self.scanner.nextIndex = codeEndIndex
        self.scanner.moveToNextLine()
        
        let content = String(self.scanner.buffer[codeStartIndex..<codeEndIndex])
        
        if let lang = language {
            return CodeBlockNode(content: content, language: lang)
        } else {
            return CodeBlockNode(content: content)
        }        
    }
    
//    func parseQuote(_ s: String.CharacterView) -> Node {
//
//    }
//
//    func parseList(_ s: String.CharacterView) -> Node {
//
//    }
}
