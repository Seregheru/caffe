function [ lat,lon ] = webmerc2latlon( x, y )

lon = (pi*x/128-pi)*180/pi;
lat = (2*atan(exp(pi-pi*y/128))-pi/2)*180/pi;

end

