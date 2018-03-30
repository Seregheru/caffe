clear all;
close all;
clc;


load('/home/jamblique/test/gsvdb/database/dmfilesu.mat','dmfilesu');

f = double(320);

for iddata=1:size(dmfilesu,1)

    disp(iddata);
    data = dmfilesu(iddata,:);
    
    try
  
    I = imread(strcat('/home/jamblique/test/gsvdb/panoimg/',data{3},'.jpg'));
    
    if size(I,1)==832 && size(I,2)==1664 && size(I,3)==3
    
        load(strcat('/home/jamblique/test/gsvdb/datageo/geo_',data{3},'.mat'),'im','normals');
        nb_planes = size(normals,2);
        
        for i=1:10

            phi0 = randn(1)*20*pi/180;
            lambda0 = rand(1)*360*pi/180;
            rotl = [cos(lambda0),-sin(lambda0),0;sin(lambda0),cos(lambda0),0;0,0,1];
            rotp = [cos(phi0),0,-sin(phi0);0,1,0;sin(phi0),0,cos(phi0)];
            rot = rotp*rotl;
            m_normals = rot*normals;
            mask = double(imresize(im,[size(I,1),size(I,2)],'nearest'));

            if nb_planes>1 && size(im,1)==256 && size(im,2)==512

                [res,resmask] = proj(double(rot),double(permute(I,[3,1,2])),int32(size(I,1)),int32(size(I,2)),f,mask);
                res = uint8(permute(res,[2,3,1]));
                %resmask = uint8(permute(resmask,[2,3,1]));

                test = false;
                m_z = rot*[0;0;1]; m_sum = 0; m_j = 0;
                for j=2:nb_planes
                    t = resmask==(j-1);
                    m_s = sum(t(:));
                    if m_z'*normals(:,j)<0.05 && m_s>25000
                        if m_s>m_sum
                           m_sum = m_s;
                           m_j = j;
                        end
                        test = true;
                    end
                end

                if test
                   
                    Igeo = zeros(480,640,3); labels = zeros(480,640);
                    for j=2:nb_planes
                        mask = resmask==(j-1);
                        n = m_normals(:,j);
                        Igeo(:,:,1) = Igeo(:,:,1) + n(1)*mask; %R = X
                        Igeo(:,:,2) = Igeo(:,:,2) + n(2)*mask; %G = Z
                        Igeo(:,:,3) = Igeo(:,:,3) + n(3)*mask; %B = Y
%                         if max(abs(normals(:,j)))==abs(normals(3,j))
%                            labels = labels + 1*mask;
%                         elseif abs(m_normals(2,j))>abs(m_normals(1,j))
%                            labels = labels + 2*mask;
%                         else
%                            labels = labels + 3*mask;
%                         end
                    end
                    
                    resgeo = Igeo./repmat(sqrt(Igeo(:,:,1).^2+Igeo(:,:,2).^2+Igeo(:,:,3).^2),1,1,3);
                    resgeo(isnan(resgeo)) = 0;
                    %Igeo = (Igeo*0.5+0.5).*double(repmat(resmask>0,1,1,3));
                    
%                     figure(1)
%                     imshow(res)
%                     figure(2)
%                     imshow(Igeo)
%                     figure(3)
%                     imagesc(uint8(labels))
%                     input('next');

                    save(strcat('/home/jamblique/test/gsvdb/datafinalter/normal/nm_',data{3},'_',int2str(i),'.mat'),'resgeo');
                    imwrite(res,strcat('/home/jamblique/test/gsvdb/datafinalter/img/im_',data{3},'_',int2str(i),'.jpg'));
                    %imwrite(Igeo,strcat('/home/jamblique/test/gsvdb/datafinalbis/normal/nm_',data{3},'_',int2str(i),'.png'));
                    %imwrite(uint8(labels),strcat('/home/jamblique/test/gsvdb/datafinalbis/label/lb_',data{3},'_',int2str(i),'.png'));
                    
                    n_x = -m_normals(:,m_j); n_z = m_z; n_y = cross(n_z,n_x);
                    rotfacade = [n_x,n_y,n_z];
                    
%                     P = [0,0,1;-1,0,0;0,-1,0];
%                     rotp= P'*rotfacade*P;
%                     K = [f,0,320;0,f,240;0,0,1];
%                     [ imT, H, RO, mask ] = img_rectification( rotp, res, inv(K) );
%                     figure(1);
%                     imshow(imT);
%                     figure(2);
%                     plot3([0,n_x(1)],[0,n_x(2)],[0,n_x(3)],'-r'); hold on;
%                     plot3([0,n_y(1)],[0,n_y(2)],[0,n_y(3)],'-g');
%                     plot3([0,n_z(1)],[0,n_z(2)],[0,n_z(3)],'-b');
%                     plot3([0,1],[0,0],[0,0],'--r');
%                     plot3([0,0],[0,1],[0,0],'--g');
%                     plot3([0,0],[0,0],[0,1],'--b');
%                     axis equal
%                     hold off;
%                     figure(2)
%                     imshow(res); hold on;
%                     nproj = K*rotfacade([2,3,1],:);
%                     nproj = nproj./repmat(nproj(3,:),3,1);
%                     nproj = nproj([3,1,2],:);
%                     plot([320,nproj(2,1)],[240,nproj(3,1)],'-r');
%                     plot([320,nproj(2,2)],[240,nproj(3,2)],'-g');
%                     plot([320,nproj(2,3)],[240,nproj(3,3)],'-b');
%                     hold off;
%                     input('next');

                    save(strcat('/home/jamblique/test/gsvdb/datafinalter/vp/vp_',data{3},'_',int2str(i),'.mat'),'rotfacade','phi0','lambda0');

                end

            end

        end
       
    
    end
    
    catch       
       disp('osef'); 
    end
    
 end