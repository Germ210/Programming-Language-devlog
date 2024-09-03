( 
 (5 + (2 / 2))
)
->

load 5 onto the stack

push an add onto the stack of states

start a subexpression

load 2 onto the stack (different from 5, as it is higher on the stack and has a higher priority)

divide the top value on the stack by 2

pop the value on the stack, then because the top of the states stack is add, add it to the new top of the stack


a pop function takes the top of a stack, returns it and removes it from the stack.

for example, lets say you have a stack like this: stack = [1,2,3,4,5]

variable = stack.pop()

print variable //outputs 5

print stack // outputs [1,2,3,4]
