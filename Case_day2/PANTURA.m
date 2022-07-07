%% XBeach DSS-PANTURA
% v0.1 Jul 22
% Gugum Gumbira
% University of Liverpool/ Lab Pantai Yogya BRIN
clear all, close all, clc;
destin = 'C:\Users\gugum\Documents\DSS_Pantura\xbeach-docs-master\docs\tutorials\sandy\files\Data\Step1_makebathy';
destout         = 'C:\Users\gugum\Documents\DSS_Pantura\xbeach-docs-master\docs\tutorials\sandy\tes_gum'; 

%% specify area
output_lon_w        = 417497.114; 
output_lon_e        = 446081.217;  
output_lat_n        = 9268380.080;  
output_lat_s        = 9226333.787;

% Determine size of grid cells
output_delta_x      = 50;
output_delta_y      = 50;
[output_X,output_Y] = meshgrid(output_lon_w:output_delta_x:output_lon_e, output_lat_n:-output_delta_y:output_lat_s);

cd(destin);
[input_Z_CRM R_CRM]            = arcgridread_v2('Sema1_UTM.asc'); % 

% Get grid information from input dataset     
[input_n_y input_n_x]           = size(input_Z_CRM);
input_delta_x                   = R_CRM(2,1);
input_delta_y                   = R_CRM(1,2);
input_lon_w                     = R_CRM(3,1);
input_lon_e                     = R_CRM(3,1)+input_delta_x*(input_n_x-1);
input_lat_n                     = R_CRM(3,2);
input_lat_s                     = R_CRM(3,2)+input_delta_y*(input_n_y-1);

%[input_X_CRM, input_Y_CRM]          = meshgrid(input_lon_w:R_CRM(2,1):input_lon_e,input_lat_n:R_CRM(1,2):input_lat_s);
[input_X_CRM, input_Y_CRM]          = meshgrid(input_lon_w:R_CRM(2,1):input_lon_e,input_lat_n:R_CRM(1,2):input_lat_s);
% Griddata to output grid
output_Z_CRM                     = griddata(input_X_CRM,input_Y_CRM,input_Z_CRM, output_X, output_Y);

%% create model domain
dxmin               = 30;
dymin               = 30;
outputformat        = 'fortran';
rotation_xb         = 4.7124/pi*180;

T                       = 3 * 24 * 3600 % 3 days in seconds

xbm = xb_generate_model(...
    'bathy',...
        {'x', output_X, 'y', output_Y, 'z', output_Z_CRM,... 
        'xgrid', {'dxmin',dxmin},... 
        'ygrid', {'dymin',dymin},...
        'ygrid', {'area_size',1000},...
        'rotate', rotation_xb, ...
        'crop', false,...
        'world_coordinates',true,...
        'finalise', {'actions', {'seaward_flatten', 'seaward_extend'},'zmin',-100}},...
        'waves', {'Hm0', 2,'Tp', 6.5},...
        'tide', {'time', [0 18600 36600 46200 63000 74400 81600,],...
        'front', [0.665 1.665 2.185 2.185 1.515 1.515 1.371],...
        'back', [0 0 0 0 0 0 0]},...
        'settings', ...
        {'outputformat',outputformat,... 
        'instat',5,...
        'morfac', 10,...
        'morstart', 0, ...
        'CFL', 0.7,...
        'thetamin', 0, ...
        'thetamax', 180, ...
        'dtheta',10,...
        'thetanaut', 1, ...
        'tstop', T, ...
        'tstart', 0,...
        'tintg', T/72,...
        'tintm', T/6,...
        'D50', .0003,...
        'D90', .0004,...
        'epsi',-1,...              
        'facua',0.10,...
        'write', false,...
        'createwavegrid',false});
    
% A. Get grid
xgrid                   = xs_get(xbm,'xfile.xfile');
ygrid                   = xs_get(xbm,'yfile.yfile');
zgrid                   = xs_get(xbm,'depfile.depfile');

id1 = find(zgrid > 10);
for i = 1:length(id1)
    zgrid(id1(i)) = 10;
end

id2 = find(zgrid < -30);
for i = 1:length(id2)
    zgrid(id2(i)) = -30;
end

% C. Straight boundaries
[nx ny]                             = size(zgrid);
roundnumber                         = 5;
first                               = 1;
second                              = roundnumber;
third                               = nx-(roundnumber-1);
four                             	= nx;
five                                = ny - (roundnumber-1);
six                                 = ny;
zgrid([first:second],:)             = repmat(zgrid(second,:),[roundnumber,1]); 
zgrid([(third:four)],:)             = repmat(zgrid((third),:),[roundnumber,1]);
zgrid(:,[five:six])                 = repmat(zgrid(:,six),[1,roundnumber]);
xbm                                 = xs_set(xbm, 'depfile.depfile', zgrid);

cd(destout);
data = [destout, '\xbm', '.mat']
save(data,'xbm')  
%copyfile(destwaves,destout,'f')        
xb_write_input([destout '\params.txt'], xbm)
