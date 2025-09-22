import options, unicode, strutils

var T_LPAREN: string = "LPAREN"
var T_RPAREN: string = "RPAREN"

var T_SYMBOL: string = "SYMBOL"
var T_STRING: string = "STRING"
var T_NUMBER: string = "NUMBER"

var N_LIST: string = "list"
var N_NUMBER: string = "number"
var N_SYMBOL: string = "symbol"
var N_STRING: string = "string"

type
    Token* = object
        tokenType*: Option[string]
        value*: Option[string]

type
    AstNode* = object
        kind*: string      
        value*: Option[string]
        children*: seq[AstNode]

var code: string = "(print (\"lista de\" (\"textos\")))"
var code2: string = "(print \"hola mundo\")"
var code3: string = "(print (235 2 \"hola\"))"

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
        elif isDigit(code[counter]):
            var numberString: string = ""

            while isDigit(code[counter]):
                numberString = numberString & code[counter]
                counter.inc()

            tokenList.add(Token(tokenType: some(T_NUMBER), value: some(numberString)))
            continue
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
            return AstNode(kind: N_LIST, value: none(string), children: children)
        else:
            let value = tokens[counter].value.get()
            let kind = if tokens[counter].tokenType.get() == T_STRING: N_STRING elif tokens[counter].tokenType.get() == T_NUMBER: N_NUMBER else: N_SYMBOL
            counter.inc()

            return AstNode(kind: kind, value: some(value), children: @[])

    return parseExpr(tokens)

proc interpretAst(ast: AstNode) = 
    var counter: int = 0

    proc printNode(node: AstNode) = 
        if node.kind == N_STRING:
            echo node.value.get()
        elif node.kind == N_NUMBER:
            echo node.value.get()
        elif node.kind == N_LIST:
            for i in node.children:
                printNode(i)
        else:
            echo "Lisnim (Syntax Error): You cannot print this!"

    while counter < ast.children.len:
        if ast.children[counter].kind == "symbol":
            if ast.children[counter].value == some("print"):
                printNode(ast.children[counter + 1])
                counter.inc()

        counter.inc()

let ast = parse(lex(code3))

interpretAst(ast)
