
close all;
files = dir('/home/jamblique/test/gsvdb/datageo/*.mat');
i = 25;
f = files(i).name;
f = f(5:end-4);

load(['/home/jamblique/test/gsvdb/datageo/geo_',f,'.mat']);
resmask = im;
im = imread(['/home/jamblique/test/gsvdb/panoimg/',f,'.jpg']);
nb_planes = size(normals,2);

a = perms([1,2,3]);
% for t=1:6
% 
%     for k=0:7
%         
%     test = double((int32(sscanf(dec2bin(k,3),'%c'))-48)*2-1);
%     Igeo = zeros(size(resmask,1),size(resmask,2),3);
%     for j=2:nb_planes
%         mask = resmask==(j-1);
%         n = double(normals(a(t,:),j)).*double(test');
%         Igeo(:,:,1) = Igeo(:,:,1) + (128*n(1)+128)*mask; %R = X
%         Igeo(:,:,2) = Igeo(:,:,2) + (128*n(2)+128)*mask; %G = Z
%         Igeo(:,:,3) = Igeo(:,:,3) + (128*n(3)+128)*mask; %B = Y
%     end
%     
%     figure();
%     imwrite(uint8(Igeo),['/home/jamblique/test/equirec/',int2str(t),'_',int2str(k),'.jpg']);
%     
%     end
% end
%3_1

test = double((int32(sscanf(dec2bin(1,3),'%c'))-48)*2-1);
Igeo = zeros(size(resmask,1),size(resmask,2),3);
for j=2:nb_planes
    mask = resmask==(j-1);
    n = double(normals(a(3,:),j)).*double(test');
    Igeo(:,:,1) = Igeo(:,:,1) + (128*n(1)+128)*mask; %R = X
    Igeo(:,:,2) = Igeo(:,:,2) + (128*n(2)+128)*mask; %G = Z
    Igeo(:,:,3) = Igeo(:,:,3) + (128*n(3)+128)*mask; %B = Y
end

figure();
imwrite(uint8(Igeo),'/home/fond/equirec.png');

figure();
imwrite(imresize(im,[size(Igeo,1),size(Igeo,2)],'cubic'),'/home/fond/equirec.jpg');
