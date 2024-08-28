import "..\\..\\constants.nim"
import "..\\types.nim"
from strUtils import parseFloat, parseInt

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

proc tokenizeAngelBrackets(inputString : string, tokenList : var seq[tokenTuple]) : void =
  tokenList.add( (kind : ttAngleBracket, value : inputString) )

proc tokenizeComma(inputString : string, tokenList : var seq[tokenTuple]) : void =
  tokenList.add( (kind : ttComma, value : inputString) )

proc tokenizeNumber(inputString : string, tokenlist : var seq[tokenTuple]) : void =
    tokenList.add( (kind : ttNumber, value : inputString) )

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