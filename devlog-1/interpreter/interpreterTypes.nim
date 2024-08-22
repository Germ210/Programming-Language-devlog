import tables
type
    register = tuple[f1 : float]

    state = enum
      adding, subtracting, multiplying, dividing, loading, programStart
    
    variableEnum = enum
      number

    stateMachine = object 
      states : seq[state]
      registers : seq[register]
      variable : Table[string, register]
      index : uint