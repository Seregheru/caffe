function [ x,y ] = latlon2webmerc( lat, lon )

x = 128/pi*(lon*pi/180+pi);
y = 128./pi*(pi-log(tan(pi/4.+lat*pi/360.)));

end

