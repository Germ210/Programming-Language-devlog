include "compilerTypes.nim"
from strUtils import parseInt, parseFloat
import "..\\constants.nim"

var numberOfExpressionss : uint = 1
var fatalError : bool = false

proc substringSplit(input: string, breakCharacters: openArray[char]): seq[string] =
  var brokenStrings: seq[string] = @[]
  var currentString: string = ""
  
  for character in input:
    if character notin breakCharacters:
      currentString.add(character)
    else:
      if currentString.len > 0:
        brokenStrings.add(currentString)
        currentString = ""
      brokenStrings.add($character)
  
  if currentString.len > 0:
    brokenStrings.add(currentString)
  return brokenStrings

proc removeLastCharacter(input : string) : string =
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
      var newStr : string = removeLastCharacter(str)
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
  
proc tokenizeSet(inputString : string, tokenlist : var seq[tokenTuple]) : void =
    tokenList.add( (kind : ttSet, value : inputString) )
proc tokenizeConst(inputString : string, tokenlist : var seq[tokenTuple]) : void =
    tokenList.add( (kind : ttConst, value : inputString) )

proc tokenizeIdentifier(inputString : string, tokenlist : var seq[tokenTuple]) : void =
    tokenList.add( (kind : ttIdentifier, value : inputString) )

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

proc parseColon(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
  case lastToken.kind
  of ttIdentifier:
    discard
  else:
    echo("Error: unexpected \"", lastToken.value, "\" before a colon ", numberOfExpressionss)
    fatalError = true

proc parseNumber(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
  case lastToken.kind
  of ttNumber:
    echo("Error: multiple numbers in a row ", numberOfExpressionss)
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
    nodeList.add( (kind : NtNum, value : currentToken.value) )
  of ttRParen:
    echo("Error: cannot have number after a closing parenthesis, perhaps putting the number at the start of the subexpression ", numberOfExpressionss)
    fatalError = true
  of ttSOF:
    nodeList.add( (kind : NtNum, value : currentToken.value) )
  else:
    echo("Error: unexpected ", currentToken.value, " before a number ", numberOfExpressionss)

proc parseOperator(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
  case lastToken.kind
  of ttNumber:
    discard
  of ttPlus, ttMinus, ttTimes, ttDivide:
    discard
  of ttLParen:
    echo("Error: operator has no number to perform on ", numberOfExpressionss)
    fatalError = true
  of ttRParen:
    nodeList.add( (kind : NtSubexpressionEnd, value : NULL) )
  of ttSOF:
    echo("Error: operator has no number to perform on, add a number after the start of the file ", numberOfExpressionss)
    fatalError = true
  else:
    discard

proc parseConst(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
  case lastToken.kind
  of ttLParen:
    discard
  else:
    echo("Error: expected parenthesis before constant, ", numberOfExpressionss)
    fatalError = true

proc parseVariable(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
  case lastToken.kind
  of ttLParen:
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    numberOfExpressionss += 1
  else:
    echo("Error: expected parenthesis before constant, ", numberOfExpressionss)
    fatalError = true

proc parseLParen(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
  case lastToken.kind
  of ttNumber:
    nodeList.add( (kind : NtMul, value : NULL) )
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    numberOfExpressionss += 1
  of ttIdentifier:
    nodeList.add( (kind : NtMul, value : NULL) )
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    numberOfExpressionss += 1
  of ttPlus:
    nodeList.add( (kind : NtAdd, value : NULL) )
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    numberOfExpressionss += 1
  of ttMinus:
    nodeList.add( (kind : NtSub, value : NULL) )
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    numberOfExpressionss += 1
  of ttTimes:
    nodeList.add( (kind : NtMul, value : NULL) )
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    numberOfExpressionss += 1
  of ttDivide:
    nodeList.add( (kind : NtDiv, value : NULL) )
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    numberOfExpressionss += 1
  of ttLParen:
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    numberOfExpressionss += 1
  of ttRParen:
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    numberOfExpressionss += 1
  else:
    discard

proc parseRParen(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
  case lastToken.kind
  of ttPlus, ttMinus, ttTimes, ttDivide:
    echo("Error: expected number after an operator, not a closing parenthesis")
    fatalError = true
  of ttEOF:
    discard
  of ttSOF:
    echo("Error: expected left parenthesis to open the subexpression, instead got start of file, expression number:", numberOfExpressionss)
    fatalError = true
  of ttConst:
    echo("Error: expected variable to assign to a constant, not a closing parenthesis, expression number:", numberOfExpressionss)
    fatalError = true
  of ttLParen, ttRParen, ttNumber, ttIdentifier:
    nodeList.add( (kind : NtSubexpressionEnd, value : NULL) )
  else:
    echo("Error: unexpected " , lastToken.value, "before a right parenthesis, expression number: " , numberOfExpressionss)
    fatalError = true

proc parseIdentifier(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) =
  case lastToken.kind
  of ttPlus:
    nodeList.add( (kind : NtAdd, value : NULL) )
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    nodeList.add( (kind : NtGetReference, value : currentToken.value) )
    nodeList.add( (kind : NtSubexpressionEnd, value : NULL) )
  of ttMinus:
    nodeList.add( (kind : NtSub, value : NULL) )
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    nodeList.add( (kind : NtGetReference, value : currentToken.value) )
    nodeList.add( (kind : NtSubexpressionEnd, value : NULL) )
  of ttTimes:
    nodeList.add( (kind : NtMul, value : NULL) )
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    nodeList.add( (kind : NtGetReference, value : currentToken.value) )
    nodeList.add( (kind : NtSubexpressionEnd, value : NULL) )
  of ttDivide:
    nodeList.add( (kind : NtDiv, value : NULL) )
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    nodeList.add( (kind : NtGetReference, value : currentToken.value) )
    nodeList.add( (kind : NtSubexpressionEnd, value : NULL) )
  of ttIdentifier:
    echo("Error: cannot have identifier next to another identifier without operator, expression number: ", numberOfExpressionss)
    fatalError = true
  of ttConst:
    nodeList.add( (kind : NtConst, value : currentToken.value) )
  of ttSet:
    nodeList.add( (kind : NtVariable, value : currentToken.value) )
  of ttNumber:
    echo("Error: cannot have number next to identifier without operator, expression number:  ", numberOfExpressionss)
    fatalError = true
  of ttLParen:
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    nodeList.add( (kind : NtGetReference, value : currentToken.value) )
    nodeList.add( (kind : NtSubexpressionEnd, value : NULL) )
  of ttSOF:
    echo("Error: undefined identifier: ", currentToken.value, " ,expression number: ", numberOfExpressionss)
  of ttRParen:
    echo("Error: cannot have identifier after a closing parenthesis, perhaps try putting the identifier at the start of the subexpression, expression number:  ", numberOfExpressionss)
    fatalError = true
  of ttEOF:
    discard 
  else:
    echo("Error: unexpected token before identifier: ", currentToken.value, " ,expression number: ", numberOfExpressionss)

proc parseEquals(lastToken, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
    case lastToken.kind
    of ttColon:
        nodeList.add( (kind : NtAssign, value : NULL) )
    of ttLParen:
        nodeList.add( (kind : NtAssign, value : NULL) )
        nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    else:
        echo("Error: unexpected token ", currentToken.value, " ", "before an equal sign, expression number: ", numberOfExpressionss)

proc genNum(node : nodeTuple, bytecodeSequence : var seq[string]) : void =
    bytecodeSequence.add(LOAD)
    bytecodeSequence.add(node.value & "\0")

proc genGetValue(node : nodeTuple, bytecodeSequence : var seq[string]) : void =
  bytecodeSequence.add(GETVALUE)
  bytecodeSequence.add(node.value)

proc genConst(node : nodeTuple, bytecodeSequence : var seq[string]) : void =
  bytecodeSequence.add(CONST)
  bytecodeSequence.add(node.value & "\0")

proc genAssign(node : nodeTuple, bytecodeSequence : var seq[string]) : void =
  bytecodeSequence.add(ASSIGN)
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

proc operandVsOpcode(str : var string) : string =
  if str notin @[LOAD, ADD, SUB, MUL, DIV, SUBSTART, SUBEND, CONST, ASSIGN]:
    str = removeLastCharacter(str)
  return str

proc valueIsInSeq(input : seq[string], wantedValue : string) : bool =
  for each in input:
    if each == wantedValue:
      return true
  return false

proc validateConstandSet(nodeList : seq[nodeTuple]) : void =
  numberOfExpressionss = 1
  var node = 0
  var definedConstants : seq[string] = @[]
  var nextNode : nodeTuple = nodeList[1]
  while node <= nodeList.len() - 1:
    nextNode = nodeList[node + 1]
    case nodeList[node].kind:
    of NtConst, NtVariable:
      if nextNode.kind == NtAssign and valueIsInSeq(definedConstants, nodeList[node].value) == true:
        echo("Error: duplicate constant definition: ", nodeList[node].value, " expression number: ", numberOfExpressionss)
        echo(nodeList[node].value)
        fatalError = true
      else:
        definedConstants.add(nodeList[node].value)
        echo("triggered")
    of NtSubexpressionStart:
      numberOfExpressionss += 1
    else:
      echo("done")
  echo(definedConstants)