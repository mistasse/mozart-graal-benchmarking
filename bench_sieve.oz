functor
import
  System(show:Show)
  Boot_Time(getMonotonicTime: Time) at 'x-oz://boot/Time'
  Browser(browse:Browse)
define
  fun {Generate N Limit}
   if N<Limit then
      N|{Generate N+1 Limit}
   else
      nil
   end
  end
  fun {Touch L}
   case L of nil then
      nil
   [] H|T then
      H|{Touch T}
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
      X|{Sieve Ys}
   end
  end
  A = {NewCell 0}
  `$End` = 10000
  A := {Sieve {Generate 2 `$End`}}
  {Show {Touch @A}}
end

