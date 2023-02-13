function res = valve_leaf_maker(nleaf, pitch, len, clearence, top_radius, bottom_radius, zstart, phistart)
%
% ; NAME:
% ;               valve_leaf_maker
% ; PURPOSE:
% ;               Creates a 3D trajectory for 3D printing the leaflets and
% ;               surrounding hull of a heart-valve model.
% ;
% ; CATEGORY:
% ;               Additive Manufacturing, 3D Printing, Path Planning
% ; CALLING SEQUENCE:
% ;               res = valve_leaf_maker(nleaf, lfpitch, lf_len, clearence,top_radius, lastr, zstart, phistart)
% ; INPUTS:
% ;               nleaf:        number of leaves (typically 3).
% ;
% ;               pitch:        vertical spacing between neighboring features.
% ;
% ;               len:          total length of the object.
% ;
% ;               clearance:    half the distance between edges of neighboring leaves.
% ;
% ;               top_radius:   radius of hull at the top of the leaves
% ;
% ;               bottom_radius:    radius of hull at the bottom of leaves
% ; 
% ;               zstart:       starting z coordinate at
% ;
% ;               phistart:     starting azimuthal coordinate.
% ; OUTPUTS:
% ;               res:          x,y,z coordinates of path
% ; PROCEDURE:
% ;               This section of the heart valve model part is drawn as a 
% ;               single path of contstant arc-length between steps
% ;               (0.05 mm).
% ; NOTES:
% ; MODIFICATION HISTORY:
% ;               Written by Senthilkumar Duraivel and Thomas E. Angelini, 
% ;               The University of Florida, 2023.
% ;

% ;
% ;       This code 'valve_leaf_maker.m' is copyright 2023, Senthilkumar 
% ;       Duraivel and Thomas E. Angelini.  It should be considered 
% ;       'freeware'- and may be distributed freely in its original form 
% ;       when properly attributed.


avg_radius = mean([bottom_radius top_radius]);

n_layers = len/pitch; % number of layers needed
delt_phi = 2*pi/360;
leaf_theta_list =  linspace(0, 2*pi, nleaf+1);
thetalength = leaf_theta_list(2)/2; % half of each leaf angle
leaf_theta_list = phistart+leaf_theta_list(1:end-1); % theta center position for each leaf (0, 120, 240)

% delta theta on each side for a leaf at a given layer (linearly spaced)
dtphi = linspace(0,thetalength-(clearence/top_radius), n_layers); 

% fits the valve cylinder radius to a sin wave
valve_radius_list = avg_radius+(top_radius-avg_radius)*sin(linspace(3*pi/2, 5*pi/2, n_layers));

% fits the valve leaf radius to a sin wave
leaf_radius_list = (top_radius-clearence)*sin(linspace(0, pi/2, n_layers));

x_leaf = [];
y_leaf = [];
z_leaf = [];

for i = 2:n_layers
    phistep = dtphi(1:i); %theta step dist for one side of the leaf for the layer 'i'
    valve_r = valve_radius_list(i); % valve cylinder radius for the layer 'i'
    leaf_r = valve_r-leaf_radius_list(i); % valve cylinder radius for the layer 'i'
    z_bucket_list = [];
    for lfphi = leaf_theta_list       
        
        % trajectory from center of leaf to leaf edge
        x_0 = valve_r*cos(lfphi+phistep);
        y_0 = valve_r*sin(lfphi+phistep);
    
        %% trajectory to make a leaf
        % trajectory to make first half of the leaf
        x_1 = linspace(valve_r*cos(lfphi+phistep(end)),leaf_r*cos(lfphi), phistep(end)/delt_phi);
        y_1 = linspace(valve_r*sin(lfphi+phistep(end)),leaf_r*sin(lfphi), phistep(end)/delt_phi);
              
        % trajectory to make second half of the leaf
        x_2 = linspace(leaf_r*cos(lfphi),valve_r*cos(lfphi-phistep(end)), phistep(end)/delt_phi);
        y_2 = linspace(leaf_r*sin(lfphi),valve_r*sin(lfphi-phistep(end)), phistep(end)/delt_phi);
       
        %% trajectory to make the wall to the next leaf
  
         % x and y for the -ve leaf dist
        x_3 = fliplr(valve_r*cos(lfphi-phistep));
        y_3 = fliplr(valve_r*sin(lfphi-phistep));
       
        % x and y for the next leaf
        x_4 = valve_r*cos([lfphi:(delt_phi):lfphi+thetalength*2]); 
        y_4 = valve_r*sin([lfphi:(delt_phi):lfphi+thetalength*2]);
       
        x_leaf = [x_leaf x_0 x_1 x_2 x_3 x_4];
        y_leaf = [y_leaf y_0 y_1 y_2 y_3 y_4];
        z_bucket_list = [z_bucket_list x_0 x_1 x_2 x_3 x_4];
    end
    z_leaf = [z_leaf zstart+linspace(0,pitch,length(z_bucket_list))];
    zstart = z_leaf(end);
end

%%
% resample path in constant arc-length steps
%
S0 = cumsum([0 sqrt(diff(x_leaf).^2+diff(y_leaf).^2+diff(z_leaf).^2)]);

[a b] = max(S0);
L = S0(b);
Sf = (0:0.05:L)';
xfine = csaps(double(S0(1:b)),double(x_leaf(1:b)),0.97,double(Sf));
yfine = csaps(double(S0(1:b)),double(y_leaf(1:b)),0.97,double(Sf));
zfine = csaps(double(S0(1:b)),double(z_leaf(1:b)),0.97,double(Sf));

res = [xfine yfine zfine];

end

