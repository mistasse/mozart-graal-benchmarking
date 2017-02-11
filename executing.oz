functor
import
   System(showInfo:Show)
   Browser(browse:Browse)
   Boot_Time(getMonotonicTime:Time) at 'x-oz://boot/Time'
define
   `$It` = 50
   A = {NewCell 0}
   for R in 1..100000 do
      local
         T0 T1
      in
         T0={Time}
         A := nil
         T1={Time}
         {Show 100000#" --- "#(T1-T0)}
      end
   end

end