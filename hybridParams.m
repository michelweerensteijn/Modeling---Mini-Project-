function p = hybridParams(p, n)
% Adds hybdrid simulation parameters to p and n
p.n      = n;
p.Temp   = 210; %starting temperature (which is Tset in report)
p.Uhold  = sqrt((p.Temp - n.Te)*n.Rn/n.Rtn);  % Holding voltage from Q1.5
p.uref   = n.Umax;       % u_n from mode N (to heat the nozzle)
p.Tref   = 200;          % In degrees celcius. Temperature to allow printing
p.eps    = 1e-5;         % In meters, a tolerance for distances in guards
p.tS     = 0.1;          % [s] duration of mode S
p.Tm     = 2;            % [s] duration to the wiptower
p.Tr     = 2;            % [s] duration to the saved position
p.twipe  = 3;            % [s] duration for wiping filament
p.tload  = 10;           % [s] duration of loading the new filament
p.tC     = Inf;          % [s] standard duration of C (color change)
p.tF     = Inf;          % [s] standard duration of F (empty)
end