function R = straight(t, p0, p1, T)
% this function generates a straight trajectory (so positions, velocities, 
% accelerations and jerks) from start position p0 to end position p1 over duration T
% using a 5th-order polynomial.
%
% Inputs:
%   t: time vector or scalar
%   p0: start position
%   p1: end position
%   T: total duration of the movement [s]
%
% Output: R: 4 x numel(t) matrix [position; velocity; acceleration; jerk]

t = t(:).';
tau = t / T;
delta_p = p1 - p0;

% Initialize output
R = zeros(4, numel(t));

% Before the movement: remain at p0
before = t < 0;
R(1, before) = p0;

% During the movement: 5th order polynomial
moving = (t >= 0) & (t <= T);
tau_m = tau(moving);

s       = 10*tau_m.^3 - 15*tau_m.^4 + 6*tau_m.^5;
s_dot   = (30*tau_m.^2 - 60*tau_m.^3 + 30*tau_m.^4) / T;
s_ddot  = (60*tau_m - 180*tau_m.^2 + 120*tau_m.^3) / T^2;
s_dddot = (60 - 360*tau_m + 360*tau_m.^2) / T^3;

R(1, moving) = p0 + delta_p * s;
R(2, moving) = delta_p * s_dot;
R(3, moving) = delta_p * s_ddot;
R(4, moving) = delta_p * s_dddot;

% After the movement: remain at p1
after = t > T;
R(1, after) = p1;

end