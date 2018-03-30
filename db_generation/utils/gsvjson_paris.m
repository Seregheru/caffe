clear all;
close all;
clc;
htmld = regexp(fileread('/home/jamblique/test/gsvdb/panoid_paris.txt'),'\n','split');
out = '/home/jamblique/test/gsvdb/test.json';
dest = '/home/jamblique/test/gsvdb/database_paris/';

%load('/home/jamblique/test/gsvdb/database/dmfiles_la.mat','dmfiles');
dmfiles_paris = {};

for i=1:length(htmld)
    
disp(i);
s = strsplit(htmld{i},',');
if length(s)==3
    if ~isequal(exist(strcat(dest,'dm_',s{3},'.json'),'file'),2)
        url = ['http://maps.google.com/cbk?output=json&panoid=',s{3},'&dm=1&pm=1'];
        try
           unix(['wget -O ',out,' --timeout=100 --no-check-certificate "',url,'"']);
           pause(0.5);
           copyfile(out,strcat(dest,'dm_',s{3},'.json'));
           dmfiles_paris = vertcat(dmfiles_paris,s);
           pause(0.5);
        catch
           disp('osef'); 
        end
    end
end

end

save('/home/jamblique/test/gsvdb/database_paris/dmfiles_paris.mat','dmfiles_paris');