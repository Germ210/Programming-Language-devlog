import "..\\..\\constants.nim"
import "..\\types.nim"

proc parseNumber(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
  case lastToken.kind
  of ttNumber:
    echo("Error: multiple numbers in a row ", numberOfExpressionss)
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
  of ttComma:
    nodeList.add( (kind : NtNumberOperand, value : currentToken.value) )
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

proc parseLParen(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
  case lastToken.kind
  of ttNumber:
    nodeList.add( (kind : NtMul, value : NULL) )
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    numberOfExpressionss += 1
  of ttIdentifier:
    nodeList.add( (kind : NtLoader, value : NULL) )
    nodeList.add( (kind : NtGetReference, value : lastToken.value) )
    nodeList.add( (kind : NtMul, value : NULL) )
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    numberOfExpressionss += 1
  of ttPlus:
    nodeList.add( (kind : NtAddSubExpression, value : NULL) )
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    numberOfExpressionss += 1
  of ttMinus:
    nodeList.add( (kind : NtSubSubExpression, value : NULL) )
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    numberOfExpressionss += 1
  of ttTimes:
    nodeList.add( (kind : NtMulSubExpression, value : NULL) )
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    numberOfExpressionss += 1
  of ttDivide:
    nodeList.add( (kind : NtDivSubExpression, value : NULL) )
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    numberOfExpressionss += 1
  of ttLParen:
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    numberOfExpressionss += 1
  of ttRParen:
    nodeList.add( (kind : NtSubexpressionStart, value : NULL) )
    numberOfExpressionss += 1
  of ttAngleBracket:
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
  of ttLParen, ttRParen, ttNumber, ttIdentifier:
    nodeList.add( (kind : NtSubexpressionEnd, value : NULL) )
  else:
    echo("Error: unexpected '" , lastToken.value, "' before a right parenthesis, expression number: " , numberOfExpressionss)
    fatalError = true

proc parseIdentifier(lastToken : tokenTuple, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) =
  case lastToken.kind
  of ttPlus:
    nodeList.add( (kind : NtAdd, value : NULL) )
    nodeList.add( (kind : NtGetReference, value : currentToken.value) )
  of ttMinus:
    nodeList.add( (kind : NtSub, value : NULL) )
    nodeList.add( (kind : NtGetReference, value : currentToken.value) )
  of ttTimes:
    nodeList.add( (kind : NtMul, value : NULL) )
    nodeList.add( (kind : NtGetReference, value : currentToken.value) )
  of ttDivide:
    nodeList.add( (kind : NtDiv, value : NULL) )
    nodeList.add( (kind : NtGetReference, value : currentToken.value) )
  of ttIdentifier:
    echo("Error: cannot have identifier next to another identifier without operator, expression number: ", numberOfExpressionss)
    fatalError = true
  of ttNumber:
    echo("Error: cannot have number next to identifier without operator, expression number:  ", numberOfExpressionss)
    fatalError = true
  of ttLParen:
    nodeList.add( (kind : NtGetReference, value : currentToken.value) )
  of ttSOF:
    echo("Error: undefined identifier: ", currentToken.value, " ,expression number: ", numberOfExpressionss)
  of ttRParen:
    echo("Error: cannot have identifier after a closing parenthesis, perhaps try putting the identifier at the start of the subexpression, expression number:  ", numberOfExpressionss)
    fatalError = true
  of ttEOF:
    discard 
  of ttAngleBracket:
    nodeList.add( (kind : NtIdentifierOperand, value : currentToken.value) )
  of ttComma:
    nodeList.add( (kind : NtIdentifierOperand, value : currentToken.value) )

proc parseAngleBracket(lastToken, currentToken : tokenTuple, nodeList : var seq[nodeTuple]) : void =
  case lastToken.kind:
  of ttAngleBracket:
    nodeList.add( (kind : NtFunStart, value : NULL) )
  else:
    discard