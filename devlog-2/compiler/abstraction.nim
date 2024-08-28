include "lexer/lexer.nim"
include "parser/parser.nim"

proc tokenizeString(inputString : string) : seq[tokenTuple] =
    var brokenStrings : seq[string] = substringSplit(inputString, @[' ', '+', '-', '*', '/', ',', '(', ')', ',', '>', '\n'])
    brokenStrings = removeSubstring(brokenStrings, " ")
    brokenStrings = removeSubstring(brokenStrings, "\t")
    var tokenList : seq[tokenTuple]
    tokenizeSOF(tokenList)
    for substring in brokenStrings:
        if fatalError == true:
            return @[]
        if isNumber(substring):
            tokenizeNumber(substring, tokenList)
        else:
            case substring
            of ",":
                tokenizeComma(substring, tokenList)
            of "+", "-", "*", "/":
                tokenizeOperator(substring, tokenList)
            of "(", ")":
                tokenizeParenthesis(substring, tokenList)
            of "\n":
                discard
            of ">":
                tokenizeAngelBrackets(substring, tokenList)
            else:
                tokenizeIdentifier(substring, tokenList)
    tokenizeEof(tokenList)
    return tokenList

proc parsePassOne(tokenList : seq[tokenTuple]) : seq[nodeTuple] =
    if tokenList.len == 0:
        return @[]
    var nodeList : seq[nodeTuple] = @[] 
    var lastToken : tokenTuple = (kind : ttSOF, value : "SOF")
    for token in tokenList:
        case token.kind
        of ttNumber:
            parseNumber(lastToken, token, nodeList)
        of ttPlus, ttMinus, ttTimes, ttDivide:
            parseOperator(lastToken, token, nodeList)
        of ttLParen:
            parseLParen(lastToken, token, nodeList)
        of ttRParen:
            parseRParen(lastToken, token, nodeList)
        of ttIdentifier:
            parseIdentifier(lastToken, token, nodeList)
        of ttAngleBracket:
            parseAngleBracket(lastToken, token, nodeList)
        else:
            discard
        lastToken = token
    if fatalError == true:
        return @[]
    return nodeList

proc parsePassTwo(nodeList: seq[nodeTuple]): seq[nodeTuple] =
    if nodeList.len == 0:
        return @[]
    if nodeList[0].kind != NtSubexpressionStart:
        echo("Error: file must start with a left parenthesis ", numberOfExpressionss)
        fatalError = true
    elif nodeList[nodeList.len() - 1].kind != NtSubexpressionEnd:
        echo("Error: file must end with a right parenthesis ", numberOfExpressionss)
        fatalError = true
    if fatalError:
        return @[]

    var newNodeList: seq[nodeTuple] = @[]
    var index : uint = 1
    var nextNode : nodeTuple = nodeList[1]
    var lastNode : nodeTuple = nodeList[0]
    for node in nodeList:
        if node.kind == NtSubexpressionStart:
            numberOfExpressionss += 1
        newNodeList.add(node)
        if index < uint(nodeList.len() - 1):
            index += 1
        if node.kind == NtFunStart and lastNode.kind == NtGetReference:
            newNodeList.del(newNodeList.len() - 1)
            newNodeList.del(newNodeList.len() - 1)
            newNodeList.add( (kind : NtFunCall, value : lastNode.value) )
        lastNode = node
        nextNode = nodeList[index]
    if newNodeList[newNodeList.len() - 1].kind == NtSubexpressionEnd:
        newNodeList.delete(newNodeList.len() - 1)

    if fatalError == true:
        return @[]
    return newNodeList

var tokens = tokenizeString("( (atom >> x, 5) )")
var nodes = parsePassOne(tokens)
nodes = parsePassTwo(nodes)

echo nodes