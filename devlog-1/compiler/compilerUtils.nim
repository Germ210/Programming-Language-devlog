import strutils
include "compilerTypes.nim"
import "constants.nim"


proc substringSplit(input : string, breakCharacters : seq[char]) : seq[string] =
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

proc removeSubstring(subStrings : seq[string], filterString : string) : seq[string] =
    var returnSubstrings : seq[string] = @[]
    for substring in subStrings:
        if substring != filterString:
            returnSubstrings.add(substring)
    return returnSubStrings

proc isNumber(inputString: string): bool =
  try:
    discard parseInt(inputString)
    return true
  except ValueError:
    try:
      discard parseFloat(inputString)
      return true
    except ValueError:
      return false

proc tokenizeNumber(inputString : string, tokenlist : var seq[tokenTuple]) : void =
    tokenList.add((kind : ttNumber, value : inputString))

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

proc parseNumber(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
  case lastToken.kind
  of ttNumber:
    echo("Error: multiple numbers in a row")
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
    echo("Error: cannot have number after a closing parenthesis, perhaps try using either a multiplication operator or putting the number at the start of the subexpression")
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
    echo("Error: operator has no number to perform on")
  of ttRParen:
    nodeList.add( (kind : NtSubexpressionEnd, value : NULL) )
  of ttSOF:
    echo("Error: operator has no number to perform on, add a number after the start of the file")
  else:
    discard

proc parseLParen(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
  case lastToken.kind
  of ttNumber:
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
    echo("Error: expected left parenthesis to open the subexpression, instead got start of file")
  of ttLParen, ttRParen, ttNumber:
    nodeList.add( (kind : NtSubexpressionEnd, value : NULL) )

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

proc genError() : void =
  echo("Error: unhandled node for bytecode generation")