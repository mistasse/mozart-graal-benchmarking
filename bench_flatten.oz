functor
import
   System(showInfo:Show)
   Boot_Time(getMonotonicTime: Time) at 'x-oz://boot/Time'
define
   fun {Times L T}
      if T == 0 then
         nil
      else
         L|{Times L T-1}
      end
   end
   `$N` = 100
   `$It` = 100
   `$BN` = 3
   `$CN` = 3
   `$Hot` = false
   A = {Times x `$N`}
   B = {Times A `$BN`}
   C = {Times B `$CN`}
   `$Depth` = C
   `$Name` = ""

   for R in 1..`$It` do
      local
         T0 T1
      in
         T0={Time}
         _ = {Flatten `$Depth`}
         T1={Time}
         {Show `$Name`#" --- "#(T1-T0)}
      end
   end
   if `$Hot` then
     for R in 1..`$It` do
        local
           T0 T1
        in
           T0={Time}
           _ = {Flatten `$Depth`}
           T1={Time}
           {Show `$Name`#"_hot --- "#(T1-T0)}
        end
     end
   end
end
