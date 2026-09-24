% clear
% clc
% syms a b c x4 x3 x2 x xy x2y y n
% 
% eq1 = a*x4 + b*x3 + c*x2 == x2y;
% eq2 = a*x3 + b*x2 + c*x == xy;
% eq3 = a*x2 + b*x + c*n == y;
% 
% tmpA = [x4 x3 x2;
%         x3 x2 x;
%         x2 x  n;];
% tmp_b = [x2y;xy;y;];
% tmp_x = tmpA\tmp_b;

% [as,bs,cs] = solve([eq1,eq2,eq3],[a,b,c]);
Vpva = Vres;
Ppva = Pres;
x = sum(Vpva);
x2 = sum((Vpva.^2));
x3 = sum((Vpva.^3));
x4 = sum((Vpva.^4));
y = sum(Ppva);
xy = sum(Vpva.*Ppva);
x2y = sum(Ppva.*(Vpva.^2));
n = length(Vpva);
% 
% tmpA = [x4 x3 x2;
%         x3 x2 x;
%         x2 x  n;];
% tmp_b = [x2y;xy;y;];
% tmp_x = tmpA\tmp_b;
% 
% A  = tmp_x(1);
% B  = tmp_x(2);
% C  = tmp_x(3);
% 
A = (x2y*x^2 - xy*x*x2 - x3*y*x + y*x2^2 - n*x2y*x2 + n*x3*xy)/(x4*x^2 - 2*x*x2*x3 + x2^3 - n*x4*x2 + n*x3^2);
B = (x2^2*xy + n*x3*x2y - n*x4*xy - x*x2*x2y + x*x4*y - x2*x3*y)/(x4*x^2 - 2*x*x2*x3 + x2^3 - n*x4*x2 + n*x3^2);
C = (x2y*x2^2 - xy*x2*x3 - x4*y*x2 + y*x3^2 - x*x2y*x3 + x*x4*xy)/(x4*x^2 - 2*x*x2*x3 + x2^3 - n*x4*x2 + n*x3^2);
 
plot(fitv,A*fitv.^2 + B*fitv + C)