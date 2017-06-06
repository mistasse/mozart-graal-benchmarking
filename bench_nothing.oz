functor
import
   Application(exit:Exit)
   MTime(time:Time diff:Diff) at 'time.ozf'
   System(showInfo:Show)
   Browser(browse:Browse)
define
   `$It` = 1000
   A = {NewCell 0}
   for R in 1..`$It` do
      local
         T0 T1
      in
         T0={Time}
         A := nil
         T1={Time}
         {Show " --- "#({Diff T0 T1})}
      end
   end
   {Exit 0}
end
