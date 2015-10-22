%Function to convert floating point to Q format
function [y]=dec2q(x,form,m,n)

option = {'mode','roundmode', 'overflowmode', 'format'}; 
value = {'fixed','ceil','saturate',[m n]}; 
q = quantizer(option,value);

if form == 'bin'
    y=num2bin(q,x);
end;

if form == 'hex'
    y=num2hex(q,x);
end;

end