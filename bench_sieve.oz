functor
import
   Application(exit:Exit)
   MTime(time:Time diff:Diff) at 'time.ozf'
   System(showInfo:ShowInfo)
define
   `$Sieve`=Sieve
   `$N`=10000
   `$It`=100
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
      [] X|T then
         {Touch T}
      end
   end
   proc {LazyFilter Xs P R}
      thread
         {WaitNeeded R}
         case Xs of
            nil then R = nil
         [] X|Xr then
            if {P X} then
               R = X|{LazyFilter Xr P}
            else
               {LazyFilter Xr P R}
            end
         end
      end
   end
   proc {LazySieve Xs R}
      thread
         {WaitNeeded R}
         case Xs of nil then R=nil
         [] X|Xr then
            Ys
         in
            thread
               {LazyFilter Xr fun {$ Y} (Y mod X) \= 0 end Ys}
            end
            if `$SqrtOpt` andthen X*X > `$N` then
               R = X|Ys
            else
               R = X|{LazySieve Ys}
            end
         end
      end
   end
   fun {Sieve Xs}
      case Xs of nil then nil
      [] X|Xr then
         Ys
      in
         thread
            {Filter Xr fun {$ Y} (Y mod X) \= 0 end Ys}
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

