%��һ����Ϸ�������ϵĺ���
function vario=variogramfit(c,r)
vario=(c(1)+c(2)*(1-exp(-(r/c(3)).^2)))/2;