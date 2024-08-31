include "types.nim"
from "..\\..\\compiler\\types.nim" import nodeTuple, NodeTypes
from strutils import parseFloat

proc load(stack : var Stack, loadValue : stackData) : void =
  stack.push(loadValue)

proc add(stack : var Stack, addVal : stackData) : void =
  var 
    baseValue = parseFloat(stack.peek())
    addValue = parseFloat(addVal)
  stack.data[stack.top] = $(baseValue + addValue)

proc subtract(stack : var Stack, subtractVal : stackData) : void =
  var 
    baseValue = parseFloat(stack.peek())
    subtractValue = parseFloat(subtractVal)
  stack.data[stack.top] = $(baseValue - subtractValue)

proc multiply(stack : var Stack, multiplyVal : stackData) : void =
  var 
    baseValue = parseFloat(stack.peek())
    multiplyValue = parseFloat(multiplyVal)
  stack.data[stack.top] = $(baseValue * multiplyValue)

proc divide(stack : var Stack, divideVal : stackData) : void =
  var 
    baseValue = parseFloat(stack.peek())
    divideValue = parseFloat(divideVal)
  if divideValue == 0.0:
    raise newException(ValueError, "Division by zero")
  stack.data[stack.top] = $(baseValue / divideValue)

proc subAdd(states : var Stack) =
  states.push("add")

proc subSubtract(states : var Stack) =
  states.push("subtract")

proc subMultiply(states : var Stack) =
  states.push("multiply")

proc subDivide(states : var Stack) =
  states.push("divide")

proc subEnd(states, stack : var Stack) =
  var topValue = stack.pop()
  case states.data[states.top]
  of "add":
    stack.add(topValue)
  of "subtract":
    stack.subtract(topValue)
  of "multiply":
    stack.multiply(topValue)
  of "divide":
    stack.divide(topValue)
  else:
    discard
  discard states.pop()