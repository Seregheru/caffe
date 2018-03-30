function [ html ] = data2browser( data, name )

    html = regexp(fileread('/home/fond/datagsvdb/javascript/getpano.html'),'\n','split');
    
    s = 'var ids = {';
    for i=1:(size(data,1)-1)
        s = [s, int2str(i-1),':"',data{i,3},'",'];
    end
    s = [s, int2str(size(data,1)-1),':"',data{size(data,1),3},'"};'];     
    html{33} = s;
    html{34} = ['for(var i=0;i<',int2str(size(data,1)),';i++){'];
    fid = fopen('/home/fond/datagsvdb/javascript/getpanom.html','w');
    fprintf(fid, '%s\n', html{:});
    fclose(fid);
    
    dest = '/home/fond/datagsvdb/javascript/panoimg_paris/';
    copyfile('/home/fond/datagsvdb/javascript/getpanom.html',strcat(dest,name,'.html'));
    
%     unix('chromium-browser -url "file:///home/major/klc/3900_5819/javascript/getpanom.html"');
%     pause(4*size(data,1)*1000);
%     unix('kill $(pidof chromium-browser)');

end

