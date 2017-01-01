functor
import
   System(showInfo:Show)
   Browser(browse:Browse)
   Boot_Time(getMonotonicTime:Time) at 'x-oz://boot/Time'
define

  MyPow
   local
    fun {Pow B E R}
      if E == 0 then R
      else if (E mod 2) == 0 then {Pow B*B E div 2 R}
      else {Pow B E-1 R*B} end end
    end
   in
    fun {MyPow B E}
      {Pow B E 1}
    end
   end
   `$Pow` = MyPow
   `$It` = 50
   A = {NewCell 0}
   for R in 1..`$It` do
      local
         T0 T1
      in
         T0={Time}
            for Y in 1..10 do
              A := {`$Pow` Y 7}
            end
         T1={Time}
         {Show `$It`#" --- "#(T1-T0)}
      end
   end

end
