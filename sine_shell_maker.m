function res = sine_shell_maker(bottom_phase, top_phase, bottom_radius, top_radius, len, pitch, phistart)
% ; NAME:
% ;               sine_shell_maker
% ; PURPOSE:
% ;               Creates a helical path of variable radius and stepsize of
% :               uniform arclength.
% ;
% ; CATEGORY:
% ;               Additive Manufacturing, 3D Printing, Path Planning
% ; CALLING SEQUENCE:
% ;               res = sine_shell_maker(bottom_phase, top_phase, bottom_radius, top_radius, length, pitch, phistart)
% ; INPUTS:
% ;               bottom_phase:     where to start the sine shape (radians).
% ;
% ;               top_phase:        where to end the sine shape (radians).
% ;
% ;               bottom_radius:    radial offset at start of sine shape (mm).
% ;
% ;               top_radius:       radial offset at end of sine shape (mm).
% ;
% ;               len:              length of cylinder.
% ;
% ;               pitch:            center-to-center spacing of adjacent features.
% ;
% ;               phistart:         azimulthal location of first point.
% ;
% ; OUTPUTS:
% ;               res:          x,y,z coordinates of path
% ; PROCEDURE:
% ;               A cylindrical helix is created using cylinder_shell_maker.m.
% ;               A sinusoidal radial profile is then given to the base shape.
% ; NOTES:
% ; MODIFICATION HISTORY:
% ;               Written by Senthilkumar Duraivel and Thomas E. Angelini, 
% ;               The University of Florida, 2023.
% ;

% ;
% ;       This code 'sine_shell_maker.m' is copyright 2023, Senthilkumar 
% ;       Duraivel and Thomas E. Angelini.  It should be considered 
% ;       'freeware'- and may be distributed freely in its original form 
% ;       when properly attributed.

[coords] = cylinder_shell_maker(bottom_radius,len,pitch,0.1);

phi = atan2(coords(:,2),coords(:,1));
z = coords(:,3);

sine_angle = ((z-z(1))/z(end))*(top_phase-bottom_phase) + bottom_phase;

rad_list = min(bottom_radius, top_radius)+abs(bottom_radius-top_radius)*sin(sine_angle);

%start the cylinder at phistart; shape the cylinder with rad_list
phi = phi + phistart;
x = rad_list.*cos(phi);
y = rad_list.*sin(phi);

res = [x y z];

end

