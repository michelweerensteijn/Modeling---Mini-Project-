function dX = fmode(t, X, q, p, c)
% the dx of the active mode q.
% X = [x xd ix y yd iy Tn iL vc]^T
% c = a struct a saves needed info: c.xs, c.ys (saved position), c.tp (print time at which
%     printing was stopped), c.ts (start time of the current mode)
% So t - c.ts is the time in the time with respect to start of the mode.

mech = true; % true if the tool head is active. False if it is standing still
switch q
    case 'P'   % printing: reference (refE) resumes at print time c.tp
        ref.x = @(s) p.ref.x(s - c.ts + c.tp);
        ref.y = @(s) p.ref.y(s - c.ts + c.tp);
        ulr = volts(t, ref, p);  
        un = p.Uhold;
    case 'M'   % moving to the wipe tower (0,0)
        ref = lineRef(c, [c.xs, c.ys], [0, 0], p.Tm);
        ulr = volts(t, ref, p);  
        un = p.Uhold;
    case 'R'   % returning to the saved position
        ref = lineRef(c, [0, 0], [c.xs, c.ys], p.Tr);
        ulr = volts(t, ref, p); 
        un = p.Uhold;
    case 'S'
        mech = false;  
        un = p.Uhold;   % standing still
    case 'W'
        mech = false;  
        un = p.Uhold;   % wiping (heater on)
    case 'L'
        mech = false;  
        un = 0;         % loading (heater off)
    case 'N'
        mech = false;  
        un = p.uref;    % heating up again
end

dX = zeros(9,1);
if mech
    [A,B] = xyDecoupledModel(p);
    ux = ulr(1) + ulr(2);   
    uy = ulr(1) - ulr(2);
    dX(1:6) = A*X(1:6) + B*[ux; uy]; % Define dynamics
else
    dX(1:6) = zeros(6,1);   % tool head is fully frozen. Because no motion in this mode
end


dX(7:9) = nozzle(X(7:9), un, p.n);   % defines nozzle dynamics [Tn; iL; vc]
end

function ref = lineRef(c, P0, P1, T)
% Straight-line reference from P0 to P1 in time T, starting at moment c.ts
    ref.x = @(t) straight(t - c.ts, P0(1), P1(1), T);
    ref.y = @(t) straight(t - c.ts, P0(2), P1(2), T);
end