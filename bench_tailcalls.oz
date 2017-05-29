functor
import
   Application(exit:Exit)
   MTime(time:Time diff:Diff) at 'time.ozf'
   System(showInfo:Show)
define
   `$It` = 50
   `$N` = 1000000

   proc {Add A B R}
      if A == 0 then
         R = A
      else
         `$LocalVars` in /*
         `$A1` `$B1` in A-1=`$A1` B+1=`$B1` %*/
         {Add `$A1` `$B1` R}
      end
   end

   A = {NewCell 0}
   for R in 1..`$It` do
      local
         T0 T1
      in
         T0={Time}
         A := {Add `$N` 0}
         T1={Time}
         {Show " --- "#({Diff T0 T1})}
      end
   end
   {Exit 0}
end
