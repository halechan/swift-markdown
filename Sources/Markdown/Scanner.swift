//
//  Scanner.swift
//  Markdown
//
//  Created by Hale Chan on 2016/11/20.
//
//

public enum MarkdownError: Error {
    case failed
}

class Scanner {
    typealias CharacterView = String.CharacterView
    typealias Index = CharacterView.Index
    
    var buffer: String.CharacterView
    var nextIndex: String.CharacterView.Index
    
    init(_ s: String) {
        buffer = s.characters
        nextIndex = buffer.startIndex
    }
    
    init(_ s: String.CharacterView) {
        buffer = s
        nextIndex = s.startIndex
    }
    
    func next(_ match: (Character) -> Bool) -> Index? {
        var index = self.nextIndex
        while index < buffer.endIndex && !match(buffer[index]) {
            index = buffer.index(after: index)
        }
        
        if index == buffer.endIndex {
            return nil
        }
        
        return index
    }
    
    func next(sliceLength:Int , _ match: (String.CharacterView) -> Bool) -> Index? {
        var start = self.nextIndex
        var end = self.buffer.index(start, offsetBy: sliceLength)
        
        while end < self.buffer.endIndex && !match(self.buffer[start..<end])  {
            start = self.buffer.index(after: start);
            end = self.buffer.index(after: end);
        }
        
        if end > self.buffer.endIndex {
            return nil
        }
        
        return start
    }
    
    func next(_ match: Character) -> Index? {
        return next { item in
            return item == match
        }
    }
    
    func next(_ match: String) -> Index? {
        return next(sliceLength: match.characters.count) { item in
            return String(item) == match
        }
    }
    
    func previous(_ match: Character) -> Index? {
        return previous { item in
            return item == match
        }
    }
    
    func previous(_ match: String) -> Index? {
        return previous(sliceLength: match.characters.count) { item in
            return String(item) == match
        }
    }
    
    func previous(_ match: (Character) -> Bool) -> Index? {
        var index = self.buffer.index(before: self.nextIndex)
        while index >= self.buffer.startIndex && !match(self.buffer[index]) {
            index = self.buffer.index(before: index)
        }
        
        if index < self.buffer.startIndex {
            return nil
        }
        
        return index
    }
    
    func previous(sliceLength:Int, _ match: (String.CharacterView) -> Bool) -> Index? {
        var start = self.buffer.index(self.nextIndex, offsetBy: sliceLength)
        var end = self.nextIndex
        
        while start >= self.buffer.startIndex && !match(self.buffer[start..<end])  {
            start = self.buffer.index(before: start);
            end = self.buffer.index(before: end);
        }
        
        if start < self.buffer.startIndex {
            return nil
        }
        
        return start
    }
}

extension Scanner {
    func readLine() -> CharacterView? {
        if self.nextIndex >= self.buffer.endIndex {
            return nil
        }
        
        if let end = self.next(Character("\n")) {
            let start = self.nextIndex
            self.nextIndex = self.buffer.index(after: end)
            return self.buffer[start...end]
        } else if self.nextIndex < self.buffer.endIndex {
            let start = self.nextIndex
            self.nextIndex = self.buffer.endIndex
            return self.buffer[start..<self.buffer.endIndex]
        } else {
            return nil
        }
    }
    
    func moveToStartOfLine() {
        if let end = self.previous(Character("\n")) {
            self.nextIndex = self.buffer.index(after: end)
            return
        }
        
        self.nextIndex = self.buffer.startIndex
    }
    
    func moveToNextLine() {
        if let lineEnd = self.next(Character("\n")) {
            self.nextIndex = self.buffer.index(after: lineEnd)
            return
        }
        
        self.nextIndex = self.buffer.endIndex
    }
    
    func moveToPreviousLine() {
        if let nextEnd = self.previous(Character("\n")) {
            self.nextIndex = nextEnd
            if let nextStart = self.previous(Character("\n")) {
                self.nextIndex = self.buffer.index(after: nextStart)
                return
            }
        }
        
        self.nextIndex = self.buffer.startIndex
    }
}
