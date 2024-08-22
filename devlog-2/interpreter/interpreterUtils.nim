include "interpreterTypes.nim"

proc initStates() : seq[state] =
    return @[programStart]

proc initRegisters() : seq[register] =
    return @[ (f1 : 0.0) ]

proc initIndex() : uint =
    return 0

proc initVariables() : seq[Table[string, variable]] =
    var variables = initTable[string, variable]()
    return @[variables]

proc changeState(newState : state, stateMachine : var stateMachine) : void =
    stateMachine.states[stateMachine.index] = newState

proc changeIndex(stateMachine : var stateMachine, incrementing : bool) : void =
    if incrementing == true:
        stateMachine.index += 1
    else:
         if stateMachine.index == 0:
            echo("Error: Attempted to decrement index below 0")
         else:
            stateMachine.index -= 1

proc vmLoad(register : register, stateMachine : var stateMachine) : void =
    if stateMachine.index > uint(stateMachine.registers.len):
        stateMachine.registers.add(register)
    else:
        stateMachine.registers[stateMachine.index] = register

proc vmAdd(addingValue : float, stateMachine : var stateMachine) : void =
    var newValue =stateMachine.registers[stateMachine.index].f1 + addingValue
    stateMachine.registers[stateMachine.index] = ( f1 : newValue )

proc vmSubtract(subtractingValue : float, stateMachine : var stateMachine) : void =
    var newValue = stateMachine.registers[stateMachine.index].f1 - subtractingValue
    stateMachine.registers[stateMachine.index] = ( f1 : newValue )

proc vmMultiply(multiplyingValue : float, stateMachine : var stateMachine) : void =
    var newValue = stateMachine.registers[stateMachine.index].f1 * multiplyingValue
    stateMachine.registers[stateMachine.index] = ( f1 : newValue )

proc vmDivide(dividingValue : float, stateMachine : var stateMachine) : void =
    if dividingValue == 0.0:
        echo("Error: Attempted to divide by 0")
    else:
        var newValue = stateMachine.registers[stateMachine.index].f1 / dividingValue
        stateMachine.registers[stateMachine.index] = ( f1 : newValue )

proc vmSubStart(stateMachine : var stateMachine) : void =
    changeIndex(stateMachine, true)
    stateMachine.registers.add( (f1 : 0.0) )
    stateMachine.states.add(programStart)


proc vmAssign(stateMachine : var stateMachine, value : string) : void =
    var stackTop = pop(stateMachine)
    var kind = stateMachine.variables[stateMachine.index][stackTop].kind
    stateMachine.variables[stateMachine.index][stackTop] = (kind : kind, value : value)

  
proc vmSubEnd(currentRegister : register, stateMachine : var stateMachine) : void =
    var str = $currentRegister.f1
    stateMachine.registers.delete(stateMachine.index)
    stateMachine.states.delete(stateMachine.index)
    changeIndex(stateMachine, false)
    case stateMachine.states[stateMachine.index]
    of loading:
        vmLoad(currentRegister, stateMachine)
    of assigning:
        vmAssign(stateMachine, str)
    of adding:
        vmAdd(currentRegister.f1, stateMachine)
    of subtracting:
        vmSubtract(currentRegister.f1, stateMachine)
    of multiplying:
        vmMultiply(currentRegister.f1, stateMachine)
    of dividing:
        vmDivide(currentRegister.f1, stateMachine)
    else:
        discard


proc vmGetReference(variableName : string, stateMachine : var stateMachine) : void =
    push(stateMachine, variableName)
    var stackTop = peek(stateMachine)
    stateMachine.variables[stateMachine.index][stackTop] = (kind : BendiNumber, value : "0.0")