type
  tokenType = enum
    ttSet, ttNumber, ttPlus, ttMinus, ttTimes, ttDivide, ttLParen, ttRParen, ttEOF, ttSOF, ttIdentifier, ttConst, ttColon, ttEqual

  tokenTuple = tuple
    kind : tokenType
    value : string

  NodeTypes = enum
    NtEOF, NtDel, NtVariable, NtNum, NtAdd, NtSub, NtMul, NtDiv, NtSubexpressionStart, NtSubexpressionEnd, NtSOF, NtConst, NtGetReference, NtAssign, ExpressionStart, ExpressionEnd
  
  nodeTuple = tuple
    kind : NodeTypes
    value : string
  
  constAndVar = object
    isConst : bool = true
    index : uint = 0