type
    register = tuple[f1 : float]

    state = enum
      adding, subtracting, multiplying, dividing, loading, programStart

    stateMachine = object 
      states : seq[state]
      registers : seq[register]
      index : uint
