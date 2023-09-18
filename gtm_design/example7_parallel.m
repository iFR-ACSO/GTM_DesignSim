% Demo skript for initializing and running gtm_design simulations in
% parallel using the MWSToSimulationInput function
% before running this script, run a setup script for the gtm
%
% for usable results, the callback StopFcn "MWSout=grabmws(bdroot);" has to
% be commented out. This is done in the Property inspector in Simulink.

% Parallel pool is created automatically by the parsim command if not
% initiated beforehand by the parpool command. After 30 mins of idle time,
% the parallel pool is shut down automatically.

%% About
%
% * Authors:    Cunis Torbjoern, Holzinger Nico
% * Created:    2023-09
% * Changed:    2023-09

%%

clear all
warning('off','all')

% work-around unit conversion

ft2m = 0.3048;              % 1m = 0.3048
fps2mps = ft2m;
kts2fps = 1.68781;          % 1kt ~ 1.68781ft/s
kts2mps = kts2fps*fps2mps;

import aerootools.*
import aerootools.pkg.*

% Add mat file directory
addpath(genpath('./config/'));

% Add mfiles directories.
addpath('./mfiles');

% Add compilex code directory
addpath('./obj');

% Add libriary directory
addpath('./libs');

rehash path

%% Set simulation parameters

N = 10;             % number of simulations

%% Create random initial values
% EOM6States(v,alpha,beta,rollrate,pitchrate,yawrate, bank angle,
% pitch angle,yaw angle)


V = normrnd(40,15,N);                   % 95% of velocities will be between 10 and 70m/s
alpha = normrnd(10,25,N);               % 95% of Alphas between -40 and +60 °
beta = normrnd(0,22.5,N);               % 95% of Betas between -45 and 45 °
roll_dot = normrnd(0,90,N);             % 95% of Rollrates between -180 and 180 °/s
pitch_dot = normrnd(0,45,N);            % 95% of Pitchrates between -90 and 90 °/s
yaw_dot = normrnd(0,90,N);              % 95% of Yawrates between -180 and 180 °/s
bank = normrnd(0,90,N);                 % 95% of Bankangles between -180 and 180°
pitch = normrnd(0,45,N);                % 95% of Pitchangles between -90 and 90°
yaw = zeros(N,1);

initial = [V, alpha, beta, roll_dot, pitch_dot, yaw_dot, bank, pitch, yaw];

%% fill MWS structure
% create MWS (Modelworkspace) structure

MWSinit = init_design;

for i = N:-1:1         % Create and fill the input files
    % Create and fill input files with constant values
    in(i) = MWSToSimulationInput(MWSinit);

    % Give varying values to the existing input files (rounding necessary since SimulationInput only accepts strings)
    x_placeholder = EOM6States.wind2body(V(i)/ft2m, deg2rad(alpha(i)), deg2rad(beta(i)), deg2rad(roll_dot(i)), deg2rad(pitch_dot(i)), deg2rad(yaw_dot(i)), double(0), double(0), double(1200), deg2rad(bank(i)),deg2rad(pitch(i)),deg2rad(yaw(i)));
    x0(:,i) = round(x_placeholder,3);
    in(i) = in(i).setBlockParameter( 'gtm_design/GTM_T2/EOM/Integrator', 'InitialCondition', mat2str(x0(:,i)));
end

%% Start Simulation in parallel
    
simout = parsim(in, 'UseFastRestart','on','ShowProgress','on');

%% Call output
% for this code to work, only the final values of the simulation should be
% given back, a simple setting in the gtm model settings, however this is
% not standard and I did not want to change that in fear of messing with
% other examples. However, this part is not to important anyways. The
% parallel part is already over.
% 
% % check if the aircraft is back in a trim condition at the end of the
% % simulation without violating constraints and save the result in the fail
% % array
% 
% fail = boolean(zeros(N,1));
% 
% for i = 1:N   
% 
%     %Calling Output
%     Nlf_res = simout(i).Nlf_res;
%     p_res = simout(i).p_res;
%     q_res = simout(i).q_res;
%     theta_res = simout(i).theta_res;
%     bank_res = simout(i).bank_res;
%     fail_indi = simout(i).fail_indi;
% 
%     %Checking if succesfull
% 
%     if fail_indi > 0    % fail_indi indicates if at any point during the simulation, the aircraft was outside of the allowed envelope
%         fail(i) = true;
%     end
%     if failCheck(Nlf_res,p_res,q_res,theta_res,bank_res)
%         fail(i) = true;
%     end
% 
% end
% 
% fprintf(['\nOut of ', num2str(N), ' simulations, ', num2str(sum(fail)), ' failed to go back to trim condition without violating constraints.\n']);
% 
% %% function to check if the final condition is within the trim condition
% function bool = failCheck(Nlf_res,p_res,q_res,theta_res,bank_res)
% bool = false;
% 
% if Nlf_res < 0.75 || Nlf_res > 1.25 || abs(p_res) > 10 || abs(q_res) > 10 || theta_res < -10 || theta_res > 20 || abs(bank_res) > 15
%     bool = true;
% end
% 
% end