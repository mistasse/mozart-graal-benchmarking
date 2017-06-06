functor
import
   OS
   Boot_Time at 'x-oz://boot/Time'
   System(showInfo:ShowInfo)
   Property(get:GetProperty)
export
   time: Time
   diff: Diff
define
   Time Diff
   BTime = Boot_Time
   proc{Memory}
      {ShowInfo "memory --- "#{GetProperty 'gc.size'}}
   end
   {Memory}
   if {HasFeature BTime getMonotonicTime} then
      Time = BTime.getMonotonicTime
      fun{Diff X Y}
         {Memory}
         Y - X
      end
   else
      %/* GOOD, takes ~1ms on my server
      fun {Time}
         Stdout
      in
         {OS.pipe date ["+%s%N"] _ Stdout#_}
         Stdout
      end
      fun{Diff StdoutX StdoutY}
         OutX OutY
      in
         {Memory}
         {OS.wait _ _}
         {OS.wait _ _}
         {OS.read StdoutX 30 OutX nil _}
         {OS.read StdoutY 30 OutY nil _}
         {OS.close StdoutX}
         {OS.close StdoutY}
         {StringToInt OutY} - {StringToInt OutX}
      end %*/
      /* NOT GOOD, ONLY PRECISE TO 10ms
      fun {Time}
         {GetProperty 'time.total'}
      end
      fun {Diff X Y}
         {ShowInfo X#' - '#Y}
         (Y*1000000) - (X*1000000)
      end %*/
   end
end
