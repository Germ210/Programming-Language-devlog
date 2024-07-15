type
  tokenType = enum
    ttNumber, ttPlus, ttMinus, ttTimes, ttDivide, ttLParen, ttRParen, ttEOF, ttSOF

  tokenTuple = tuple
    kind : tokenType
    value : string

  NodeTypes = enum
    NtNum, NtAdd, NtSub, NtMul, NtDiv, NtSubexpressionStart, NtSubexpressionEnd
  
  nodeTuple = tuple
    kind : NodeTypes
    value : string

  bytes = seq[int64]
