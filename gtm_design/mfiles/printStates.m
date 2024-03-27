function printStates(MWS)
%% --------------------- Print Aircraft States Information --------------------------------
%
% This function, printStates, is designed to display the state information 
% of an aircraft stored in a Model Workspace Structure (MWS). It prints 
% various states such as velocity components, angular velocities, geographic 
% coordinates, altitude, and Euler angles in a human-readable format.
%
% The function takes an input parameter MWS, which is expected to be a 
% structure containing the aircraft state information. It then prints out 
% each state variable along with its corresponding value.
%
% The printed states include:
%   1. Linear velocity components (ub, vb, wb) in meters per second (m/s).
%   2. Angular velocity components (pb, qb, rb) in degrees per second (deg/s).
%   3. Geographic coordinates (lat, lon) in degrees.
%   4. Altitude (h) in meters.
%   5. Euler angles (phi, theta, psi) in degrees.
%   6. Derived states (alpha, beta) in degrees, calculated from linear velocity components.
%
% This function is useful for debugging and monitoring the state of an aircraft 
% during simulation or analysis.
%
% Syntax:
%   printStates(MWS)
%
% Inputs:
%   - MWS: Model Workspace Structure containing aircraft state information.
%
% Example:
%   % Define an example Model Workspace Structure
%   MWS.StatesInp = [100, 50, 20, 0.1, 0.2, 0.3, 0.5, 1.0, 5000, 0.2, 0.1, 0.3];
%   
%   % Print the state information
%   printStates(MWS)
%
% Output:
%   The function prints the state information to the MATLAB command window.
%
%% Author: Omar Mouard
% Email: <mailto: st181901@stud.uni-stuttgart.de>
% Date: 15.03.2024
    
    fps2metersPerSecond=0.3048;
    
    fprintf('Aircraft States Information:\n');
    fprintf('  1. Linear Velocities:\n');
    fprintf('     - u (m/s): %.2f\n', MWS.StatesInp(1)*fps2metersPerSecond);
    fprintf('     - v (m/s): %.2f\n', MWS.StatesInp(2)*fps2metersPerSecond);
    fprintf('     - w (m/s): %.2f\n', MWS.StatesInp(3)*fps2metersPerSecond);
    fprintf('  2. Angular Velocities:\n');
    fprintf('     - p (deg/s): %.2f\n', rad2deg(MWS.StatesInp(4)));
    fprintf('     - q (deg/s): %.2f\n', rad2deg(MWS.StatesInp(5)));
    fprintf('     - r (deg/s): %.2f\n', rad2deg(MWS.StatesInp(6)));
    fprintf('  3. Geographic Coordinates:\n');
    fprintf('     - latitude (deg): %.6f\n', rad2deg(MWS.StatesInp(7)));
    fprintf('     - longitude (deg): %.6f\n', rad2deg(MWS.StatesInp(8)));
    fprintf('  4. Altitude (m): %.2f\n', MWS.StatesInp(9));
    fprintf('  5. Euler Angles:\n');
    fprintf('     - roll (phi) (deg): %.2f\n', rad2deg(MWS.StatesInp(10)));
    fprintf('     - pitch (theta) (deg): %.2f\n', rad2deg(MWS.StatesInp(11)));
    fprintf('     - yaw (psi) (deg): %.2f\n', rad2deg(MWS.StatesInp(12)));
    fprintf('  6. Derived States:\n');
    fprintf('     - angle of attack (alpha) (deg): %.2f\n', atan2(MWS.StatesInp(3), MWS.StatesInp(1)) * 180/pi);
    fprintf('     - sideslip angle (beta) (deg): %.2f\n', atan2(MWS.StatesInp(2), sqrt((MWS.StatesInp(1))^2 + (MWS.StatesInp(3))^2)) * 180/pi);
end
