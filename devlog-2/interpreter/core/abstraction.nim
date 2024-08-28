from "..\\..\\compiler\\types.nim" import NodeTypes, nodeTuple
include "utils.nim"

var stack : Stack = initStack()

proc executeNode(node : nodeTuple) : void =
    case node.kind
    of NtNum:
        executeLoad(stack, node.value)
    else:
        discard
proc traverseNodes(nodeList : seq[nodeTuple], callBackFunc : proc(node : nodeTuple)) =
  var i = 0
  while i < nodeList.len:
    callBackFunc(nodeList[i])
    inc(i)