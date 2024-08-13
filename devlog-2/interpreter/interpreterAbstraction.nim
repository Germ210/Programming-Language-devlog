include "interpreterUtils.nim"
from strutils import parseFloat
import "..\\compiler\\constants.nim"

proc initStateMachine() : stateMachine =
    var machine = stateMachine(states : initStates(), registers : initRegisters(), index : initIndex())
    return machine

proc executeOperand(operand : string, stateMachine : var stateMachine) : void =
    var floatOperand : float = 0.0
    try:
        floatOperand = parseFloat(operand)
    except ValueError as e:
        echo(e.msg)

    case stateMachine.states[stateMachine.index]
    of loading:
        vmLoad( (f1 : floatOperand) , stateMachine)
    of adding:
        vmAdd(floatOperand, stateMachine)
    of subtracting:
        vmSubtract(floatOperand, stateMachine)
    of multiplying:
        vmMultiply(floatOperand, stateMachine)
    of dividing:
        vmDivide(floatOperand, stateMachine)
    of programStart:
        echo("Error: Attempted to execute an operand before an operation has been defined")

proc executeInstructions(instructions: seq[string], stateMachine: var stateMachine): void =
    for instruction in instructions:
        case instruction
        of LOAD:
            changeState(loading, stateMachine)
        of ADD:
            changeState(adding, stateMachine)
        of SUB:
            changeState(subtracting, stateMachine)
        of MUL:
            changeState(multiplying, stateMachine)
        of DIV:
            changeState(dividing, stateMachine)
        of SUBSTART:
            vmSubStart(stateMachine)
        of SUBEND:
            vmSubEnd(stateMachine.registers[stateMachine.index], stateMachine)
        else:
            executeOperand(instruction, stateMachine)