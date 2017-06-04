functor
import
   Application(exit:Exit)
   MTime(time:Time diff:Diff) at 'time.ozf'
   System(showInfo:Show)
   Browser(browse:Browse)
define
  /*fun {Add A B}
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
  end*/

  fun {Gen I}
    if I == 0 then nil
    else I|{Gen I-1} end
  end

  fun {MapPat L F}
    case L of H|T then
      {F H}|{MapPat T F}
    [] nil then nil end
  end

  fun {MapFeat L F}
    if L == nil then
      nil
    else
      {F L.1}|{MapFeat L.2 F}
    end
  end
  `$N` = 400
  `$It` = 1000
  `$Map` = Map
  `$Name` = ""
  L = {Gen `$N`}

  A = {NewCell 0}
  for R in 1..`$It` do
    local
         T0 T1
      in
        T0 = {Time}
        A := {Map L fun {$ X} 11*X end}
        T1 = {Time}
        {Show `$Name`#' --- '#({Diff T0 T1})}
      end
   end
   {Exit 0}
end
