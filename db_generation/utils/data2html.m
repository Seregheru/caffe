function [ html ] = data2html( data, name )

    html = regexp(fileread('/home/fond/datagsvdb/gsvheadingtest.html'),'\n','split');
    
    s = 'var locations = {';
    for i=1:(size(data,1)-1)
        id = data{i};
        s = [s, int2str(i-1),': "',id,'",'];
    end
    id = data{end};
    s = [s, int2str(size(data,1)-1),': "',id,'"};'];
    html{17} = ['link.download = "',name,'.txt"'];
    html{33} = s;
    html{34} = ['for(var i=0;i<',int2str(size(data,1)),';i++){'];
    html{38} = ['setTimeout(savedata,',int2str(size(data,1)+1),'*50+1000)'];
    fid = fopen('/home/fond/datagsvdb/gsvheadingdata.html','w');
    fprintf(fid, '%s\n', html{:});
    fclose(fid);

    %dest = '/home/jamblique/test/gsvdb/javascript/panoid_paris/';
    %copyfile('/home/jamblique/test/gsvdb/javascript/gsvdataid.html',strcat(dest,name,'.html'));
    
    %unix('chromium-browser -url "file:///home/major/klc/3900_5819/javascript/gsvdataid.html"');
    %pause(size(data,1)*1000);
    %unix(['kill $(pidof ',chromium-browser,')']);

end

