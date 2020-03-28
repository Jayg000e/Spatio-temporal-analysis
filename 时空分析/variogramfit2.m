%第二种拟合方法所拟合的函数
function f=variogramfit2(c,r)
f=c(1)/2 + (c(2)*r.^2)/(2*c(3).^2)- (c(2)*r.^4)/(4*c(3).^4);
    