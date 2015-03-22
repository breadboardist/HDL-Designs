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
     //Add code here to print the numbers in assending order
     //-----------------------------------------------------
        // printascending(root.lpt);
        $display("%d",root.value);
        // printascending(root.gpt);
   end
 endfunction
 
 function automatic void printdescending;
   begin
     //------------------------------------------------------
     //Add code here to print the numbers in descending order
     //------------------------------------------------------   
   end
 endfunction


endclass

