functor
import
   System(show:Show)
   Boot_Int('l<<':`l<<` 'xor':`xor`) at 'x-oz://boot/Int'
define

proc {Mandelbrot Size R}
   Sum = {NewCell 0}
   Acc = {NewCell 0}
   Num = {NewCell 0}

   proc {ZLoop Z Cr Ci Zr Zi Zrzr Zizi Escape}
   if Z == 0 then
      Escape = 1
   else
      Zr_ = Zrzr - Zizi + Cr
      Zi_ = (2.0 * Zr * Zi) + Ci
      Zrzr_ = Zr_*Zr_
      Zizi_ = Zi_*Zi_
   in
      if Zrzr_ + Zizi_ > 4.0 then
         Escape = 0
      else
         {ZLoop
            Z-1   % Z
            Cr    % Cr
            Ci    % Ci
            Zr_   % Zr
            Zi_   % Zi
            Zrzr_ % Zrzr
            Zizi_ % Zizi
            Escape
         }
      end
   end
   end


   proc {XLoop X Size Ci Acc Num Sum R}
   if X == Size then
      R = Sum
   else
      Cr = (2.0*{IntToFloat X}/{IntToFloat Size}) - 1.5 % CONVERSION
      Acc_ = Acc * 2 + {ZLoop 50 Cr Ci 0.0 0.0 0.0 0.0}
      Num_ = Num + 1
   in
      if Num_ == 8 then
         {XLoop
            X+1               % X
            Size              % Size
            Ci
            0                 % Acc
            0                 % Num
            {`xor` Sum Acc_}  % Sum
            R
         }
      elseif X == Size-1 then
         {XLoop
            X+1                              % X
            Size                             % Size
            Ci
            0                                % Acc
            0                                % Num
            {`xor` Sum {`l<<` Acc_ 8-Num_}}  % Sum
            R
         }
      else
         {XLoop X+1 Size Ci Acc_ Num_ Sum R}
      end
   end
   end
   
   proc {YLoop Y Size Sum R}
      if Y == Size then
         R = Sum
      else
         Ci = (2.0*{IntToFloat Y}/{IntToFloat Size}) - 1.0 % CONVERSION
      in
         {YLoop Y+1 Size {XLoop 0 Size Ci 0 0 Sum} R}
      end
   end

in
   {YLoop 0 Size 0 R}
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
