import streams
import os

proc toUTF8(inputString : string) : seq[int64] =
  var returnSequence : seq[int64] = @[]
  for character in inputString:
    returnSequence.add(int64(ord(character)))
  return returnSequence

proc fromUTF8(inputSequence : openArray[int64]) : string =
  var returnString : string = ""
  for byteCharacter in inputSequence:
    returnString = returnString & char(chr(byteCharacter))
  return returnString

proc store(fn: string, data: openArray[int64]) =
  var s = newFileStream(fn, fmWrite)
  for x in data:
    s.write(x)
  s.close()

proc load(fn: string): seq[int64] =
  if not fileExists(fn):
    echo "File does not exist: ", fn
    return @[]
  
  var s = newFileStream(fn, fmRead)
  result = @[]
  while not s.atEnd:
    let value = s.readInt64()
    result.add(value)
  s.close()
  return result