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
        
        return buffer
    }
}
