%计算100*100随机场中两个点间的距离
function r=dist(num1,num2)
[x1,y1]=num2site(num1);
[x2,y2]=num2site(num2);
r=sqrt((x1-x2)^2+(y1-y2)^2);