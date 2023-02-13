function [res] = cylinder_shell_maker(radius,len,pitch,dS)

% ; NAME:
% ;               cylinder_shell_maker
% ; PURPOSE:
% ;               Creates a helical path of constant radius and stepsize of
% :               uniform arclength.
% ;
% ; CATEGORY:
% ;               Additive Manufacturing, 3D Printing, Path Planning
% ; CALLING SEQUENCE:
% ;               res = cylinder_shell_maker(radius,length,pitch,dS)
% ; INPUTS:
% ;               radius:       radius of cylinder.
% ;
% ;               len:          length of cylinder.
% ;
% ;               pitch:        center-to-center spacing of adjacent features.
% ;
% ;               dS:           arclength of each step (usually 0.1 mm).
% ;
% ; OUTPUTS:
% ;               res:          x,y,z coordinates of path
% ; PROCEDURE:
% ;               A helix is created using a 1 degree azimuthal step size.
% ;               The helix is then resampled to have an arc length of dS
% ;               between steps.
% ; NOTES:
% ; MODIFICATION HISTORY:
% ;               Written by Senthilkumar Duraivel and Thomas E. Angelini, 
% ;               The University of Florida, 2023.
% ;

% ;
% ;       This code 'cylindrical_shell_maker.m' is copyright 2023, Senthilkumar 
% ;       Duraivel and Thomas E. Angelini.  It should be considered 
% ;       'freeware'- and may be distributed freely in its original form 
% ;       when properly attributed.

%%
%First make cylinder with constant phi-stepsize
delt_deg = 1;
phi_end = 2*pi*len/pitch;
phi_1 = 0:(2*pi*delt_deg/360):phi_end;

z_1 = phi_1*pitch/(2*pi);
x_1 = radius*cos(phi_1);
y_1 = radius*sin(phi_1);

%Now re-sample to make constant arc-length steps

S_1 = cumsum(sqrt(diff(x_1).^2 + diff(y_1).^2 + + diff(z_1).^2));
S_1 = [0 S_1];

Slength = S_1(end);
S = 0:dS:Slength;
Phi = csaps(S_1,phi_1,1,S);

Z = Phi*pitch/(2*pi);
X = radius*cos(Phi);
Y = radius*sin(Phi);

res = [X' Y' Z'];

end
