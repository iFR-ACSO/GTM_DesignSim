function MWS = init_spiral_design(vehicle,noise_on,fuelburn_on)
%
% Initializes the Model Workspace Structure for simulating a targeted steep spiral condition.
%
% Inputs:
%   vehicle      - Type of vehicle, currently only 'GTM_T2' (default = 'GTM_T2').
%   noise_on     - Flag for turning sensor noise models on (default = 0).
%   fuelburn_on  - Flag for turning the fuel burn model on (default = 0).
%
% Outputs:
%   MWS          - Simulation parameters to be loaded into the Model Workspace 
%                  with loadmws(MWS) or appendmws(MWS).
%
%
% This function initializes the simulation environment for a steep spiral condition 
% of the specified vehicle type. It sets up parameters such as wind direction and speed, 
% simulation timestep, initial conditions, aircraft dynamics, noise models, damage models,
% and other simulation options.
%
% The resulting MWS structure contains all the necessary parameters for simulating the 
% targeted steep spiral condition.
%
%% About
%
% Author:     Omar Mourad
% Email:      <mailto: st181901@stud.uni-stuttgart.de>
% Created:    15.03.2024

if ~exist('vehicle','var') || isempty(vehicle)
    vehicle='GTM_T2';
end

if strcmp(vehicle,'GTM'),
    vehicle='GTM_T2';  % Backwards compatible
end

if ~exist('noise_on','var') || isempty(noise_on)
    noise_on = 0;
end

if ~exist('fuelburn_on','var') || isempty(fuelburn_on)
    fuelburn_on = 0;
end

% Initialize MWS structure
MWS=[];

% Winds
MWS.WindDir = 270;  %deg,   true heading wind is coming FROM
MWS.WindSpd = 0;    %kts,   wind speed
MWS.WindShearOn = 1;

% Sim timestep
MWS.Timestep = 1/200; % sec

% Steep Spiral Initial Conditions
ini.Altitude =     0;          % ft

ini.tas      =     43.32;      % (meter/sec)

ini.alpha    =     20.05;           % deg
ini.beta     =     -7.55;           % deg

ini.p        =     -122.9;           % (deg/s)
ini.q        =       49.1;           % (deg/s)
ini.r        =      -45.4;           % (deg/s)

ini.bank       =       -47.3;            % deg
ini.pitch      =       -61.5;            % deg
ini.heading    =           0;            % deg


ini.p = -250; 

ini.stab     =     0;

% Flying at Wallops
ini.lat        =  37.827926944;            % deg
ini.lon        = -75.494061666;            % deg
MWS.StatesInp  = SetICs(ini);
MWS.runway_alt = 12;                       %ft

MWS.fuel_in_use  = fuelburn_on;            % fuel burn on/off


switch(upper(vehicle))
    case 'GTM_T2',
      %MWS.Aero=load('T2_restricted_aerodatabase');
      MWS.Aero=load('T2_polynomial_aerodatabase');

       % Load aircraft parameters and noise models
       MWS = AC_baseparams_T2(MWS);
       MWS = NoiseParams_T2(MWS,noise_on); % Second parameter is on/off

       % Generate Damage Models
       MWS = DamageModels_T2(MWS);
    otherwise,
       error('No Parameters defined for vehicles: %s',vehicle);
end

% Surface/Throttle Offsets for trim
MWS.bias.aileron    =0;
MWS.bias.speedbrake =0;
MWS.bias.elevator   =0;
MWS.bias.flaps      =0;
MWS.bias.rudder     =0;
MWS.bias.stabilizer =0;
MWS.bias.throttle   =20;
MWS.bias.geardown   =0;

% Basic Table Options
MWS.LinearizeModeOn=0;
MWS.TrimModeOn=0;
MWS.SurfaceDeadbandOn=0;
MWS.TrimWithStab=0;
MWS.symmetric_aero_on  = 1;
MWS.DamageCase = 0;
MWS.DamageOnsetTime=10; % In secs.

% Engine on/off parameters
MWS.LengON = 1;
MWS.RengON = 1;

%Engine Ram Drag Coefficient
MWS.ram_drag_coef = 0.010;

% Set turbulence model parameters
MWS = init_turbulence(MWS);

% The following increase asymetric response at stall and
% have been used for pilot training
MWS.stall_cl_asym_enabled         = 0;     % turn the Cl asymetry at stall on/off
%MWS.stall_cl_asym_add_uncertainty = 0;    % add random uncertainties to Cl
%MWS.stall_cl_asym_vary_sign       = 0;    % apply random +/-1 gain to Cl


%--------------------SubFunctions--------------------

function [StatesInp] = SetICs(ini)
StatesInp= zeros(12,1);

metersPerSecond2fps = 3.28084;
d2r=pi/180;

ub = (metersPerSecond2fps)*ini.tas*cos(ini.alpha*d2r)*cos(ini.beta*d2r);
vb = (metersPerSecond2fps)*ini.tas*sin(ini.beta*d2r);
wb = (metersPerSecond2fps)*ini.tas*sin(ini.alpha*d2r)*cos(ini.beta*d2r);

ini.gamma    = ini.pitch - ini.alpha;

StatesInp(1)  = ub;      %  1 - ub (ft/s)
StatesInp(2)  = vb;		 %  2 - vb (ft/s)
StatesInp(3)  = wb;		 %  3 - wb (ft/s)
StatesInp(4)  = ini.p*d2r;		 %  4 - pb (rad/s)
StatesInp(5)  = ini.q*d2r;		 %  5 - qb (rad/s)
StatesInp(6)  = ini.r*d2r;		 %  6 - rb (rad/s)
StatesInp(7)  = ini.lat*d2r;	 %  7 - lat (rad), +north,
StatesInp(8)  = ini.lon*d2r;	 %  8 - lon (rad), +east,
StatesInp(9)  = ini.Altitude;	 %  9 - h (ft)
StatesInp(10) = ini.bank*d2r;	      % 10 - phi (rad)
StatesInp(11) = ini.pitch*d2r;        % 11 - theta (rad)
StatesInp(12) = ini.heading*d2r;	  % 12 - psi (rad)





