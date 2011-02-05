calculator {
  ; parse string
  var %string $1-
  %string = $_checkCalc(%string)
  ; save string
  ; replace constant functions with value
  ; determine x dependency
  ; ->calc
  ; ->solve
  return %string
}
ScanString {
  var %string $1, %index 1, %newString, %strLen $len(%string), %char, %lastChar, %calcId $iif($2, $2, $thread)
  if (!$2) { oadd %calcId solve $false | oadd %calcId recursions 1 }
  echo -a %string : %strLen
  while (%index <= %strLen) {
    %char = $mid(%string, %index, 1)
    if (%char isnum) { ; add numbers to the string
      var %num, %point $false
      while ($mid(%string, %index, 1) isin ., || $mid(%string, %index, 1) isnum) {
        %char = $mid(%string, %index, 1)
        if (%char == ,) { inc %index | continue }
        if (%char == . && !%point) { inc %index | %point = $true | continue }
        elseif (%char == . && %point) { return $false }
        %num = %num $+ %char
        inc %index
      }
      %newString = %newString $+ %num
    }
    elseif ($isOperator(%char)) { ; add operators to the string
      %newString = %newString $+ %char
      inc %index
    }
    elseif (%char isin $chr(40) $+ [) { ; add brackets to the string
      var %lastRealChar %lastChar, %i $calc(%index - 1)
      while (%lastChar == $chr(32) && %i) {
        dec %i
        %lastChar = $mid(%string, %i, 1)
      }
      if (!$isOperator(%lastChar) && %lastChar && %lastChar !isin $chr(40) $+ [) {
        %newString = %newString $+ *
      }
      %newString = %newString $+ (
      inc %index
    }
    elseif (%char isin ] $+ $chr(41)) { ; add brackets to the string
      %newString = %newString $+ )
      inc %index
    }
    elseif (%char isletter) { ; add functions and skills to the string
      var %func, %funcArgVal, %funcName = $true, %funcArg $false, %isFunc $true, %brackets 0
      ; stay inside function name while next char is a letter, a space, a bracket and while the string length isn't reached.

      ; parse functions
      while (%index <= %strLen) {
        %char = $mid(%string, %index, 1)
        if (!%funcArg) {
          ; add *x if x appears as an unknown (not in the middle of a function name or argument.)
          if (%char == x && %lastChar && !$isOperator(%lastChar) && %lastChar !isletter && %lastChar !isin $($chr(40) $+ [,2) && %lastChar != $chr(32)) {
            %newString = %newString $+ *x
            %isFunc = $false
            inc %index
            break
          }
          elseif (%char == x && ($isOperator(%lastChar) || !%lastChar || %lastChar isin $chr(40) $+ $chr(41) $+ ][)) { ; add x if x appears as an unknown (not in the middle of a function name or argument.)
            %newString = %newString $+ x
            %isFunc = $false
            inc %index
            break
          }
          elseif (%char == x) {
            echo -a escaping through overflow! : %index
            %newString = %newString $+ x
            %isFunc = $false
            inc %index
            break
          }
        }


        if (%funcName) { ; if we are still building the function name
          if (%char isin $chr(40) $+ [) { ; if we reach the argument portion of the function, move on@
            %funcName = $false
            %funcArg = $true
            %func = %func $+ (
            inc %brackets
          }
          else { ; otherwise continue building function name
            if (%lastChar == x && $len(%func) == 0) { %func = x | %newString = $left(%newString, -1) }
            %func = %func $+ %char
          }
        }
        else { ; build the argument of the function
          if (%char isin $($chr(40) $+ [,2)) inc %brackets
          if (%char isin $($chr(41) $+ ],2)) dec %brackets
          if (%brackets == 0) {
            %func = %func $+ )
            echo -a %func : %funcArgVal
            if (!$takesNonNumericArgument($left(%func, -2))) {
              %funcArgVal = $recurseScan(%funcArgVal, %calcId)
            }
            inc %index
            break
          }

          %funcArgVal = %funcArgVal $+ $iif(%lastChar != $chr(32), %char, $chr(32) %char)
        }
        inc %index
        %lastChar = %char
      }

      if (%funcArg && %isFunc) { ; if the function has an argument, add the function to the string
        var %s $null
        if ($numtok(%funcArgVal, 44) > 1) var %s = s
        echo -a function: %func argument $+ %s $+ : %funcArgVal
        %newString = %newString $+ $left(%func, -1) $+ %funcArgVal $+ )
      }
      elseif (%isFunc) { ; otherwise fail.
        echo -a $false is constant@ %func
        %newString
      }
    }
    elseif (%char == $chr(32)) { ; remove spaces from between terms
      inc %index
    }
    else { ; character is not a number, bracket, operator or function
      echo -a $false
      inc %index
    }
    %lastChar = %char
  }
  hinc %calcId recursions -1
  if ($$$(%calcId).recursions == 0) {
    echo -a %string > %newString
  }
  else {
    return %newString
  }
}
recurseScan {
  hinc $2 recursions
  return $scanString($1, $2)
}
isOperator {
  var %char $1
  if (%char isin +-*/^%) { return $true }
  return $false
}
isConstantFunction {
  var %func $1, %arg $2, %calcId $3
  ; functions which take items are always constant.
  if ($takesNonNumericArgument($1)) { return $true }
  ; all arguments are now numerical
  ; function argument is a simple number
  if (%arg isnum) { return $true }

  oadd %calcId solve $true
  return $false
}
isConstant {
}
takesNonNumericArgument {
  var %constantFunctions price ge xp exp
  if ($istok(%constantFunctions, $1, 32)) { return $true }
}
