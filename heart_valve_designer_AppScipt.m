classdef heart_valve_designer_AppScipt < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        UIAxes                       matlab.ui.control.UIAxes
        leafletheightmmLabel         matlab.ui.control.Label
        leafheight                   matlab.ui.control.Slider
        baseradiusmmLabel            matlab.ui.control.Label
        baseradius                   matlab.ui.control.Slider
        pitchmmLabel                 matlab.ui.control.Label
        pitch                        matlab.ui.control.Spinner
        exportprinttrajectoryButton  matlab.ui.control.Button
        noofleavesSpinnerLabel       matlab.ui.control.Label
        leafnumber                   matlab.ui.control.Spinner
        couplingradiusmmLabel        matlab.ui.control.Label
        cpradius                     matlab.ui.control.Slider
        valveheightmmLabel           matlab.ui.control.Label
        sinusheight                  matlab.ui.control.Slider
    end

    methods (Access = private)
               
        function results = heart_valve_maker(app)
            pitch = app.pitch.Value; %mm (helical pitch of path)
            dS = 0.1; %mm (typical arclength between points along smooth traces)
               
            
            %%%%%%%%%%%%%%%%%% bottom coupling START %%%%%%%%%%%%%%%%%%
            len = 3; %mm (length of bottom tube)
            radius = app.cpradius.Value; %mm (radius of bottom tube)
            
            [coords] = cylinder_shell_maker(radius,len,pitch,dS);
            
            X = coords(:,1);
            Y = coords(:,2);
            Z = coords(:,3);
            %%%%%%%%%%%%%%%%%% bottom coupling END %%%%%%%%%%%%%%%%%%
            
            %%
            %%%%%%%%%%%%%%%%%% bottom cover START %%%%%%%%%%%%%%%%%%

            len = 0.5*(app.sinusheight.Value-app.leafheight.Value); %mm (length of curved cap)
            bottom_radius = sqrt(X(end)^2 + Y(end)^2); %mm (radius of the bottom end)
            top_radius = app.baseradius.Value; %mm (radius of the top end)
            
            bottom_phase = 0; %radians (determines shape of cap)
            top_phase = pi/2; %radians (determines shape of cap)
            
            phistart = atan2(Y(end),X(end));
            
            [coords] = sine_shell_maker(bottom_phase, top_phase, bottom_radius, top_radius, len, pitch, phistart);
            
            zstart = Z(end);
            
            X = [X; coords(:,1)]; 
            Y = [Y; coords(:,2)]; 
            Z = [Z; coords(:,3)+zstart];
            %%%%%%%%%%%%%%%%%% bottom cover END %%%%%%%%%%%%%%%%%%

            
            %%
            
            %%%%%%%%%%%%%%%%%% valve leaf START %%%%%%%%%%%%%%%%%%
            nleaf = app.leafnumber.Value;
            len = app.leafheight.Value; %mm (length of the leaf)
            clearance = 0.5; %mm (half the distance between adjacent leaves)
            bottom_radius = sqrt(X(end)^2 + Y(end)^2); %mm (radius of the bottom end)
            top_radius = 1.46*app.baseradius.Value; 

            phistart = atan2(Y(end),X(end));
            zstart = Z(end);
            
            [coords] = valve_leaf_maker(nleaf, pitch, len, clearance,top_radius, bottom_radius, zstart, phistart);
            
            X = [X; coords(:,1)]; 
            Y = [Y; coords(:,2)]; 
            Z = [Z; coords(:,3)];
            %%%%%%%%%%%%%%%%%% valve leaf END %%%%%%%%%%%%%%%%%%
            
            %%
            %%%%%%%%%%%%%%%%%% top valve cover START %%%%%%%%%%%%%%%%%%
            len = 0.5*(app.sinusheight.Value-app.leafheight.Value); %mm (length of curved cap)
            bottom_radius = sqrt(X(end)^2 + Y(end)^2); %mm (radius of the bottom end)
            top_radius = app.cpradius.Value; %mm (radius of the top end)
            
            bottom_phase = pi/2; %radians (determines shape of cap)
            top_phase = pi; %radians (determines shape of cap)
            
            phistart = atan2(Y(end),X(end));
            
            [coords] = sine_shell_maker(bottom_phase, top_phase, bottom_radius, top_radius, len, pitch, phistart);
            
            zstart = Z(end);
            
            X = [X; coords(:,1)]; 
            Y = [Y; coords(:,2)]; 
            Z = [Z; coords(:,3)+zstart];
            %%%%%%%%%%%%%%%%%% top valve cover END %%%%%%%%%%%%%%%%%%
            
            %%
            %%%%%%%%%%%%%%%%%%  top coupling START %%%%%%%%%%%%%%%%%%
            len = 3; %mm (length of top tube)
            phistart = atan2(Y(end),X(end));
            zstart = Z(end);
            
            [coords] = cylinder_shell_maker(top_radius,len,pitch,dS);
            
            phitemp = atan2(coords(:,2),coords(:,1))+phistart;
            rtemp = sqrt(coords(:,1).^2 + coords(:,2).^2);
            
            xtemp = rtemp.*cos(phitemp);
            ytemp = rtemp.*sin(phitemp);
            
            X = [X; xtemp]; 
            Y = [Y; ytemp]; 
            Z = [Z; coords(:,3)+zstart];
            
            
            results = [X, Y, Z];
            plot3(app.UIAxes, X, Y, Z);
            axis(app.UIAxes, 'equal');

        end       
    end
    
    methods (Access = public)
          
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: exportprinttrajectoryButton
        function exportprinttrajectoryButtonPushed(app, event)
           results = heart_valve_maker(app);
           writematrix(results,'heart_valve_xyz.csv')
        end

        % Value changed function: baseradius
        function baseradiusValueChanged(app, event)
            heart_valve_maker(app);
        end

        % Value changed function: leafheight
        function leafheightValueChanged(app, event)
            heart_valve_maker(app);
        end

        % Value changed function: pitch
        function pitchValueChanged(app, event)
            heart_valve_maker(app);
        end

        % Value changed function: leafnumber
        function leafnumberValueChanged(app, event)
            heart_valve_maker(app);
        end

        % Value changed function: cpradius
        function cpradiusValueChanged(app, event)
            heart_valve_maker(app);            
        end

        % Value changed function: sinusheight
        function sinusheightValueChanged(app, event)
            heart_valve_maker(app);            
        end

        % Button down function: UIFigure
        function UIFigureButtonDown(app, event)
            heart_valve_maker(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 827 575];
            app.UIFigure.Name = 'UI Figure';
            app.UIFigure.ButtonDownFcn = createCallbackFcn(app, @UIFigureButtonDown, true);

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'printing trajectory')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.Position = [207 37 588 502];

            % Create leafletheightmmLabel
            app.leafletheightmmLabel = uilabel(app.UIFigure);
            app.leafletheightmmLabel.Position = [25 333 105 22];
            app.leafletheightmmLabel.Text = 'leaflet height (mm)';

            % Create leafheight
            app.leafheight = uislider(app.UIFigure);
            app.leafheight.Limits = [10 17];
            app.leafheight.ValueChangedFcn = createCallbackFcn(app, @leafheightValueChanged, true);
            app.leafheight.Position = [47 321 149 3];
            app.leafheight.Value = 12;

            % Create baseradiusmmLabel
            app.baseradiusmmLabel = uilabel(app.UIFigure);
            app.baseradiusmmLabel.Position = [24 422 99 22];
            app.baseradiusmmLabel.Text = 'base radius (mm)';

            % Create baseradius
            app.baseradius = uislider(app.UIFigure);
            app.baseradius.Limits = [8 15];
            app.baseradius.MajorTicks = [8 9 10 11 12 13 14 15];
            app.baseradius.ValueChangedFcn = createCallbackFcn(app, @baseradiusValueChanged, true);
            app.baseradius.Position = [46 410 150 3];
            app.baseradius.Value = 8.5;

            % Create pitchmmLabel
            app.pitchmmLabel = uilabel(app.UIFigure);
            app.pitchmmLabel.Position = [27 518 62 22];
            app.pitchmmLabel.Text = 'pitch (mm)';

            % Create pitch
            app.pitch = uispinner(app.UIFigure);
            app.pitch.Step = 0.05;
            app.pitch.Limits = [0.05 1];
            app.pitch.ValueChangedFcn = createCallbackFcn(app, @pitchValueChanged, true);
            app.pitch.Position = [108 518 91 22];
            app.pitch.Value = 0.35;

            % Create exportprinttrajectoryButton
            app.exportprinttrajectoryButton = uibutton(app.UIFigure, 'push');
            app.exportprinttrajectoryButton.ButtonPushedFcn = createCallbackFcn(app, @exportprinttrajectoryButtonPushed, true);
            app.exportprinttrajectoryButton.FontSize = 15;
            app.exportprinttrajectoryButton.Position = [56 37 112 44];
            app.exportprinttrajectoryButton.Text = {'export print'; 'trajectory'};

            % Create noofleavesSpinnerLabel
            app.noofleavesSpinnerLabel = uilabel(app.UIFigure);
            app.noofleavesSpinnerLabel.Position = [27 470 74 22];
            app.noofleavesSpinnerLabel.Text = 'no. of leaves';

            % Create leafnumber
            app.leafnumber = uispinner(app.UIFigure);
            app.leafnumber.Limits = [2 7];
            app.leafnumber.ValueChangedFcn = createCallbackFcn(app, @leafnumberValueChanged, true);
            app.leafnumber.Position = [108 470 91 22];
            app.leafnumber.Value = 3;

            % Create couplingradiusmmLabel
            app.couplingradiusmmLabel = uilabel(app.UIFigure);
            app.couplingradiusmmLabel.Position = [26 155 118 22];
            app.couplingradiusmmLabel.Text = 'coupling radius (mm)';

            % Create cpradius
            app.cpradius = uislider(app.UIFigure);
            app.cpradius.Limits = [4 8];
            app.cpradius.MajorTicks = [4 5 6 7 8];
            app.cpradius.ValueChangedFcn = createCallbackFcn(app, @cpradiusValueChanged, true);
            app.cpradius.Position = [48 143 149 3];
            app.cpradius.Value = 6;

            % Create valveheightmmLabel
            app.valveheightmmLabel = uilabel(app.UIFigure);
            app.valveheightmmLabel.Position = [28 244 101 22];
            app.valveheightmmLabel.Text = 'valve height (mm)';

            % Create sinusheight
            app.sinusheight = uislider(app.UIFigure);
            app.sinusheight.Limits = [21 28];
            app.sinusheight.ValueChangedFcn = createCallbackFcn(app, @sinusheightValueChanged, true);
            app.sinusheight.Position = [50 232 149 3];
            app.sinusheight.Value = 25;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = heart_valve_designer_AppScipt

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end