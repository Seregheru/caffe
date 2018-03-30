clear all;
close all;
clc;

path = '/home/fond/normals/datafinalter/';

impath = strcat(path,'img/');
imrzpath = strcat(path,'imgrz/');
nmpath = strcat(path,'normal/');
smpath = strcat(path,'semrz/');
vppath = strcat(path,'contvp/');
plpath = strcat(path,'planes2/');

imfiles = dir(strcat(impath,'*.jpg'));
imfiles = imfiles(randperm(length(imfiles)));

p = 0;
k = 1; cf = 0;

image_mean = cat(3,  103.9390*ones(224,224),...
		     116.7700*ones(224,224),...
		     123.6800*ones(224,224));

rng('default');
rng(28);
rndid = rand(length(imfiles),1)<0.95;
ntrain = sum(rndid);
ntest = sum(rndid==0);

celltrain = cell(ntrain,2);
datatrain = zeros(ntrain,4);
celltest = cell(ntest,2);
datatest = zeros(ntest,4);

itrain = 1;
itest = 1;

focal = 320;
K = [focal,0,320;0,focal,240;0,0,1];

for i=1:length(imfiles)
    
    disp([int2str(i),'/',int2str(length(imfiles))]);
    
    f = imfiles(i).name;
    f = f(4:end-4);
    im_or = imread(strcat(impath,'im_',f,'.jpg'));
    im = imresize(im_or,[360,480],'cubic');
    imwrite(im,strcat(imrzpath,'im_',f,'.jpg'));
    load(strcat(nmpath,'nm_',f,'.mat'));
    nm = imresize(resgeo,[360,480],'nearest');
    n = sqrt(nm(:,:,1).^2+nm(:,:,2).^2+nm(:,:,3).^2);
    nm = nm./repmat(n,1,1,3);
    nm(isnan(nm)) = 0;
    nmn = nm(:,:,2); nmn = cat(3,nmn,nm(:,:,3)); nmn = cat(3,nmn,(-1)*nm(:,:,1));
    nm = nmn;
    sem = imread(strcat(smpath,'sem_',f,'.png'));
    sem = imresize(sem,[360,480],'nearest');
    mask = sem ~=0 & sem ~= 5;

    load(strcat(path,'vp/vp_',f,'.mat'),'rotfacade');

    if( (abs(rotfacade(1,1)) < abs(rotfacade(1,2))) && (abs(rotfacade(2,1)) > abs(rotfacade(2,2))) )
        if(rotfacade(1,1)>0)
            rotfacade = [-rotfacade(:,2),rotfacade(:,1),rotfacade(:,3)];
        else
            rotfacade = [rotfacade(:,2),-rotfacade(:,1),rotfacade(:,3)];
        end
    end
    if(rotfacade(1,1)>0)
        rotfacade = [rotfacade(:,1),rotfacade(:,2),rotfacade(:,3)];
    else
        rotfacade = [-rotfacade(:,1),-rotfacade(:,2),rotfacade(:,3)];
    end
    
    P = [0,0,1;-1,0,0;0,-1,0];
    rotref = P'*rotfacade*P;
    
    contin = true;
    try 
        [u,~,v] = svd(rotfacade);
        trplvp = u*v';
        [trplvp,err,outliers] = line_rot_refinement( im_or, trplvp, K, mask );
        quatvp = SpinCalc('DCMtoQ',trplvp,0.001,0);
    catch
       contin = false; 
    end
    
    if(contin)
        if((abs(sin(err))<0.05) && (outliers<0.6))
            if rndid(i)>0
                celltrain{itrain,1} = strcat(imrzpath,'im_',f,'.jpg');
                celltrain{itrain,2} = strcat(plpath,'pl_',f,'.png');
                datatrain(itrain,:) = quatvp;
                itrain = itrain + 1;
            else
                celltest{itest,1} = strcat(imrzpath,'im_',f,'.jpg');
                celltest{itest,2} = strcat(plpath,'pl_',f,'.png');
                datatest(itest,:) = quatvp;
                itest = itest + 1;
            end
            save(['/home/fond/normals/datafinalter/vps/',f,'.mat'],'trplvp');
        else
            try
                [u,~,v] = svd(rotfacade);
                trplvp = u*v';
                quatvp = SpinCalc('DCMtoQ',trplvp,0.001,0);
                if rndid(i)>0
                    celltrain{itrain,1} = strcat(imrzpath,'im_',f,'.jpg');
                    celltrain{itrain,2} = strcat(plpath,'pl_',f,'.png');
                    datatrain(itrain,:) = quatvp;
                    itrain = itrain + 1;
                else
                    celltest{itest,1} = strcat(imrzpath,'im_',f,'.jpg');
                    celltest{itest,2} = strcat(plpath,'pl_',f,'.png');
                    datatest(itest,:) = quatvp;
                    itest = itest + 1;
                end
                save(['/home/fond/normals/datafinalter/vps/',f,'.mat'],'trplvp');
            catch
               disp('osef'); 
            end
        end
    end
    
end

celltrain = celltrain(1:(itrain-1),:);
ntrain = size(celltrain,1);
celltest = celltest(1:(itest-1),:);
ntest = size(celltest,1);

datatrain = datatrain(1:ntrain,:);
datatest = datatest(1:ntest,:);

h5create(strcat('/home/fond/normals/datafinalter/trplvp4/trainr.h5'),'/data2',[4,ntrain],'Datatype','double');
h5create(strcat('/home/fond/normals/datafinalter/trplvp4/trainr.h5'),'/label2',[1,ntrain],'Datatype','double');
h5create(strcat('/home/fond/normals/datafinalter/trplvp4/testr.h5'),'/data2',[4,ntest],'Datatype','double');
h5create(strcat('/home/fond/normals/datafinalter/trplvp4/testr.h5'),'/label2',[1,ntest],'Datatype','double');

h5write(strcat('/home/fond/normals/datafinalter/trplvp4/trainr.h5'),'/data2',datatrain',[1,1],[4,ntrain]);
h5write(strcat('/home/fond/normals/datafinalter/trplvp4/trainr.h5'),'/label2',double(ones(1,ntrain)),[1,1],[1,ntrain]);
h5write(strcat('/home/fond/normals/datafinalter/trplvp4/testr.h5'),'/data2',datatest',[1,1],[4,ntest]);
h5write(strcat('/home/fond/normals/datafinalter/trplvp4/testr.h5'),'/label2',double(ones(1,ntest)),[1,1],[1,ntest]);

trainf = fopen('/home/fond/normals/datafinalter/trplvp4/trainr.txt','w');
testf = fopen('/home/fond/normals/datafinalter/trplvp4/testr.txt','w');

celltrain = celltrain';
celltest = celltest';
fprintf(trainf,'%s %s\n',celltrain{:});
fprintf(testf,'%s %s\n',celltest{:});

fclose(trainf);
fclose(testf);

celltrainim = cell(2,size(celltrain,2));
for i=1:size(celltrain,2)
   celltrainim{1,i} = celltrain{1,i};
   celltrainim{2,i} = '1';
end
trainimf = fopen('/home/fond/normals/datafinalter/trplvp4/trainimr.txt','w');
fprintf(trainimf,'%s %s\n',celltrainim{:});
fclose(trainimf);

celltestim = cell(2,size(celltest,2));
for i=1:size(celltest,2)
   celltestim{1,i} = celltest{1,i};
   celltestim{2,i} = '1';
end
testimf = fopen('/home/fond/normals/datafinalter/trplvp4/testimr.txt','w');
fprintf(testimf,'%s %s\n',celltestim{:});
fclose(testimf);
