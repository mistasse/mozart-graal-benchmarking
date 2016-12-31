functor
import
   System(showInfo:Show)
   Browser(browse:Browse)
   Boot_Time(getMonotonicTime:Time) at 'x-oz://boot/Time'
define
  fun {Add A B}
    if B == 0 then
      A
    else
      {Add A+1 B-1}
    end
  end

  fun {Sub A B}
    if B == 0 then
      A
    else
      {Sub A-1 B-1}
    end
  end

  fun {Gen I}
    if I == 0 then nil
    else I|{Gen I-1} end
  end

  fun {Map L F}
    case L of H|T then
      {F H}|{Map T F}
    [] nil then nil end
  end

  fun {Map2 L F}
    if L == nil then
      nil
    else
      {F L.1}|{Map2 L.2 F}
    end
  end
  `$N` = 400
  `$It` = 1000
  `$Name` = "default"
  L = {Gen `$N`}

  A = {NewCell 0}
  for R in 1..`$It` do
    local
         T0 T1
      in
        T0 = {Time}
        A := {Map L fun {$ X} {Add 3 X} end}
        A := {Map2 L fun {$ X} {Add 3 X} end}
        A := {Map L fun {$ X} {Sub 3 X} end}
        A := {Map2 L fun {$ X} {Sub 3 X} end}
        T1 = {Time}
        {Show `$Name`#' --- '#(T1-T0)}
      end
   end

end
