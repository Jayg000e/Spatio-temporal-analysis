clear;clc;
cov=zeros(10000,10000);
%所模拟的高斯随机场的variogram函数
c0=1;
c1=1;
alpha=4;
variogram=@(r) (c0+c1*(1-exp(-(r/alpha).^2)))/2;
c=@(r) exp(-(r/alpha).^2)/2;
var=(c0+c1)/2;
%计算100*100高斯场的10000*10000的协方差矩阵
for i=1:10000
    for j=1:10000
        if i==j
        cov(i,j)=var;
        else
        cov(i,j)=c(dist(i,j));
        end
    end
end
%利用多元正态分布函数生成随机场
mu=zeros(1,10000);
gauss=mvnrnd(mu,cov);
gaussfield=zeros(100,100);
for i=1:100
    for j=1:100
        gaussfield(i,j)=gauss((i-1)*100+j);
    end
end
%求不同矢量方向的variogram估计值
sum=zeros(100,100);
num=zeros(100,100);
for i=1:100
    for j=1:100
        for k=i:100
            for l=j:100
                sum(i,j)=sum(i,j)+(gaussfield(k,l)-gaussfield(k-i+1,l-j+1))^2;
                num(i,j)=num(i,j)+1;
            end
        end
    end
end
%求不同矢量方向对应的距离r值
for i=1:100
    for j=1:100
    dist(i,j)=sqrt((i-1)^2+(j-1)^2);
    end
end
%由于该场为isotropic的，故有不同的向量对应同样的variogram，需要求出真正不同的r值
uniquedist=unique(dist);
uniquedist=uniquedist(2:length(uniquedist));
uniquedistsum=zeros(1,length(uniquedist));
uniquedistnum=zeros(1,length(uniquedist));
for i=1:100
    for j=1:100
        index=find(uniquedist==dist(i,j));
        uniquedistsum(index)=uniquedistsum(index)+sum(i,j);
        uniquedistnum(index)=uniquedistnum(index)+num(i,j); 
    end
end
%求出不同r对应的variogram估计值
estvariogram=uniquedistsum./uniquedistnum/2;
%画出估计variogram与r的散点关系图
scatter(uniquedist,estvariogram,2);
hold on;
%画出真实分布，对比
fplot(variogram,[0,99*sqrt(2)]);
xlabel('r');
ylabel('variogramhat(r)');
legend('统计估计量','真实值');
hold off;
%利用第一种拟合方法拟合
coeff1=lsqcurvefit(@variogramfit,[1 1 2],(uniquedist(1:100))',estvariogram(1:100))
%利用第二种拟合方法进行初次拟合，得出各参数大致值
coeff21=lsqcurvefit(@variogramfit2,[1 1 2],uniquedist(1:5)',estvariogram(1:5));
%为进行二次拟合，舍弃泰勒余项较大的点
for i=2:length(uniquedist)
    if abs((coeff21(2)*uniquedist(i)^6)/(12*coeff21(3)^6))>0.005
        samplesize=i-1;
        break;
    end
end
%进行第二种方法的二次拟合
coeff22=lsqcurvefit(@variogramfit2,[1 1 2],uniquedist(1:samplesize)',estvariogram(1:samplesize))
%根据第一种拟合方法得出相应的sill，nugget effect，range
sill1=coeff1(1)+coeff1(2);
nugget1=coeff1(1);
range1=sqrt(3)*coeff1(3);
%根据第二种拟合方法得出相应的sill，nugget effect，range
sill2=coeff22(1)+coeff22(2);
nugget2=coeff22(1);
range2=sqrt(3)*coeff22(3);
%第三种拟合方法根据特殊点拟合
coeff3(1)=2*polyval(polyfit(uniquedist(1:2)',estvariogram(1:2),1),0);
coeff3(2)=mean(estvariogram(100:500))*2-coeff3(1);
surpassnum=0;
for i=1:3663
    if(estvariogram(i)>estvariogram(i+1))
        surpassnum=surpassnum+1;
    end
    %只要r值大的点比r值小的点variogram预测值小的情况出现四次，就把其对应距离认为是range；
    if surpassnum==4
        coeff3(3)=uniquedist(i)/sqrt(3);
        break
    end
end
coeff3
%根据第三种拟合方法得出相应的sill，nugget effect，range
sill3=coeff3(1)+coeff3(2);
nugget3=coeff3(1);
range3=sqrt(3)*coeff3(3);