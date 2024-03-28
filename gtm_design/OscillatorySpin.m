%% --------------------- Oscillatory Trajectory Simulation --------------------------
%
% This MATLAB script models a targeted oscillatory spin condition for a GTM_T2 aircraft, 
% simulates the trajectory from that condition, and plots various flight 
% parameters over time.
%
% Simulation Details:
% - The script begins by initializing the simulation with nominal design conditions for 
%   a GTM_T2 aircraft.
% - It then proceeds to set up conditions for an oscillatory spin as specified in
%   init_spin_design function.
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
% Created:    20.03.2024 


%% Conditions

% Start with some altitude,otherwise nominal init
MWS = init_design('GTM_T2');
loadmws(MWS,'gtm_design');
printStates(MWS);

% Proceed with the oscillatory spin conditions
MWS = init_spin_design('GTM_T2');
printStates(MWS);
loadmws(MWS,'gtm_design');

%% Simulate
%Determine the Simulation time (in Secs)
time_of_simulation = 100; 
[t,x,y]=sim('gtm_design',[0 time_of_simulation]); 

%% Convert from lat/lon to ft 
Xeom=y(:,7:18);
dist_lat=(Xeom(:,7)-Xeom(1,7)) * 180/pi*364100.79;
dist_lon=(Xeom(:,8)-Xeom(1,8)) * 180/pi*291925.24;
alt=Xeom(:,9);

%% Define simple airplane shape
scale=1;
x1=scale*([0.0,-.5, -2.0, -3.0,-4.0, -3.25, -5.5, -6.0, -6.0]+3.0);
y1=scale*[0.0, 0.5,  0.5, 4.25, 4.5,  0.5,   0.5,  1.5,  0.0];
Vehicletop=[ [x1,fliplr(x1)]; [y1,fliplr(-y1)]; -.01*ones(1,2*length(x1))];
Vehiclebot=[ [x1,fliplr(x1)]; [y1,fliplr(-y1)];  .01*ones(1,2*length(x1))];


%% ------------------------Plots---------------------------
h=figure(1);,set(h,'Position',[20,20,1200,800]);clf

% Alpha/Beta
axes('position',[.1 .75 .23 .13])
plot(t,[y(:,3),y(:,4)]); % y(:,3) ----> Alphas // y(:,4) ----> Betas
legend({'\alpha','\beta'},'Location','SouthEast');,grid on
xlabel('time (sec)'),
ylabel('\alpha (deg), \beta (deg)');
title('Alpha/Beta');

% Flight Path Angle and Airspeed
axes('position',[.1 .55 .23 .13])
[ax,h1,h2]=plotyy(t,y(:,5),t,y(:,1));grid on % y(:,5) ----> Gammas //
xlabel('time (sec)'),                        % %y(:,1) ----> Airspeeds
ylabel(ax(1),'Flight Path,  \gamma (deg)');
ylabel(ax(2),'Equivalent Airspeed (konts)')
legend([h1;h2],{'\gamma','eas'},'Location','SouthEast');
title('Flight Path Angle and Airspeed');

% Angular Rates
axes('position',[.1 .35 .23 .13])
plot(t,Xeom(:,4:6)*180/pi);grid on
legend({ 'p','q','r'},'Location','SouthEast');
xlabel('time (sec)'),ylabel('angular rates (deg/sec)')
title('Angular Rates');

% Euler Angles
axes('position',[.1 .15 .23 .13]);
plot(t,[y(:,16)*180/pi, y(:,17)*180/pi, y(:,18)*180/pi]);
% y(:,16) ---> Phi  // y(:,17) ---> Theta // y(:,18) ---> Psi
legend({'roll','pitch','yaw'},'Location','NorthEast');,grid on
xlabel('time (sec)');
ylabel('\phi (deg), \theta (deg), \psi (deg)');
title('Euler Angles');

% Trajectory: 3D plot with orientated vehicle
axes('position',[.45,.15,.5,.7])
plot3(dist_lat,dist_lon,alt);grid on, axset=axis; % Just get axis limits
%cnt=0;
% resample at equally spaced points for animation plot
tplot=[0:.1:max(t)];
X_ani=interp1(t,Xeom,tplot);
lat_ani=interp1(t,dist_lat,tplot);
lon_ani=interp1(t,dist_lon,tplot);
alt_ani=interp1(t,alt,tplot);
tic
for i=[1:length(tplot)]
  plot3(dist_lat,dist_lon,alt);grid on
  Offset=repmat([lat_ani(i);lon_ani(i);alt_ani(i)],1,size(Vehicletop,2));
  Ptmp=diag([1,1,-1])*transpose(euler321(X_ani(i,10:12)))*Vehicletop + Offset;
  patch(Ptmp(1,:),Ptmp(2,:),Ptmp(3,:),'g');
  Ptmp=diag([1,1,-1])*transpose(euler321(X_ani(i,10:12)))*Vehiclebot + Offset;
  patch(Ptmp(1,:),Ptmp(2,:),Ptmp(3,:),'c');
  view(25,10),axis(axset),hold off
  xlabel('Lat. Crossrange(ft)');
  ylabel('Long. Crossrange(ft)');
  zlabel('Altitude(ft)');
  title('Simulation of Oscillatory Spin Trajectory');
  pause(.1);
end
toc
if(exist('AutoRun','var'))
    pause(.2);
    orient portrait; print -dpng SteepSpiral;
end

