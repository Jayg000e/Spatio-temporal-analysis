%��1-10000�е���ת����100*100�����е�����
function [x,y]=num2site(num)
 if mod(num,100)==0
   x=num/100;
   y=100;
else 
   x=ceil(num/100);
   y=num-(x-1)*100;
end