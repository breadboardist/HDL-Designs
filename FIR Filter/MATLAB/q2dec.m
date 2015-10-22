%Function to Q format to floating point
function [y]=q2dec(x,form,m,n)
if (form == 'hex')
    x=hex2dec(x);
    x=dec2bin(x,m);
end;

option = {'mode','roundmode','overflowmode','format'}; 
value = {'fixed','ceil','saturate',[m n]}; 
q = quantizer(option,value);
y = bin2num(q,x);
end


        