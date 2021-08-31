clear
% n=8;%设置CPU核心数！！！！！！
% parpool(n)%请在运行此程序前将CPU核心数n全部打开
tic %计时开始
%% 读取文件
cloud_xyz=importdata('E:\PointCloudSourceFile\txt\HP.txt');%读取纯数字txt
x0=cloud_xyz(:,1);
y0=cloud_xyz(:,2);
z0=cloud_xyz(:,3);%提取空间坐标
figure
P1=plot3(x0,y0,z0,'k.');% k代表黑色，.代表线型符号为点
xlabel('X(m)')
ylabel('Y(m)')
zlabel('高程（m）')
title('原始三维点云显示图')
%% 生成DSM
pixel=0.24;%设置分辨率 0.28
file='E:\MyCodeWorkPlace\matlab\tsy\tsy_dsm.tif';%设置输出DSM路径
[density,dis,DSM]=space2dsm(x0,y0,z0,pixel,file);
figure
imagesc(DSM)%展示DSM
title('DSM显示图')
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
       for i=2:2*n+1        %垂直，水平，对角，反对角四个方向领域灰度差的平方和
            V(1)=V(1)+(sq(i,n+1)-sq(i-1,n+1))^2;
            V(2)=V(2)+(sq(n+1,i)-sq(n+1,i-1))^2;
            V(3)=V(3)+(sq(i,i)-sq(i-1,i-1))^2;
            V(4)=V(4)+(sq(i,(2*n+1)-(i-1))-sq(i-1,(2*n+1)-(i-2)))^2;
       end
       pix=min(V);          %四个方向中选最小值
       imgn(y,x)=pix;      
   end
end

T=mean(imgn(:));        %设阈值，小于均值置零
ind=find(imgn<T);
imgn(ind)=0;

parfor y=yl:yr           %选局部最大且非零值作为特征点
    for x=xl:xr
        sq=imgn(y-n:y+n,x-n:x+n); %#ok<PFBNS>
        if max(sq(:))==imgn(y,x) && imgn(y,x)~=0
            img(y,x)=255;
         % plot(y,x,'+','color','red');
         %  count=count+1;
        end
    end
end

%% 输出结果
figure;
% imshow(img,[]);
imagesc(img)
title('MORAVEC特征显示图')
file1='E:\MyCodeWorkPlace\matlab\tsy\DSM_MORAVEC.tif';
imwrite(uint16(img),file1,'tif' )%输出为tif
%% 计算树的棵数以及树高
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
%% 收尾
disp('点云平均面密度')
disp(density)
disp('点云平均点间距')
disp(dis)
disp('提取到的树木棵数为')
disp(length(tree_h))
toc%计时结束
% delete(gcp('nocreate'))%关闭CPU并行计算