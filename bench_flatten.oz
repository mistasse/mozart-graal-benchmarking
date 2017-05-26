functor
import
   Application(exit:Exit)
   MTime(time:Time diff:Diff) at 'time.ozf'
   System(showInfo:Show)
define
    local
       fun {DoFlatten Xs Start End}
          case Xs of
             X|Xr then S S1 in
             if {DoFlatten X S S1}
             then S=Start {DoFlatten Xr S1 End}
             else S2 in Start=X|S2 {DoFlatten Xr S2 End}
             end
          [] nil then Start=End true
          else false
          end
       end
    in
       fun {MyFlatten X}
          Start in if {DoFlatten X Start nil} then Start else X end
       end
    end
    `$Flatten` = Flatten
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
   `$DN` = 3
   `$EN` = 3
   `$Hot` = false
   A = {Times x `$N`}
   B = {Times A `$BN`}
   C = {Times B `$CN`}
   D = {Times C `$DN`}
   E = {Times D `$EN`}
   `$Depth` = C
   `$Name` = ""

   for R in 1..`$It` do
      local
         T0 T1
      in
         T0={Time}
         _ = {`$Flatten` `$Depth`}
         T1={Time}
         {Show `$Name`#" --- "#{Diff T0 T1}}
      end
   end
   if `$Hot` then
     for R in 1..`$It` do
        local
           T0 T1
        in
           T0={Time}
           _ = {`$Flatten` `$Depth`}
           T1={Time}
           {Show `$Name`#"_hot --- "#{Diff T0 T1}}
        end
     end
   end
   {Exit 0}
end
