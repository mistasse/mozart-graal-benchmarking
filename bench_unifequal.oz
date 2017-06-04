functor
import
   Application(exit:Exit)
   MTime(time:Time diff:Diff) at 'time.ozf'
   System(showInfo:Show)
   Browser(browse:Browse)
define
   `$It` = 1000
   `$N` = 1000
   A = {NewCell 0}
   fun {X}
      a(1 b(2 c(3 d(4 e(5 f(6 g(7 h(8 i(9 j(10 k(11 l(12 m(13 n(14 o(15
         )))))))))))))))
   end
   fun {Y}
      A B C D E F G H I J K L M N O R in
      R = a(A b(B c(C d(D e(E f(F g(G h(H i(I j(J k(K l(L m(M n(N o(O
           )))))))))))))))
      A=1 B=2 C=3 D=4 E=5 F=6 G=7 H=8 I=9 J=10 K=11 L=12 M=13 N=14 O=15
      R
   end
   fun {Z}
      A B C D E F G H I J K L M N O R in
      R = a(A b(2 c(C d(4 e(E f(6 g(G h(8 i(I j(10 k(K l(12 m(L n(14 o(O
         )))))))))))))))
      A=1 B=2 C=3 D=4 E=5 F=6 G=7 H=8 I=9 J=10 K=11 L=12 M=13 N=14 O=15
      R
   end
   `$X`=X
   `$Y`=X
   P = {`$X`}
   Q = {`$Y`}
   `$Op` must be commented
   for R in 1..`$It` do
      local
         T0 T1
      in
         T0={Time}
         for I in 1..`$N` do
            A := (P `$Op` Q)
         end
         T1={Time}
         {Show "`$Op` --- "#({Diff T0 T1})}
      end
   end
   {Exit 0}
end
