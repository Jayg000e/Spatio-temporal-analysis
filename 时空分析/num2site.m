%将1-10000中的数转化成100*100矩阵中的坐标
function [x,y]=num2site(num)
 if mod(num,100)==0
   x=num/100;
   y=100;
else 
   x=ceil(num/100);
   y=num-(x-1)*100;
end