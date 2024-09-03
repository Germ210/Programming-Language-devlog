include "utils.nim"

var
    states = initStack()
    stack = initStack()

proc executeNode(node : nodeTuple) : void =
    case node.kind
    of NtNum:
        stack.load(node.value)
    of NtAdd:
        stack.add(node.value)
    of NtSub:
        stack.subtract(node.value)
    of NtMul:
        stack.multiply(node.value)
    of NtDiv:
        stack.divide(node.value)
    of NtAddSubExpression:
        states.subAdd()
    of NtSubSubExpression:
        states.subSubtract()
    of NtMulSubExpression:
        states.subMultiply()
    of NtDivSubExpression:
        states.subDivide()
    of NtSubexpressionEnd:
        states.subEnd(stack)
    else:
        discard

proc traverseNodes(nodeList : seq[nodeTuple]) : void =
    try:
      var i : int = 0
      while i < nodeList.len():
            executeNode(nodeList[i])
            echo states, " ", stack
            i += 1
    except IndexDefect as id:
        discard id.msg

traverseNodes(@[(kind: NtSubexpressionStart, value: "n\n"), (kind: NtNum, value: "5"), (kind: NtAddSubExpression, value: "n\n"), (kind: NtSubexpressionStart, value: "n\n"), (kind: NtNum, value: "6"), (kind: NtDiv, value: "2"), (kind: NtSubexpressionEnd, value: "n\n"), (kind: NtSubexpressionEnd, value: "n\n")])
