type
  types = enum 
    BendyNumber, BendyString, BendyBoolean
  bendyVariable = tuple[kind : bendyVariableTypes, value : string]                                                                                                 │  ▼ interface/
  variableTables = seq[Table[string, bendyVariable]]

proc initStack() : Stack =
  return Stack(data : @[], top : -1)

proc push(stack : var Stack, loadValue : stackData) : void =
  stack.data.add(loadValue)
  stack.top += 1

proc pop(stack : var Stack) : stackData =
  var poppedValue = stack.data[stack.top]
  stack.data.del(stack.top)
  stack.top -= 1
  return poppedValue

proc peek(stack : var Stack) : stackData =
  return stack.data[stack.top]
