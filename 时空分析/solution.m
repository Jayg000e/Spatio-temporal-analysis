clear;clc;
cov=zeros(10000,10000);
%��ģ��ĸ�˹�������variogram����
c0=1;
c1=1;
alpha=4;
variogram=@(r) (c0+c1*(1-exp(-(r/alpha).^2)))/2;
c=@(r) exp(-(r/alpha).^2)/2;
var=(c0+c1)/2;
%����100*100��˹����10000*10000��Э�������
for i=1:10000
    for j=1:10000
        if i==j
        cov(i,j)=var;
        else
        cov(i,j)=c(dist(i,j));
        end
    end
end
%���ö�Ԫ��̬�ֲ��������������
mu=zeros(1,10000);
gauss=mvnrnd(mu,cov);
gaussfield=zeros(100,100);
for i=1:100
    for j=1:100
        gaussfield(i,j)=gauss((i-1)*100+j);
    end
end
%��ͬʸ�������variogram����ֵ
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
%��ͬʸ�������Ӧ�ľ���rֵ
for i=1:100
    for j=1:100
    dist(i,j)=sqrt((i-1)^2+(j-1)^2);
    end
end
%���ڸó�Ϊisotropic�ģ����в�ͬ��������Ӧͬ����variogram����Ҫ���������ͬ��rֵ
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
%�����ͬr��Ӧ��variogram����ֵ
estvariogram=uniquedistsum./uniquedistnum/2;
%��������variogram��r��ɢ���ϵͼ
scatter(uniquedist,estvariogram,2);
hold on;
%������ʵ�ֲ����Ա�
fplot(variogram,[0,99*sqrt(2)]);
xlabel('r');
ylabel('variogramhat(r)');
legend('ͳ�ƹ�����','��ʵֵ');
hold off;
%���õ�һ����Ϸ������
coeff1=lsqcurvefit(@variogramfit,[1 1 2],(uniquedist(1:100))',estvariogram(1:100))
%���õڶ�����Ϸ������г�����ϣ��ó�����������ֵ
coeff21=lsqcurvefit(@variogramfit2,[1 1 2],uniquedist(1:5)',estvariogram(1:5));
%Ϊ���ж�����ϣ�����̩������ϴ�ĵ�
for i=2:length(uniquedist)
    if abs((coeff21(2)*uniquedist(i)^6)/(12*coeff21(3)^6))>0.005
        samplesize=i-1;
        break;
    end
end
%���еڶ��ַ����Ķ������
coeff22=lsqcurvefit(@variogramfit2,[1 1 2],uniquedist(1:samplesize)',estvariogram(1:samplesize))
%���ݵ�һ����Ϸ����ó���Ӧ��sill��nugget effect��range
sill1=coeff1(1)+coeff1(2);
nugget1=coeff1(1);
range1=sqrt(3)*coeff1(3);
%���ݵڶ�����Ϸ����ó���Ӧ��sill��nugget effect��range
sill2=coeff22(1)+coeff22(2);
nugget2=coeff22(1);
range2=sqrt(3)*coeff22(3);
%��������Ϸ���������������
coeff3(1)=2*polyval(polyfit(uniquedist(1:2)',estvariogram(1:2),1),0);
coeff3(2)=mean(estvariogram(100:500))*2-coeff3(1);
surpassnum=0;
for i=1:3663
    if(estvariogram(i)>estvariogram(i+1))
        surpassnum=surpassnum+1;
    end
    %ֻҪrֵ��ĵ��rֵС�ĵ�variogramԤ��ֵС����������ĴΣ��Ͱ����Ӧ������Ϊ��range��
    if surpassnum==4
        coeff3(3)=uniquedist(i)/sqrt(3);
        break
    end
end
coeff3
%���ݵ�������Ϸ����ó���Ӧ��sill��nugget effect��range
sill3=coeff3(1)+coeff3(2);
nugget3=coeff3(1);
range3=sqrt(3)*coeff3(3);