include "utils.nim"

proc tokenizeString(inputString : string) : seq[tokenTuple] =
    var brokenStrings : seq[string] = substringSplit(inputString, @[' ', '+', '-', '*', '/', ',', '(', ')', ':', '=', '\n'])
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
            of "+", "-", "*", "/":
                tokenizeOperator(substring, tokenList)
            of "(", ")":
                tokenizeParenthesis(substring, tokenList)
            of "const":
                tokenizeConst(substring, tokenList)
            of "\n":
                discard
            of ":":
                tokenizeColon(substring, tokenList)
            of "=":
                tokenizeEquals(substring, tokenList)
            of "set":
                tokenizeSet(substring, tokenList)
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
        of ttColon:
            parseColon(lastToken, token, nodeList)
        of ttEqual:
            parseEquals(lastToken, token, nodeList)
        of ttSet:
            parseVariable(lastToken, token, nodeList)
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
        if node.kind == NtAdd or node.kind == NtSub:
            if nextNode.kind == NtMul or nextNode.kind == NtDiv:
                newNodeList.add((kind: node.kind, value: NULL))
                newNodeList.add((kind: NtSubexpressionStart, value: NULL))
                newNodeList.add((kind: NtNum, value: node.value))
                newNodeList.add(nextNode)
                newNodeList.add((kind: NtSubexpressionEnd, value: NULL))
        elif node.kind == NtAdd or node.kind == NtSub:
            newNodeList.add(node)
        elif node.kind == NtMul or node.kind == NtDiv and (lastnode.kind == NtSub or lastNode.kind == NtAdd):
            discard
        elif node.kind == NtAssign and nextNode.kind == NtNum:
            newNodeList.add( (kind : NtAssign, value : nextNode.value) )
        elif node.kind == NtNum and lastNode.kind == NtAssign:
            discard
        else:
            newNodeList.add(node)
        if index < uint(nodeList.len() - 1):
            index += 1
        lastNode = node
        nextNode = nodeList[index]
    if newNodeList[newNodeList.len() - 1].kind == NtSubexpressionEnd:
        newNodeList.delete(newNodeList.len() - 1)
    return newNodeList

proc genBytecode(nodeList : seq[nodeTuple]) : seq[string] =
    var returnString : seq[string]
    var lastNode : nodeTuple
    for node in nodeList:
        case node.kind
        of NtNum:
            genNum(node, returnString)
        of NtAdd, NtSub, NtMul, NtDiv:
            genOperator(node, returnString)
        of NtConst:
            genConst(node, returnString)
        of NtSubexpressionStart:
            genSubStart(returnString)
        of NtSubexpressionEnd:
            genSubEnd(returnString)
        of NtAssign:
            genAssign(node, returnString)
        of NtGetReference:
            genGetValue(node, returnString)
        of NtVariable:
            genConst(node, returnString)
        else:
            discard
        lastNode = node
    for str in countup(0, returnString.len() - 1):
        returnString[str] = operandVsOpcode(returnString[str])
    if fatalError == true:
        return @[]
    returnString = removeSubstring(returnString, NULL)
    return returnString

proc validateNodeList(nodeList : seq[nodeTuple]) : seq[nodeTuple] =
  validateConstandSet(nodeList)
  if fatalError == true:
    return @[]
  return nodeList
var tokens = tokenizeString("((const x := 5)(const x := 6))")
var nodes = parsePassOne(tokens)
nodes = parsePassTwo(nodes)
nodes = validateNodeList(nodes)

echo nodes