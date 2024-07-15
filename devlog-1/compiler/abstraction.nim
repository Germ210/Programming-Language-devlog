include "serilize.nim"
include "compilerUtils.nim"

proc tokenizeString(inputString : string) : seq[tokenTuple] =
    var brokenStrings : seq[string] = substringSplit(inputString, @[' ', '+', '-', '*', '/', ',', '(', ')'])
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
            else:
                discard
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
        else:
            discard
        lastToken = token
    return nodeList

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
    
    if write == true:
        store("bytecode.bin", toUTF8(join(returnString, "")))

    return returnString