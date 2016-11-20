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
            } else if let list = readList(line) {
                self.rootNode.children.append(list)
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
    
    func parseQuote(_ startLine: String.CharacterView) -> Node? {
        let quotePrefix = "< "
        
        if !startLine.hasPrefix(quotePrefix) {
            return nil
        }
        
        class QuoteBlock {
            let level: Int
            var content: String.CharacterView?
            weak var parent: QuoteBlock?
            var children: [QuoteBlock] = []
            init(level:Int = 0, parent: QuoteBlock? = nil, content: String.CharacterView? = nil) {
                self.level = level
                self.parent = parent
                self.content = content
            }
        }
        
        func parseQuoteLine(_ raw: String.CharacterView) -> (Int, String.CharacterView) {
            var level = 0
            var content = raw
            
            while content.hasPrefix(quotePrefix) {
                level += 1
                content = content.suffix(from: content.index(content.startIndex, offsetBy: 2))
            }
            
            return (level, content)
        }
        
        let (_, firstContent) = parseQuoteLine(startLine)
        
        var rootQuote = QuoteBlock()
        var currentQuote = QuoteBlock(level: 1, parent: rootQuote, content: firstContent)
        rootQuote.children.append(currentQuote)//the leaf node
        
        while let line = self.scanner.readLine() {
            if line.hasPrefix(quotePrefix) {
                let (level, content) = parseQuoteLine(line)
                while currentQuote.level >= level {
                    if let parent = currentQuote.parent {
                        currentQuote = parent
                    } else {
                        break
                    }
                }
                
                currentQuote.children.append(QuoteBlock(level: level, parent: currentQuote, content: content))
            } else {
                self.scanner.moveToPreviousLine()
                break
            }
        }
        
        return nil
    }
    
    func parseLines(_ lines:[String.CharacterView]) -> [Node] {
        return []
    }
    
    func parseOrderList(_ startLine:Line) -> Node? {
        return nil
    }
    
    func parseUnorderList(_ startLine:Line) -> Node? {
        let quotePrefix = "* "
        
        if !startLine.hasPrefix(quotePrefix) {
            return nil
        }
        
        return nil
    }
    
    func parseListLine(_ startLine:Line) -> (Int, Bool, Line)? {
        let scanner = Scanner(startLine)
        
        if let firstNonTabIndex = scanner.next({return $0 != "\t"}) {
            let tabCount = scanner.buffer.distance(from: scanner.buffer.startIndex, to: firstNonTabIndex)
            let sub = startLine.suffix(from: firstNonTabIndex)
            
            if sub.hasPrefix("* ") || sub.hasPrefix("- ") {
                let content = startLine.suffix(from: startLine.index(startLine.startIndex, offsetBy: 2))
                
                return (tabCount, false, content)
            }
            
            scanner.nextIndex = firstNonTabIndex
            if let dotIndex = scanner.next(". ") {
                let numberSlice = startLine[firstNonTabIndex..<dotIndex]
                if numberSlice.count > 0 {
                    if let num = Int(String(numberSlice)) {
                        let content = startLine.suffix(from: startLine.index(dotIndex, offsetBy: 2))
                        return (tabCount, true, content)
                    }
                }
            }
        }
        
        return nil
    }
    
    func readList(_ startLine: Line) -> Node? {
        if let (level, ordered, content) = parseListLine(startLine) {
            if 0 != level {
                return nil
            }
            
            var rootNode = ListNode()
            rootNode.ordered = ordered
            rootNode.level = level
            rootNode.children.append(ListItemNode(content.trim("\n \t")))
            
            var currentList = rootNode
            
            while let line = self.scanner.readLine() {
                if let (level, ordered, content) = parseListLine(line) {
                    while currentList.level > level {
                        currentList = currentList.parent! as! ListNode
                    }
                    
                    //same level, so insert one item
                    if currentList.level == level {
                        currentList.children.append(ListItemNode(content.trim("\n \t")))
                    } else {
                        //smallLevel, so insert one list
                        var smallList = ListNode()
                        smallList.level = level
                        smallList.ordered = ordered
                        smallList.children.append(ListItemNode(content.trim("\n \t")))
                        smallList.parent = currentList
                        
                        currentList.children.append(smallList)
                        
                        currentList = smallList
                    }
                    
                    //order?
                } else {
                    self.scanner.moveToPreviousLine()
                    break
                }
            }
            
            return rootNode
        }
        
        return nil
    }
}
