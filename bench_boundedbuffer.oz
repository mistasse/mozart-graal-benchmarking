functor
import
   Application(exit:Exit)
   %MTime(time:Time diff:Diff) at 'time.ozf'
   System(showInfo:Show)
define
   `$It`=20
   `$TimeUnit`=50000
   `$BoundedBuffer`=true
   `$Process`=Process
   `$ConsTime`=2
   `$ProdTime`=1
   `$InitTime`=2
   fun {BoundedBuffer In N}
      End=thread {List.drop In N} end
      fun lazy {Loop In End}
         case In of I|In2 then
            I|{Loop In2 thread End.2 end}
         end
      end
   in
      {Loop In End}
   end

   X = {NewCell 0.0}
   proc {Process Log Units}
      if Units == 0 then
         skip
      else
         {Show Log}
         X := @X + 1.0
         {Process Log Units-1}
      end
   end
   proc {ProcessWait Log Units}
      if Units == 0 then
         skip
      else
         {Show Log}
         {Delay 0}
         {ProcessWait Log Units-1}
      end
   end
   
   fun lazy {Producer I}
      if true then
         {`$Process` "active --- "#I `$ProdTime`*`$TimeUnit`}
      else
         {`$Process` "active --- "#I 1}
      end
      I|{Producer I+1}
   end

   proc {Consumer X In N}
      if N == 0 then
         skip
      else
         {`$Process` "active --- -"#X 1}
         case In of I|In2 then
            {`$Process` "active --- -"#I `$ConsTime`*`$TimeUnit`}
            {Consumer X+1 In2 N-1}
         end
      end
   end
   
   In = thread {Producer 1} end
   Out = if `$BoundedBuffer` then {BoundedBuffer In 5} else In end
   {`$Process` "active --- 0" `$InitTime`*`$TimeUnit`}
   {Consumer 1 Out `$It`}
   {Exit 0}
end
