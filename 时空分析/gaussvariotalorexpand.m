%��˹�����variogram��r����̩��չ��
clear;clc;
syms c0 c1 alpha r
taylor(((c0+c1*(1-exp(-(r/alpha).^2)))/2),r,0,'order',10)