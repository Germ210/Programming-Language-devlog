include "serilize.nim"
include "compilerUtils.nim"

proc tokenizeString(inputString : string) : seq[tokenTuple] =
    var brokenStrings : seq[string] = substringSplit(inputString, @[' ', '+', '-', '*', '/', ',', '(', ')', ':', '=', '\n'])
    brokenStrings = removeSubstring(brokenStrings, " ")
    brokenStrings = removeSubstring(brokenStrings, "\t")
    var tokenList : seq[tokenTuple]
    tokenizeSOF(tokenList)
    for substring in brokenStrings:
        if isNumber(substring):
            tokenizeNumber(substring, tokenList)
        else:
            case substring
            of "+", "-", "*", "/":
                tokenizeOperator(substring, tokenList)
            of "(", ")":
                tokenizeParenthesis(substring, tokenList)
            of "const":
                tokenizeConst(substring, tokenList)
            of "\n":
                tokenizeNewLine(substring, tokenList)
            of ":":
                tokenizeColon(substring, tokenList)
            of "=":
                tokenizeEquals(substring, tokenList)
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
        of ttConst:
            parseConst(lastToken, token, nodeList)
        of ttIdentifier:
            parseIdentifier(lastToken, token, nodeList)
        of ttNewline:
            parseNewLine()
        of ttColon:
            parseColon(lastToken, token, nodeList)
        of ttEqual:
            parseEquals(lastToken, token, nodeList)
        else:
            discard
        lastToken = token
    return nodeList

proc parsePassTwo(nodeList : openArray[nodeTuple]) : seq[nodeTuple] =
    var lastNode : nodeTuple = (kind : NtSOF, value : NULL)
    var newNodeList : seq[nodeTuple] = @[]
    for node in nodeList:
        if node.kind == NtMul or node.kind == NtDiv and lastNode.kind == NtAdd or lastNode.kind == NtSub:
            newNodeList.add( (kind : NtAdd, value : NULL) )
            newNodeList.add( (kind : NtSubexpressionStart, value : NULL) )
            newNodeList.add( (kind : NtNum, value : node.value) )
            newNodeList.add( (node) )
        elif node.kind == NtConst:
            discard
        elif node.kind == NtAssign and lastNode.kind == NtConst:
            parsePass2Const(lastNode, node, newNodeList)
        else:
            newNodeList.add(node)
        lastNode = node
    return newNodeList

proc serializeBytecode(nodeList : seq[nodeTuple], write : bool) : seq[string] =
    var returnString : seq[string] 
    for node in nodeList:
        case node.kind
        of NtNum:
            genNum(node, returnString)
        of NtAdd, NtSub, NtMul, NtDiv:
            genOperator(node, returnString)
        of NtSubexpressionStart:
            genSubStart(returnString)
        of NtSubexpressionEnd:
            genSubEnd(returnString)
        else:
            discard
    returnString = removeSubstring(returnString, NULL)
    if write == true:
        store("bytecode.bin", toUTF8(join(returnString, "")))
    return returnString

proc deserializeBytecode(fileName : string) : seq[string] =
    var content : seq[int64] = load(fileName)
    var returnThis : seq[string] = removeSubstring(stringSplitAdd(fromUTF8(content), '\0'), NULL)
    return removeSubstring(returnThis, "")

var
    tokens = tokenizeString("\nconst x := 5")
    nodes = parsePassOne(tokens)
nodes = parsePassTwo(nodes)

echo tokens
echo nodes