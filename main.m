%�о���ͬ��λ�㷨�Ķ�λ���ܲ���
%200*10m�ĵ�·�����տ�����
%�ƶ����������ڵ�·�м���ʻ(1m/s)

%%
%1m/s�ٶ���ʻ�����10m������
lengh=length(1:1:200)
trace_1=[1:1:200;repmat(5,lengh,1)']'    %��ʵ�켣,2.5m�м�
leng=length(0:15:200)
AP_1=[0:15:200;repmat(0.5,leng,1)']'                                    %APλ��(��������)
AP_2=[0:15:200;repmat(9.5,leng,1)']'                                   %APλ��(��������)
AP=[AP_1;AP_2]                                                      %ȫ����APλ�ã�AP���10m����

%%
%����켣�㵽AP�ľ���
for j=1:size(AP(:,1))
    for i=1:size(trace_1(:,1))
        d(i,j)=sqrt((trace_1(i,1)-AP(j,1)).^2+(trace_1(i,2)-AP(j,2)).^2)   %���й켣�㵽��j��AP����ʵ����
    end
end    %�õ�200*42�Ľṹ�壬ÿһ�д����i���켣�㵽����AP����ʵ����

%%
%����������������RSSIֵ
A=2  %˥������
rssi=-37.5721-10*1.2*log10(d)    %1m��RSSIΪ-.37.5721��˥������Ϊ1.26
rssi_noise=rssi+normrnd(0,2,lengh,leng*2)      %���ɷ���Ϊ2dBm�ľ���,�������������

%%
%������Ӱ˥��ģ�ͣ����ƾ���
intial_test=abs(-37.5721)
distance= 10.^((abs(rssi_noise)-intial_test)/(10 * A))  %���й켣�㵽��j��AP�Ĺ��ƾ���

save('AP','AP')
save('onlinedata','rssi','distance')
save('trace_1','trace_1')

%%
clc;
clear;
load('AP.mat')
load('onlinedata.mat')
%��С���˷�Ӧ��ǰ��ѡȡ4������ĵ�
distance_sort=sort(distance,2)  %��������
for k=1:length(distance(:,1))
    index(k,:)=find(distance(k,:)<=distance_sort(k,5)) %�������С�������ĸ��������������4
end
distance_dim=distance_sort(:,1:5)    %4������ĵ�Ĺ��ƾ��룬���������4

%4������ĵ��AP����λ��
AP_X=AP(:,1)  %AP��x��
AP_Y=AP(:,2)  %AP��y��
for n=1:length(distance(:,1))    %nΪ200,nΪ��n����λ��
    for m=1:length(index(1,:))    %mΪ4���ܹ���4��
       mm=index(n,m)   %ȡ����n�е�m�е�����
       AP_X_dim(n,m)=AP_X(mm)   %���ڵ�n����λ�㣬ȡ��AP��x��
       AP_Y_dim(n,m)=AP_Y(mm)   %���ڵ�n����λ�㣬ȡ��AP��y��
    end
end
AP_Z_dim=zeros(length(AP_Y_dim),size(AP_X_dim,2))  %AP��z��

%��С���˷�
for p=1:length(distance_dim(:,1))  %d�����d���켣��
    X=AP_X_dim(p,:)
    Y=AP_Y_dim(p,:)
    Z=AP_Z_dim(p,:)
    d_LSE=distance_dim(p,:)'  %����������������������
    distance_LSE(:,p)=Algo_LSE(X,Y,Z,d_LSE)
end

%��С����+��ͳ̩��չ��
len=size(AP_X_dim,2)    
for i=1:length(distance_dim(:,1)) 
     xtyt_LSE(:,i)=distance_LSE(1:2,i)   %����̩�ռ���չ���ĳ�ʼ�㣬��������С���˷�
    
     delta=[0.001;0.001];%��ʼ����
%      while (abs(delta(1,1))+abs(delta(2,1)))>=0.001%��λ�����ֵ
k=0
     while k<50 
        for j=1:len
         AP_dim(:,j)=[AP_X_dim(i,j);AP_Y_dim(i,j)]
         d(j)=sqrt(sum((xtyt_LSE(:,i)- AP_dim(:,j)).^2))
         A1(j,:)=[(xtyt_LSE(1,i)-AP_X_dim(i,j))/d(j),(xtyt_LSE(2,i)-AP_Y_dim(i,j))/d(j)];
         B1(j,1)=distance_dim(i,j)-d(j);
        end
        delta=(A1'*A1)\A1'*B1;
        xtyt_LSE(:,i)=xtyt_LSE(:,i)+delta;
        
        k=k+1
     end
end
%save('distance_MLE','distance_MLE')

%%
% clc;
% clear;
% load('AP.mat')
% load('onlinedata.mat')
% %��Ȩ��С���˷�Ӧ��ǰ��ѡȡ4������ĵ�
% distance_sort=sort(distance,2)  %��������
% for k=1:length(distance(:,1))
%     index(k,:)=find(distance(k,:)<=distance_sort(k,4)) %�������С�������ĸ��������������4
% end
% distance_dim=distance_sort(:,1:4)    %4������ĵ�Ĺ��ƾ��룬���������4
% 
% %4������ĵ��AP����λ��
% AP_X=AP(:,1)  %AP��x��
% AP_Y=AP(:,2)  %AP��y��
% for n=1:length(distance(:,1))    %nΪ200,nΪ��n����λ��
%     for m=1:length(index(1,:))    %mΪ4���ܹ���4��
%        mm=index(n,m)   %ȡ����n�е�m�е�����
%        AP_X_dim(n,m)=AP_X(mm)   %���ڵ�n����λ�㣬ȡ��AP��x��
%        AP_Y_dim(n,m)=AP_Y(mm)   %���ڵ�n����λ�㣬ȡ��AP��y��
%     end
% end
% AP_Z_dim=zeros(length(AP_Y_dim),size(AP_X_dim,2))  %AP��z��

%��Ȩ��С���˷�
for p=1:length(distance_dim(:,1))  %d�����d���켣��
    X=AP_X_dim(p,:)
    Y=AP_Y_dim(p,:)
    Z=AP_Z_dim(p,:)
    d_LSE=distance_dim(p,:)'  %����������������������
    distance_WLSE(:,p)=Algo_WLSE(X,Y,Z,d_LSE)
end
%save('distance_WLSE','distance_WLSE')

%%
% clc;
% clear;
% load('AP.mat')
% load('onlinedata.mat')
% 
% %������Ȼ��λ�㷨Ӧ��֮ǰ��ѡȡ5������ĵ�
% distance_sort=sort(distance,2)  %��������
% for k=1:length(distance(:,1))
%     index(k,:)=find(distance(k,:)<=distance_sort(k,4)) %�������С�������ĸ��������������5
% end
% distance_dim=distance_sort(:,1:4)    %5������ĵ�Ĺ��ƾ��룬���������5

%3������ĵ��AP����λ��
% AP_X=AP(:,1)  %AP��x��
% AP_Y=AP(:,2)  %AP��y��
% for n=1:length(distance(:,1))    %nΪ200,nΪ��n����λ��
%     for m=1:length(index(1,:))    %mΪ3���ܹ���4��
%        mm=index(n,m)   %ȡ����n�е�m�е�����
%        AP_X_dim(n,m)=AP_X(mm)   %���ڵ�n����λ�㣬ȡ��AP��x��
%        AP_Y_dim(n,m)=AP_Y(mm)   %���ڵ�n����λ�㣬ȡ��AP��y��
%     end
% end


%������Ȼ��
% len=size(AP_X_dim,2)    
% for i=1:length(distance_dim(:,1))   
%     for j=1:len-1
%         A(j,:)=[2*(AP_X_dim(i,j)-AP_X_dim(i,len)),2*(AP_Y_dim(i,j)-AP_Y_dim(i,len))]
%         B(j,1)=[distance_dim(i,len)^2-distance_dim(i,j)^2+AP_X_dim(i,j)^2-AP_X_dim(i,len)^2+AP_Y_dim(i,j)^2-AP_Y_dim(i,len)^2]  
%     end
%     distance_MLE(:,i)=(A'*A)\A'*B    
% end     
%  

%�Ľ�������Ȼ��
len=size(AP_X_dim,2)    
for i=1:length(distance_dim(:,1)) 
     xtyt_WMLE(:,i)=distance_MLE(1:2,i)   %����̩�ռ���չ���ĳ�ʼ�㣬��������С���˷�
    
     delta=[0.001;0.001];%��ʼ����
%      while (abs(delta(1,1))+abs(delta(2,1)))>=0.001%��λ�����ֵ
     k=0
     T=sum(distance_dim(i,:))
     Q=(1/16)*diag(T-distance_dim(i,:))
     while k<100 
        for j=1:len
         AP_dim(:,j)=[AP_X_dim(i,j);AP_Y_dim(i,j)]
         d(j)=sqrt(sum((xtyt_WMLE(:,i)- AP_dim(:,j)).^2))
         A1(j,:)=[(xtyt_WMLE(1,i)-AP_X_dim(i,j))/d(j),(xtyt_WMLE(2,i)-AP_Y_dim(i,j))/d(j)];
         B1(j,1)=distance_dim(i,j)-d(j);
        end
        delta=(A1'*A1)\A1'*Q*B1;
        xtyt_WMLE(:,i)=xtyt_WMLE(:,i)+delta;
        
        k=k+1
     end
end
%%
% clc;
% clear;
% load('AP.mat')
% load('onlinedata.mat')
% 
% %��Ȩ�����㷨Ӧ��֮ǰ��ѡȡ3������ĵ�
% distance_sort=sort(distance,2)  %��������
% for k=1:length(distance(:,1))
%     index(k,:)=find(distance(k,:)<=distance_sort(k,4)) %�������С�������ĸ��������������3
% end
% distance_dim=distance_sort(:,1:4)    %4������ĵ�Ĺ��ƾ��룬���������3

%3������ĵ��AP����λ��
% AP_X=AP(:,1)  %AP��x��
% AP_Y=AP(:,2)  %AP��y��
% for n=1:length(distance(:,1))    %nΪ200,nΪ��n����λ��
%     for m=1:length(index(1,:))    %mΪ3���ܹ���4��
%        mm=index(n,m)   %ȡ����n�е�m�е�����
%        AP_X_dim(n,m)=AP_X(mm)   %���ڵ�n����λ�㣬ȡ��AP��x��
%        AP_Y_dim(n,m)=AP_Y(mm)   %���ڵ�n����λ�㣬ȡ��AP��y��
%     end
% end

%��Ȩ�����㷨
len=size(AP_X_dim,2)    
for i=1:length(distance_dim(:,1))  
    x1=0.1;
    y1=0.1;
    dq=0.1;
    for j=1:len
        x1=x1+AP_X_dim(i,j)/distance_dim(i,j);
        y1=y1+AP_Y_dim(i,j)/distance_dim(i,j);
        dq=dq+1/distance_dim(i,j);
    end
    distance_WZX(:,i)= [x1/dq;y1/dq];
end

%��Ȩ�����㷨+�Ľ�̩��
len=size(AP_X_dim,2)    
for i=1:length(distance_dim(:,1)) 
     xtyt_WWZX(:,i)=distance_WZX(1:2,i)   %����̩�ռ���չ���ĳ�ʼ�㣬��������С���˷�
    
     delta=[0.001;0.001];%��ʼ����
%      while (abs(delta(1,1))+abs(delta(2,1)))>=0.001%��λ�����ֵ
     k=0
     T=sum(distance_dim(i,:))
     Q=(1/16)*diag(T-distance_dim(i,:))
     while k<100 
        for j=1:len
         AP_dim(:,j)=[AP_X_dim(i,j);AP_Y_dim(i,j)]
         d(j)=sqrt(sum((xtyt_WWZX(:,i)- AP_dim(:,j)).^2))
         A1(j,:)=[(xtyt_WWZX(1,i)-AP_X_dim(i,j))/d(j),(xtyt_WWZX(2,i)-AP_Y_dim(i,j))/d(j)];
         B1(j,1)=distance_dim(i,j)-d(j);
        end
        delta=(A1'*A1)\A1'*Q*B1;
        xtyt_WWZX(:,i)=xtyt_WWZX(:,i)+delta;
        
        k=k+1
     end
end

%%
%��ͼ
load('trace_1.mat')
error_WLSE=sqrt(sum((distance_WLSE(1:2,:)-trace_1').^2))./2   %���
mean_error_WLSE=mean(error_WLSE)           %ƽ����λ���
rmse_error_WLSE=(sqrt(mean((distance_WLSE(1,:)-trace_1(:,1)').^2))+sqrt(mean((distance_WLSE(2,:)-trace_1(:,2)').^2)))/2

error_WZX=sqrt(sum((distance_WZX-trace_1').^2))./2   %���
mean_error_WZX=mean(error_WZX)           %ƽ����λ���
rmse_error_WZX=(sqrt(mean((distance_WZX(1,:)-trace_1(:,1)').^2))+sqrt(mean((distance_WZX(2,:)-trace_1(:,2)').^2)))/2

error_MLE=sqrt(sum((distance_MLE-trace_1').^2))./2   %���
mean_error_MLE=mean(error_MLE)           %ƽ����λ���
rmse_error_MLE=(sqrt(mean((distance_MLE(1,:)-trace_1(:,1)').^2))+sqrt(mean((distance_MLE(2,:)-trace_1(:,2)').^2)))/2

error_xtyt_LSE=sqrt(sum((xtyt_LSE-trace_1').^2))./2   %���
mean_error_xtyt_LSE=mean(error_xtyt_LSE)           %ƽ����λ���
rmse_error_xtyt_LSE=(sqrt(mean((xtyt_LSE(1,:)-trace_1(:,1)').^2))+sqrt(mean((xtyt_LSE(2,:)-trace_1(:,2)').^2)))/2

error_xtyt_WWZX=sqrt(sum((xtyt_WWZX-trace_1').^2))./2   %���
mean_error_xtyt_WWZX=mean(error_xtyt_WWZX)           %ƽ����λ���
rmse_error_xtyt_WWZX=(sqrt(mean((xtyt_WWZX(1,:)-trace_1(:,1)').^2))+sqrt(mean((xtyt_WWZX(2,:)-trace_1(:,2)').^2)))/2


% figure(1)
% h1=cdfplot(error_MLE)
% hold on
% h2=cdfplot(error_WZX)
% hold on
% h3=cdfplot(error_WLSE)
% hold on
% h4=cdfplot(error_xtyt_LSE)
% hold on
% h5=cdfplot(error_xtyt_WWZX)
% legend('MLE','WCL','WLS','TSLS','WTS-WCL')
% set(gca,'ytick',0:0.1:1)
% set(gca, 'linewidth', 1.0, 'fontsize', 12, 'fontname', 'Times New Roman')
% xlabel('Error (m)')
% ylabel('CDF')
% set(gca,'XLim',[0 10]);%X���������ʾ��Χ
% 
% 
% 
