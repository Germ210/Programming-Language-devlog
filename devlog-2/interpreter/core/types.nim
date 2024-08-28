type
  stackData = string
  Stack = object
    data : seq[stackData]
    top : int
  

proc initStack(): Stack =
  result.data = @[]
  result.top = -1


proc push(stack : var Stack, elem : string) =
  stack.data.add(elem)
  stack.top = stack.data.high()

proc pop(stack : var Stack) : stackData =
  if stack.data.len == 0:
    raise newException(ValueError, "Stack is empty")
  let topElem = stack.data[stack.top]
  stack.data.del(stack.top)
  stack.top = stack.data.high()
  return topElem

proc peek(stack : Stack): stackData =
  if stack.data.len == 0:
    raise newException(ValueError, "Stack is empty")
  return stack.data[stack.top]