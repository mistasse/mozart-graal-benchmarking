functor
import
   System(showInfo:ShowInfo gcDo:GcDo)
   Property(get:GetProperty)
   Application(exit:Exit)
define
   proc {Atom R}
      R = atom
      skip
   end
   proc {Int R}
      {StringToInt "1" R}
      skip
   end
   proc {List S X R}
      case S of 0 then
         R = nil
      else R2 in
         R = {X}|R2
         {List S-1 X R2}
      end
   end
   proc {Record S X R}
      case S of 0 then
         R = S
      else R2 in
         R = rec({X} R2)
         {Record S-1 X R2}
      end
   end
   proc {LargeRecord S X R}
      case S of 0 then
         R = S
      else R2 in
         R = rec({X} {X} R2)
         {LargeRecord S-1 X R2}
      end
   end
   proc {FullRecord S X R}
      case S of 0 then
         R = S
      else R2 in
         R = rec({X} {X} {X} R2)
         {FullRecord S-1 X R2}
      end
   end
   `$Type`=List
   `$Value`=Int
   `$Size`=8000
   A = {NewCell 0}
   B = {NewCell 0}
   R = {NewCell _}
   proc {Measure}
      A := _
      B := _
      R := _
      {GcDo}
      {GetProperty 'gc.size' @A}
      {`$Type` `$Size` `$Value` @R}
      {GcDo}
      {GetProperty 'gc.size' @B}
      {ShowInfo "memory --- "#(@B-@A)}
      skip
   end
   for I in 1..1000 do
      {Measure}
   end
   {Exit 0}
end
