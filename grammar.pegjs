
{
  var stack = [];
}

Expression = blocks:Statement+ { return blocks.filter(function (b) { return b !== undefined})}

LineEnd = continuingLineEnd / ! .
continuingLineEnd = '\n' / '\r\n'
Whitespace = [ \t]
__ = Whitespace*
identifier = id:[a-zA-Z_]+ { return id.join("").toLowerCase() }

Statement = Comment / Block / Line / BlankLine
  BlankLine = __ continuingLineEnd { return undefined}
  Block = start:BlockStart content:Statement* end:BlockEnd { return {id: start.id, args: start.args, content: content.filter(function (b) { return b !== undefined}) } }
    BlockStart = __ '<' __ id:identifier args:blockArg* __ '>' __ LineEnd { stack.push(id); return {id: id, args: args} }
      blockArg = Whitespace+ arg:blockArgBlock { return arg }
    BlockEnd = __ '</' id:identifier '>' __ LineEnd & { var result = stack.pop() === id; return result; }
  Line = __ id:identifier args:lineArg+ __  LineEnd { return { id:id, args: args } }
    lineArg = Whitespace+ arg:argBlock { return arg }
  Comment = __ '#' txt:[^\n]* LineEnd { return {comment: txt.join("") }}

blockArgBlock = '"' s:doubleQuoteStr* '"' { return s.join("") }
              / "'" s:singleQuoteStr* "'"  { return s.join("") }
              / s:unQuotedBlockArgChar*  { return s.join("") }

argBlock = '"' s:doubleQuoteStr* '"' { return s.join("") }
         / "'" s:singleQuoteStr* "'"  { return s.join("") }
         / s:unQuotedLineArgChar*  { return s.join("") }

escapedLineTerminator = '\\\n' { return ""} / '\\\r\n' { return ""}
unQuotedLineArgChar = escapedLineTerminator 
                    / [^ \t\r\n]
unQuotedBlockArgChar = escapedLineTerminator 
                    / [^ \t\r\n>]
doubleQuoteStr = escapedLineTerminator
               / '\\"' { return '"'  }
               / [^\\"]
singleQuoteStr = escapedLineTerminator
               / "\\'" { return "'"  }
               / [^\\']
