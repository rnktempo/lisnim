import options
import unicode

var T_LPAREN: string = "LPAREN"
var T_RPAREN: string = "RPAREN"

var T_SYMBOL: string = "SYMBOL"
var T_STRING: string = "STRING"

type
    Token* = object
        tokenType*: Option[string]
        value*: Option[string]

type
    AstNode* = object
        kind*: string      
        value*: Option[string]
        children*: seq[AstNode]

var code: string = "(print \"hola mundo\" ( \"que tal\"))"

proc lex(code:string): seq[Token] =
    var counter: int = 0
    var tokenList: seq[Token] = @[]

    while counter < code.len:

        if code[counter] in {' ', '\n', '\t'}:
            counter.inc()
            continue
        elif code[counter] == '(':
            tokenList.add(Token(tokenType: some(T_LPAREN), value: none(string)))
            counter.inc()
            continue
        elif code[counter] == ')':
            tokenList.add(Token(tokenType: some(T_RPAREN), value: none(string)))
            counter.inc()
            continue
        elif isAlpha(Rune(code[counter])):
            var symbol: string = ""

            while isAlpha(Rune(code[counter])):
                symbol = symbol & code[counter]
                counter.inc()

            tokenList.add(Token(tokenType: some(T_SYMBOL), value: some(symbol)))

            counter.inc()
            continue
        elif code[counter] == '"':
            var stringToken: string = ""
            counter.inc()

            while code[counter] != '"':
                stringToken = stringToken & code[counter]
                counter.inc()

            tokenList.add(Token(tokenType: some(T_STRING), value: some(stringToken)))

            counter.inc()
        else:
            counter.inc()
            continue

    return tokenList

proc parse(tokens: seq[Token]): AstNode = 
    var counter: int = 0

    proc parseExpr(tokens: seq[Token]): AstNode =
        if tokens[counter].tokenType.get() == T_LPAREN:
            counter.inc()
            
            var children: seq[AstNode] = @[]

            while tokens[counter].tokenType.get() != T_RPAREN:
                children.add(parseExpr(tokens))

            counter.inc()
            return AstNode(kind: "list", value: none(string), children: children)
        else:
            let value = tokens[counter].value.get()
            let kind = if tokens[counter].tokenType.get() == T_STRING: "string" else: "symbol"
            counter.inc()

            return AstNode(kind: kind, value: some(value), children: @[])

    return parseExpr(tokens)

let ast = parse(lex(code))

echo ast
