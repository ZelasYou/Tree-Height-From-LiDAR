clear
% n=8;%����CPU������������������
% parpool(n)%�������д˳���ǰ��CPU������nȫ����
tic %��ʱ��ʼ
%% ��ȡ�ļ�
cloud_xyz=importdata('E:\PointCloudSourceFile\txt\HP.txt');%��ȡ������txt
x0=cloud_xyz(:,1);
y0=cloud_xyz(:,2);
z0=cloud_xyz(:,3);%��ȡ�ռ�����
figure
P1=plot3(x0,y0,z0,'k.');% k�����ɫ��.�������ͷ���Ϊ��
xlabel('X(m)')
ylabel('Y(m)')
zlabel('�̣߳�m��')
title('ԭʼ��ά������ʾͼ')
%% ����DSM
pixel=0.24;%���÷ֱ��� 0.28
file='E:\MyCodeWorkPlace\matlab\tsy\tsy_dsm.tif';%�������DSM·��
[density,dis,DSM]=space2dsm(x0,y0,z0,pixel,file);
figure
imagesc(DSM)%չʾDSM
title('DSM��ʾͼ')
%% MORAVEC
img=double(imread(file));
img_old = img;
[h,w]=size(img);
% figure
% imshow(img,[])
imgn=zeros(h,w);
n=4;
yl=1+n;
yr=h-n;
xl=1+n;
xr=w-n;
parfor y=yl:yr
   for x=xl:xr
       sq=img(y-n:y+n,x-n:x+n);  %#ok<PFBNS>
       V=zeros(1,4);
       for i=2:2*n+1        %��ֱ��ˮƽ���Խǣ����Խ��ĸ���������ҶȲ��ƽ����
            V(1)=V(1)+(sq(i,n+1)-sq(i-1,n+1))^2;
            V(2)=V(2)+(sq(n+1,i)-sq(n+1,i-1))^2;
            V(3)=V(3)+(sq(i,i)-sq(i-1,i-1))^2;
            V(4)=V(4)+(sq(i,(2*n+1)-(i-1))-sq(i-1,(2*n+1)-(i-2)))^2;
       end
       pix=min(V);          %�ĸ�������ѡ��Сֵ
       imgn(y,x)=pix;      
   end
end

T=mean(imgn(:));        %����ֵ��С�ھ�ֵ����
ind=find(imgn<T);
imgn(ind)=0;

parfor y=yl:yr           %ѡ�ֲ�����ҷ���ֵ��Ϊ������
    for x=xl:xr
        sq=imgn(y-n:y+n,x-n:x+n); %#ok<PFBNS>
        if max(sq(:))==imgn(y,x) && imgn(y,x)~=0
            img(y,x)=255;
         % plot(y,x,'+','color','red');
         %  count=count+1;
        end
    end
end

%% ������
figure;
% imshow(img,[]);
imagesc(img)
title('MORAVEC������ʾͼ')
file1='E:\MyCodeWorkPlace\matlab\tsy\DSM_MORAVEC.tif';
imwrite(uint16(img),file1,'tif' )%���Ϊtif
%% �������Ŀ����Լ�����
% [L,W]=size(img);
tree_n=0;
tree_h=[];
k=1;
for i=1:h
    for j=1:w
        if img(i,j)==255
            tree_n=tree_n+1;
            if DSM(i,j)~= 0
            tree_h(k)=DSM(i,j);
            k = k+1;
            end
        end
    end
end
%% ��β
disp('����ƽ�����ܶ�')
disp(density)
disp('����ƽ������')
disp(dis)
disp('��ȡ������ľ����Ϊ')
disp(length(tree_h))
toc%��ʱ����
% delete(gcp('nocreate'))%�ر�CPU���м���