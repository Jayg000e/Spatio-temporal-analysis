%第一种拟合方法所拟合的函数
function vario=variogramfit(c,r)
vario=(c(1)+c(2)*(1-exp(-(r/c(3)).^2)))/2;