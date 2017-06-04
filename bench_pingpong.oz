functor
import
   Application(exit:Exit)
   MTime(time:Time diff:Diff) at 'time.ozf'
   System(showInfo:Show)
   Property(get:GetProperty)
define
   `$It` = 1
   `$N` = 250000 % Iterations
   `$MemFB` = 500000 % Iterations per memory feedback
   `$Ping`=Ping
   `$Pong`=Pong

   proc {Ping S I}
      if I == 0 then
         skip
      else
         case S of pong|A then
            A = ping|_
            {Ping A.2 I-1}
         end
      end
   end

   fun {Pong S I}
      if I == 0 then
         unit
      else
         case S of ping|A then
            A = pong|_
            {Pong A.2 I-1}
         end
      end
   end

   fun {PongMem S I}
      if I == 0 then
         unit
      else
         case S of ping|A then
            A = pong|_
            if (I mod `$MemFB`) == 0 then
               {Show "memory --- "#{GetProperty 'gc.size'}}
            end
            {PongMem A.2 I-1}
         end
      end
   end

   A = {NewCell 0}
   for R in 1..`$It` do
      local
         T0 T1
         S = ping|_
      in
         thread {`$Ping` S.2 `$N`} end
         T0={Time}
         A := {`$Pong` S `$N`}
         T1={Time}
         {Show " --- "#({Diff T0 T1})}
      end
   end
   {Exit 0}
end
