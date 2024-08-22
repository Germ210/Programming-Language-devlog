import tables

type
    register = tuple[f1: float]

    state = enum
      adding, subtracting, multiplying, dividing, loading, programStart, definingConstant, assigning, gettingReference

    types = enum
      BendiNumber, BendiBoolean, BendiString 
    
    variableStack = seq[string]

    variable = tuple[kind : types, value : string]

    stateMachine = object
      states: seq[state]
      registers: seq[register]
      index: uint
      variables: seq[Table[string, variable]]
      stack: variableStack

proc push(self: var stateMachine, variableName: string): void =
  self.stack.add(variableName)

proc pop(self : var stateMachine) : string =
  var poppedValue : string = self.stack[self.stack.len - 1]
  self.stack.delete(self.stack.len - 1)
  return poppedValue

proc peek(self : stateMachine) : string =
  return self.stack[self.stack.len - 1]