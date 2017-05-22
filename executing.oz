functor
import
   System(show:Show)
   Boot_Int at 'x-oz://boot/Int'
define

proc {Mandelbrot Size R}
   Sum = {NewCell 0}
   Acc = {NewCell 0}
   Num = {NewCell 0}
in
   for Y in 0..(Size-1) do
      Ci = {NewCell (2.0*{IntToFloat Y}/{IntToFloat Size}) - 1.0} % CONVERSION
   in
      for X in 0..(Size-1) do
         Zr = {NewCell 0.0}
         Zrzr = {NewCell @Zr}
         Zi = {NewCell 0.0}
         Zizi = {NewCell @Zi}
         Cr = (2.0*{IntToFloat X}/{IntToFloat Size}) - 1.5 % CONVERSION
         Escape = {NewCell 1}
      in
         for Z in 0..49 do
            Tr = @Zrzr - @Zizi + Cr
            Ti = (2.0 * @Zr * @Zi) + @Ci
         in
            if @Escape == 1 then
            Zr := Tr
            Zi := Ti

            Zrzr := @Zr * @Zr
            Zizi := @Zi * @Zi
            if @Zrzr + @Zizi > 4.0 then
               Escape := 0
            end
            end
         end % end for Z
         
         Acc := @Acc * 2 + @Escape
         Num := @Num + 1
         if @Num == 8 then
            Sum := {Boot_Int.xor @Sum @Acc}
            Acc := 0
            Num := 0
         elseif X == Size-1 then
            Acc := {Boot_Int.'l<<' @Acc 8-@Num}
            Sum := {Boot_Int.xor @Sum @Acc}
            Acc := 0
            Num := 0
         end
      end % end for X
   end % end for Y
   R = @Sum
end % end of Mandelbrot

`$Iterations` = 100
`$ProblemSize` = 1000
Result = {NewCell 0}

{Show {Mandelbrot 750}}
for I in 0..(`$Iterations`-1) do
   Result := @Result + {Mandelbrot `$ProblemSize`}
end

if @Result == 0 then
   {Show notok}
else
   {Show ok}
end
end