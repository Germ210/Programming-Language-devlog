import strutils
include "compilerTypes.nim"
import "constants.nim"

var numberOfNewLines = 1

proc substringSplit(input : string, breakCharacters : openArray[char]) : seq[string] =
  var brokenStrings : seq[string] = @[]
  var currentString : string = "" 
  for character in input:
    if character in breakCharacters:
      if currentString != "":
        brokenStrings.add(currentString)
      currentString = ""
      brokenStrings.add($character)
    else:
      currentString.add(character) 
  if currentString != "":
    brokenStrings.add(currentString)
  
  return brokenStrings

proc removeLastChacter(input : string) : string =
  var len = 0
  var newStr = ""
  for character in input:
    if len == input.len() - 1:
      break
    newStr.add(character)
    len += 1
  return newStr

proc stringSplitAdd(input: string, breakString: char): seq[string] =
  var returnSequence: seq[string] = @[]
  var realReturnSequence: seq[string] = @[]

  var currentSubstring: string = ""
  for character in input:
    currentSubstring &= character
    if character == breakString:
      returnSequence.add(currentSubstring)
      currentSubstring = ""
  returnSequence.add(currentSubstring)
  for str in returnSequence:
    if str notin [LOAD, ADD, SUB, MUL, DIV, SUBSTART, SUBEND, NULL]:
      var newStr : string = removeLastChacter(str)
      realReturnSequence.add(newStr)
  return realReturnSequence

proc removeSubstring(subStrings : openArray[string], filterString : string) : seq[string] =
    var returnSubstrings : seq[string] = @[]
    for substring in subStrings:
        if substring != filterString:
            returnSubstrings.add(substring)
        else:
            discard
    return returnSubStrings

proc isNumber(inputString : string) : bool =
  try:
    discard parseInt(inputString)
    return true
  except ValueError:
    try:
      discard parseFloat(inputString)
      return true
    except ValueError:
      return false

proc tokenizeEquals(inputString : string, tokenlist : var seq[tokenTuple]) : void =
  tokenlist.add( (kind : ttEqual, value : inputString) )

proc tokenizeColon(inputString : string, tokenlist : var seq[tokenTuple]) : void =
  tokenlist.add( (kind : ttColon, value : inputString) )

proc tokenizeNumber(inputString : string, tokenlist : var seq[tokenTuple]) : void =
    tokenList.add( (kind : ttNumber, value : inputString) )
  
proc tokenizeConst(inputString : string, tokenlist : var seq[tokenTuple]) : void =
    tokenList.add( (kind : ttConst, value : inputString) )

proc tokenizeIdentifier(inputString : string, tokenlist : var seq[tokenTuple]) : void =
    tokenList.add( (kind : ttIdentifier, value : inputString) )

proc tokenizeKeyword(inputString : string, tokenlist : var seq[tokenTuple]) : void =
  case inputString
  of "const":
    tokenizeConst(inputString, tokenList)
  else:
    tokenizeIdentifier(inputString, tokenList)

proc tokenizeNewLine(inputString : string, tokenlist : var seq[tokenTuple]) : void =
    tokenlist.add( (kind : ttNewline, value : inputString) )

proc tokenizeOperator(inputString : string, tokenlist : var seq[tokenTuple]) : void =
  case inputString:
  of "+":
    tokenList.add( (kind : ttPlus, value : inputString) )
  of "-":
    tokenList.add( (kind : ttMinus, value : inputString) )
  of "*":
    tokenList.add( (kind : ttTimes, value : inputString) )
  of "/":
    tokenList.add( (kind : ttDivide, value : inputString) )
  else:
    discard

proc tokenizeParenthesis(inputString : string, tokenList : var seq[tokenTuple]) : void =
  case inputString:
  of "(":
    tokenList.add ((kind : ttLParen, value : inputString) )
  of ")":
    tokenList.add( (kind : ttRParen, value : inputString) )
  else:
    discard

proc tokenizeSOF(tokenList : var seq[tokenTuple]) : void =
    tokenList.add( (kind : ttSOF, value : "SOF") )

proc tokenizeEOF(tokenList : var seq[tokenTuple]) : void = 
    tokenList.add( (kind : ttEOF, value : "EOF") )

proc parseNewLine() : void =
  numberOfNewlines += 1

proc parseColon(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
  case lastToken.kind
  of ttIdentifier:
    discard
  else:
    echo("Error: unexpected \"", lastToken.value, "\" before a colon ", numberOfNewLines)

proc parseEquals(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
  case lastToken.kind
  of ttColon:
    nodeList.add( (kind : NtAssign, value : lastToken.value & currentToken.value) )
  else:
    echo("Error: unexpected \"", lastToken.value, "\" before an equal sign")
  
proc parseNumber(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
  case lastToken.kind
  of ttNumber:
    echo("Error: multiple numbers in a row ", numberOfNewLines)
  of ttEqual:
    nodeList.add( (kind : NtNum, value : currentToken.value) )
  of ttPlus:
    nodeList.add( (kind : NtAdd, value : currentToken.value) )
  of ttMinus:
    nodeList.add( (kind : NtSub, value : currentToken.value) )
  of ttTimes:
    nodeList.add( (kind : NtMul, value : currentToken.value) )
  of ttDivide:
    nodeList.add( (kind : NtDiv, value : currentToken.value) )
  of ttLParen:
    nodeList.add( (kind : NtSubexpressionStart, value : NULL ) )
    nodeList.add( (kind : NtNum, value : currentToken.value) )
  of ttRParen:
    echo("Error: cannot have number after a closing parenthesis, perhaps putting the number at the start of the subexpression ", numberOfNewLines)
  of ttSOF:
    nodeList.add( (kind : NtNum, value : currentToken.value) )
  else:
    discard

proc parseOperator(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
  case lastToken.kind
  of ttNumber:
    discard
  of ttPlus, ttMinus, ttTimes, ttDivide:
    discard
  of ttLParen:
    echo("Error: operator has no number to perform on ", numberOfNewLines)
  of ttRParen:
    nodeList.add( (kind : NtSubexpressionEnd, value : NULL) )
  of ttSOF:
    echo("Error: operator has no number to perform on, add a number after the start of the file ", numberOfNewLines)
  else:
    discard

proc parseConst(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
  case lastToken.kind
  of ttNewline, ttSOF:
    discard
  else:
    echo("Error: expected newline or a semicolon before a constant ", numberOfNewLines)

proc parsePass2Const(lastNode : nodeTuple, currentNode : nodeTuple, nodeList : var seq[nodeTuple]) : void =
  case lastNode.kind
  of NtConst:
    nodeList.add( (kind : NtAssignConst, value : lastNode.value) )
  else:
    discard
    

proc parseLParen(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
  case lastToken.kind
  of ttNumber:
    nodeList.add( (kind : NtMul, value : NULL) )
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
  of ttIdentifier:
    nodeList.add( (kind : NtMul, value : NULL) )
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
  of ttPlus:
    nodeList.add( (kind : NtAdd, value : NULL) )
  of ttMinus:
    nodeList.add( (kind : NtSub, value : NULL) )
  of ttTimes:
    nodeList.add( (kind : NtMul, value : NULL) )
  of ttDivide:
    nodeList.add( (kind : NtDiv, value : NULL) )
  of ttLParen:
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
  of ttRParen:
    nodeList.add( (kind : NtSubexpressionEnd, value : NULL) )
  of ttSOF:
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
  else:
    discard

proc parseRParen(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
  case lastToken.kind
  of ttPlus, ttMinus, ttTimes, ttDivide:
    echo("Error: expected number after an operator, not a closing parenthesis")
  of ttEOF:
    discard
  of ttSOF:
    echo("Error: expected left parenthesis to open the subexpression, instead got start of file ", numberOfNewLines)
  of ttConst:
    echo("Error: expected variable to assign to a constant, not a closing parenthesis")
  of ttLParen, ttRParen, ttNumber, ttIdentifier:
    nodeList.add( (kind : NtSubexpressionEnd, value : NULL) )
  of ttNewline:
    nodeList.add( (kind : NtSubexpressionEnd, value : NULL) )
  else:
    echo("Error: unexpected " , lastToken.value, "before a right parenthesis")

proc parseIdentifier(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) =
  case lastToken.kind
  of ttPlus, ttMinus, ttTimes, ttDivide:
    nodeList.add( (kind : NtAdd, value : NULL) )
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    nodeList.add( (kind : NtGetValue, value : currentToken.value) )
    nodeList.add( (kind : NtSubexpressionEnd, value : NULL) )
  of ttIdentifier:
    echo("Error: cannot have identifier next to another identifier without operator ", numberOfNewLines)
  of ttNumber:
    echo("Error: cannot have number next to identifier without operator ", numberOfNewLines)
  of ttLParen:
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    nodeList.add( (kind : NtGetValue, value : currentToken.value) )
  of ttConst:
    nodeList.add( (kind : NtConst, value : currentToken.value) )
  of ttSOF:
    echo("Error: expected \"const\" or \"set\" before an identifier, not the start of the file", numberOfNewLines)
  of ttRParen:
    echo("Error: cannot have identifier after a closing parenthesis, perhaps try putting the identifier at the start of the subexpression ", numberOfNewLines)
  of ttEOF:
    discard
  of ttNewline:
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    nodeList.add( (kind : NtGetValue, value : currentToken.value) )
    nodeList.add( (kind : NtSubexpressionEnd, value : NULL) )  
  else:
    discard

proc genNum(node : nodeTuple, bytecodeSequence : var seq[string]) : void =
    bytecodeSequence.add(LOAD)
    bytecodeSequence.add(node.value & "\0")

proc genOperator(node : nodeTuple, bytecodeString : var seq[string]) : void =
    case node.kind
    of NtAdd:
        bytecodeString.add(ADD)
        bytecodeString.add(node.value & "\0")
    of NtSub:
        bytecodeString.add(SUB)
        bytecodeString.add(node.value & "\0")
    of NtMul:
        bytecodeString.add(MUL)
        bytecodeString.add(node.value & "\0")
    of NtDiv:
        bytecodeString.add(DIV)
        bytecodeString.add(node.value & "\0")
    else:
        discard

proc genSubStart(bytecodeSequence : var seq[string]) : void =
    bytecodeSequence.add(SUBSTART)

proc genSubEnd(bytecodeSequence : var seq[string]) : void =
    bytecodeSequence.add(SUBEND)

proc genConst(node : nodeTuple, bytecodeSequence : var seq[string]) : void =
  bytecodeSequence.add(CONST)
  bytecodeSequence.add(node.value & "\0")
