%% --------------------- Steep Spiral Trajectory Simulation --------------------------
%
% This MATLAB script models a targeted steep spiral condition for a GTM_T2 aircraft, 
% simulates the trajectory from that condition, and plots various flight 
% parameters over time.
%
% Simulation Details:
% - The script begins by initializing the simulation with nominal design conditions for 
%   a GTM_T2 aircraft.
% - It then proceeds to set up conditions for a steep spiral as specified in
%   init_spiral_design function.
% - The trajectory is simulated for a duration of 100 seconds.
% - The resulting trajectory is plotted, showing the behavior of key flight parameters 
%   such as alpha, beta, flight path angle, airspeed, angular rates, and Euler angles 
%   over time.
% - The trajectory is also visualized in a 3D plot with an orientated aircraft shape.
%
%
%% About
%
% Author:     Omar Mourad
% Email:      <mailto: st181901@stud.uni-stuttgart.de>
% Created:    15.03.2024 


%% Conditions

% Start with some altitude,otherwise nominal init
MWS = init_design('GTM_T2');
loadmws(MWS,'gtm_design');
printStates(MWS);

% Proceed with the steep spiral conditions
MWS = init_spiral_design('GTM_T2');
printStates(MWS);
loadmws(MWS,'gtm_design');

%% Simulate
%Determine the Simulation time (in Secs)
time_of_simulation = 100;    
[t,x,y]=sim('gtm_design',[0 time_of_simulation]); 
intermediate = y;
%% Convert from lat/lon to ft 
Xeom=y(:,7:18);
dist_lat=(Xeom(:,7)-Xeom(1,7)) * 180/pi*364100.79;
dist_lon=(Xeom(:,8)-Xeom(1,8)) * 180/pi*291925.24;
alt=Xeom(:,9);
tplot=0:.1:max(t);

%% Save the data to file
save('SteepSpiralData.mat','t', 'tplot' , 'y', 'Xeom', 'dist_lat', 'dist_lon', 'alt');
