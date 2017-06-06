functor
import
   Application(exit:Exit)
   MTime(time:Time diff:Diff) at 'time.ozf'
   System(showInfo:Show)
define
   `$It` = 100
   `$N` = 2000000
   %`$LocalVars`
   `$Method`=none

   class AddClass
      meth init() skip end
      meth add(A B R)
         if A == 0 then
            R = B
         else A1 B1 in
            A-1 = A1 B+1 = B1
            {self add(A1 B1 R)}
         end
      end

      meth '_iadd'(A B R)
         if A == 0 then
            R = B
         else
            {self iadd(A-1 B+1 R)}
         end
      end

      meth otherwise(M)
         case M of iadd(A B R) then
            {self '_iadd'(A B R)}
         end
      end
   end

   proc {Add A B R}
      if A == 0 then
         R = A
      else
         {Add A-1 B+1 R}
      end
   end

   A = {NewCell 0}
   if `$Method` == none then
      for R in 1..`$It` do
         local
            T0 T1
         in
            T0={Time}
            A := {Add `$N` 0}
            T1={Time}
            {Show " --- "#({Diff T0 T1})}
         end
      end
   else
      Add = {New AddClass init()} in
      for R in 1..`$It` do
         local
            T0 T1
         in
            T0={Time}
            A := {Add `$Method`(`$N` 0 $)}
            T1={Time}
            {Show " --- "#({Diff T0 T1})}
         end
      end
   end
   {Exit 0}
end
