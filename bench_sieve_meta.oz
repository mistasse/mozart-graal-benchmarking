functor
import
   Application(exit:Exit)
   MTime(time:Time diff:Diff) at 'time.ozf'
   System(showInfo:ShowInfo)
define
   `$Sieve`=Sieve
   `$N`=[5000,10000,150000,20000,25000]
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
   proc {LazySieve Xs N R}
      thread
         {WaitNeeded R}
         case Xs of nil then R=nil
         [] X|Xr then
            Ys
         in
            thread
               {LazyFilter Xr fun {$ Y} (Y mod X) \= 0 end Ys}
            end
            if `$SqrtOpt` andthen X*X > N then
               R = X|Ys
            else
               R = X|{LazySieve Ys N}
            end
         end
      end
   end
   fun {Sieve Xs N}
      case Xs of nil then nil
      [] X|Xr then
         Ys
      in
         thread
            {Filter Xr fun {$ Y} (Y mod X) \= 0 end Ys}
         end
         if `$SqrtOpt` andthen X*X > N then
            X|Ys
         else
            X|{Sieve Ys N}
         end
      end
   end
   fun {Mean L Skip N Acc}
      case L of nil then Acc div N
      [] H|T then
         if Skip == 0 then
            {Mean T Skip N+1 Acc+H}
         else
            {Mean T Skip-1 N Acc}
         end
      end
   end

   A = {NewCell 0}

   Measures = {MakeRecord measures `$N`}
   Lists = {MakeRecord integers `$N`}
   for N in `$N` do
      Lists.N = {Generate 2 N}
      Measures.N = {NewCell nil}
   end

   for I in 1..`$It` do
      for N in `$N` do
         T0 T1
         Integers = Lists.N
         Meas = Measures.N
      in
         T0 = {Time}
         A := {`$Sieve` Integers N}
         {Touch @A}
         T1 = {Time}
         if I >= (`$It` div 2) then
            Meas := {Diff T0 T1}|@Meas
         end
      end
   end
   for N in `$N` do   
      {ShowInfo `$Name`#" --- "#{Mean @(Measures.N) 0 0 0}}
   end
   {Exit 0}
end

