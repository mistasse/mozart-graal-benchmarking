functor
import
   Application(exit:Exit)
   MTime(time:Time diff:Diff) at 'time.ozf'
   System(showInfo:ShowInfo)
define
   `$Sieve`=Sieve
   `$N`=10000
   `$It`=5000
   `$SqrtOpt`=false
   `$Name`=""
   fun {Generate N Limit}
      if N<Limit then
         N|{Generate N+1 Limit}
      else
         nil
      end
   end
   proc{Touch L}
      case L of nil then
         skip
      [] _|T then
         {Touch T}
      end
   end
   fun lazy {LazySieve Xs}
      case Xs of nil then nil
      [] X|Xr then
         Ys
      in
         thread
            Ys = {Filter Xr fun {$ Y} Y mod X \= 0 end}
         end
         if `$SqrtOpt` andthen X*X > `$N` then
            X|Ys
         else
            X|{LazySieve Ys}
         end
      end
   end
   fun {Sieve Xs}
      case Xs of nil then nil
      [] X|Xr then
         Ys
      in
         thread
            Ys = {Filter Xr fun {$ Y} Y mod X \= 0 end}
         end
         if `$SqrtOpt` andthen X*X > `$N` then
            X|Ys
         else
            X|{Sieve Ys}
         end
      end
   end

   A = {NewCell 0}
   Integers = {Generate 2 `$N`}
   for I in 1..`$It` do
      T0 T1
   in
      T0 = {Time}
      A := {`$Sieve` Integers}
      {Touch @A}
      T1 = {Time}
      {ShowInfo `$Name`#" --- "#{Diff T0 T1}}
   end
   {Exit 0}
end

