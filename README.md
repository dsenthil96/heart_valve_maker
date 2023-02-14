# heart_valve_maker

This code produces the x,y,z coordinates of a model heartvalve. The entire valve is constructed as a single path of helical construction. Run heart_valve_designer_App.mlapp or heart_valve_designer_AppScipt.m as a master script in MATLAB. This script calls three additional functions (valve_leaf_maker.m, cylinder_shell_maker.m, and sine_shell_maker.m).

Each part is drawn as a helical path of contstant arc-length between steps (either 0.1 or 0.05 mm). Different shapes are constructed separately and joined together by starting each successive part at the end point of the preceding part.

The base radius of the sinus, the total valve height, the leaflet height and the coupling radius can be tuned to produce the desired model geometery.

# heart valve parameters:
  Pitch - the layer height of the helical print path

  No. of leaves - choose from 2 to 7 for number of leaves to be designed in the valve

  Base radius - radius of the base of the valve where the leaflet begins
  
  Leaflet height - vertical height of the valve leaflets
  
  Valve height - vertical height of the valve sinus; total length of the valve (leaflets+sinus wall) not including the couplings
  
  Coupling radius - radius of the coupling added to the top and bottom of the valve for connections to external tubing



# to use the app:
1. Download all the files in the same directory.

2. Run heart_valve_designer_App.mlapp in MATLAB.

3. Change the different part dimensions

4. Click "export print trajectory" to download the csv file


The trajectory file contains the x,y,z coordinates of the model heartvalve with the selected dimensions.

To make a gcode file, convert the trajectory into a solid part using MeshLab and use a slicer software to export it as a gcode file.
