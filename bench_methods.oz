functor
import
   Application(exit:Exit)
   MTime(time:Time diff:Diff) at 'time.ozf'
   System(showInfo:Show)
define
X
X = {NewCell 0}
class AClass
   meth init skip end
   meth a {self b} skip end
   meth b {self c} skip end
   meth c {self d} skip end
   meth d {self e} skip end
   meth e {self f} skip end
   meth f {self g} skip end
   meth g {self h} skip end
   meth h X := @X+1 end
   meth otherwise(C)
      X = C.1 in
      {self X}
   end
end
A = {New AClass init}
`$Rec` = w(x(y(z(a))))
`$Name` = "otherwise"
`$N` = 100
`$M` = 50000
for I in 1..`$N` do
   T0 T1 in
   {Time T0}
   for J in 1..`$M` do
      {A `$Rec`}
   end
   {Time T1}
   {Show `$Name`#" --- "#{Diff T0 T1}}
end
{Show @X}
{Exit 0}
end
