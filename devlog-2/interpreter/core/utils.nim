include "types.nim"
from strutils import parseFloat

proc executeLoad(stack : var Stack, loadValue : stackData) =
    stack.data.add(loadValue)

proc executeAdd(stack : var Stack, addValue : stackData) =
    stack.data[stack.top] = $(parseFloat(stack.data[stack.top]) + parseFloat(addValue))

proc executeSubtract(stack : var Stack, subtractValue : stackData) =
    stack.data[stack.top] = $(parseFloat(stack.data[stack.top]) - parseFloat(subtractValue))

proc executeMultiply(stack : var Stack, multiplicationValue : stackData) : void =
    stack.data[stack.top] = $(parseFloat(stack.data[stack.top]) * parseFloat(multiplicationValue))

proc executeDivide(stack : var Stack, divideValue : stackData) : void =
    if divideValue == "0.0" or divideValue == "0":
        raise newException(ValueError, "Division by zero")
    stack.data[stack.top] = $(parseFloat(stack.data[stack.top]) / parseFloat(divideValue))