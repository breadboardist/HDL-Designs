% y = sampdata;
%
%   This function returns a test sample data set to be used for 
%       signal processing problems.
%
function y4 = sampdata(xlen)

ntaps = 65;  % Design filter to make the data band limited.
f = [0.0 0.9 0.95 1.0];
mag = [ 1.0 1.0 0.7071 0.0];
b = fir2(ntaps, f, mag);
a = 1.0;

t = linspace(0,1,floor(xlen/2));
y1 = 5*square(2*pi*2*t);
y2 = filter(b, a, y1);
x = zeros(1,ceil(xlen/2));

for k=1:ceil(xlen/2)
    m = (k-1);
    t1 = 5*cos(0.1*pi*m + 0.5*pi);
    t2 = 2*cos(0.75*pi*m + 0.5*pi);
    t3 = 1*cos(0.92*pi*m + 0.5*pi);
    x(k) = t1 + t2 + t3;
end

win = transpose(hanning(ceil(xlen/2)));
y3 = win.*x;

y4 = [y2 y3];
return
