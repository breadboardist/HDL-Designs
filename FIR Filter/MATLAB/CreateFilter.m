%Mini Proj 2 - FIR Filter Design using MATLAB and Verilog HDL
clc;
clear;
%Using fir1 to design filter
%-- h = filter object
%-- b = filter coefficients
h = fir_design;
b = get (h,'numerator');

%Generate input vector using sampdata
x = sampdata (200);

%Perform filter operation
ytemp = conv (b,x); % y = matlab simulated output
y = ytemp(1:200);   % later used to calculate error

%Convert floating point coefficients to Q0.16 format
for n=1:9
    bQ(n,:)=dec2q(b(n),'bin',16,16);
end
%Write out the coefficients to text file
fileID = fopen('filtercoeffs.txt','w');
bQstr = cellstr(bQ);
for n=1:9
    fprintf(fileID,'%s\n',bQstr{n,:});
end

%Convert the floating point input to Q1.15 format
for n=1:200
    xQ(n,:)=dec2q(x(n),'hex',16,15);
end
fileID = fopen('input.txt','w');
xQstr = cellstr(xQ);
for n=1:200
    fprintf(fileID,'%s\n',xQstr{n,:});
end

%Read the verilog simulated output and convert to floating point
fileID = fopen('output.txt','r');
outRaw = textscan(fileID,'%s');
outArr = [outRaw{:}];
outTemp = cell2mat(outArr);
output = cellstr(outTemp);
for n=1:200
    Y(n) = q2dec(output{n},'hex',33,31);
end

%Convert the quantized input to floating point
for n=1:200
    X(n) = q2dec(xQstr{n},'hex',16,15);
end

%Plotting input and output of the filter
subplot(2,2,1);
plot(x); %original input
axis([0 200 -6 6]);
title('Input Samples');
xlabel('Sample Number');
ylabel('Amplitude');
subplot(2,2,2);
plot(y); %matlab simulated output (ideal)
title('Matlab Convolution Output');
xlabel('Sample Number');
ylabel('Amplitude');
subplot(2,2,3);
plot(X); %quantized input
axis([0 200 -1.5 1.5]);
title('Quantized Input Samples');
xlabel('Sample Number');
ylabel('Amplitude');
subplot(2,2,4);
plot(Y); %verilog output
title('Verilog Output');
xlabel('Sample Number');
ylabel('Amplitude');

%Error Calculation between MATLAB and Verilog
norm_y=(y)/(max(y)); %Normalize output
err=Y-norm_y;
err2=err.^2;
mserr=sum(err2)/length(err2); %Mean Square Error
pkserr=max(abs(err)); %Peak Absolute Error