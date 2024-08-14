type
  tokenType = enum
    ttNumber, ttPlus, ttMinus, ttTimes, ttDivide, ttLParen, ttRParen, ttEOF, ttSOF, ttIdentifier, ttConst, ttNewline, ttColon, ttEqual

  tokenTuple = tuple
    kind : tokenType
    value : string

  NodeTypes = enum
    NtNum, NtAdd, NtSub, NtMul, NtDiv, NtSubexpressionStart, NtSubexpressionEnd, NtSOF, NtConst, NtGetValue, NtAssign, NtAssignConst
  
  nodeTuple = tuple
    kind : NodeTypes
    value : string
