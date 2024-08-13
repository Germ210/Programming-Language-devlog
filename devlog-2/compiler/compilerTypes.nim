type
  tokenType = enum
    ttNumber, ttPlus, ttMinus, ttTimes, ttDivide, ttLParen, ttRParen, ttEOF, ttSOF, ttIdentifier, ttConst, ttNewline

  tokenTuple = tuple
    kind : tokenType
    value : string

  NodeTypes = enum
    NtNum, NtAdd, NtSub, NtMul, NtDiv, NtSubexpressionStart, NtSubexpressionEnd, NtSOF, NtConst
  
  nodeTuple = tuple
    kind : NodeTypes
    value : string
