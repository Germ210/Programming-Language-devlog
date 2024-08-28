type
  tokenType* = enum
    ttNumber, ttPlus, ttMinus, ttTimes, ttDivide, ttLParen, ttRParen, ttEOF, ttSOF, ttIdentifier, ttAngleBracket, ttComma

  tokenTuple* = tuple
    kind : tokenType
    value : string

  NodeTypes* = enum
    NtIdentifierOperand, NtFunStart, NtNumberOperand, NtNum, NtAdd, NtSub, NtMul, NtDiv, NtSubexpressionStart, NtSubexpressionEnd, NtGetReference, NtPass, NtFunCall
  
  nodeTuple* = tuple
    kind : NodeTypes
    value : string