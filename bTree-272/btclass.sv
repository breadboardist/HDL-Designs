// A class for the binary tree homework problem.

class btclass;
 btclass lpt;
 btclass gpt;
 integer value;

 function automatic void add(input btclass nn);
   begin
     if(nn.value < value) begin
       if(lpt) lpt.add(nn); else lpt=nn;
     end else begin
       if(gpt) gpt.add(nn); else gpt=nn;
     end
     return;
   end
 endfunction

  function new(input integer vl);
   begin
     value=vl;
     lpt=null;
     gpt=null;
   end
 endfunction

 function automatic void printascending(input btclass root);
   begin
     //-----------------------------------------------------
     //Print the numbers in assending order
     //-----------------------------------------------------
        if (root == null) return;
        printascending (root.lpt);
        $display("Value=%d",root.value);
        printascending (root.gpt);
   end
 endfunction
 
 function automatic void printdescending(input btclass root);
   begin
     //------------------------------------------------------
     //Print the numbers in descending order
     //------------------------------------------------------
     if (root == null) return;
        printdescending (root.gpt);
        $display("Value=%d",root.value);
        printdescending (root.lpt);   
   end
 endfunction


endclass

