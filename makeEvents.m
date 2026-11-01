function [ev, sigma] = makeEvents(q, p, c)
% ev    : event function [value,isterminal,direction] = ev(t,X)
% sigma : FSM event symbol belonging to this guard (to be used in fsmStep)
switch q
    case 'P'
        tstop = min(p.tC, p.tF);                 % first external event (C or F) stops the printing
        ev = guard(@(t,X) t - tstop, +1);        % crosses zero upwards when t reaches tstop
        if p.tC <= p.tF
            sigma = 'C';
        else
            sigma = 'F';
        end                                      % symbol of the event that came first
    case 'S'
        ev = guard(@(t,X) t - c.ts - p.tS, +1);  % internal trigger: mode S lasts tS seconds
        sigma = 's';
    case 'M'
        ev = guard(@(t,X) hypot(X(1),X(4)) - p.eps, -1);                % distance to (0,0) drops below eps
        sigma = 'a_w';
    case 'W'
        ev = guard(@(t,X) t - c.ts - p.twipe, +1);                      % wiping time is over
        sigma = 'w';
    case 'L'
        ev = guard(@(t,X) t - c.ts - p.tload, +1);                      % loading time is over (filament loaded)
        sigma = 'l';
    case 'N'
        ev = guard(@(t,X) X(7) - p.Tref, +1);                           % nozzle temperature rises above Tref
        sigma = 'T_hi';
    case 'R'
        ev = guard(@(t,X) hypot(X(1)-c.xs, X(4)-c.ys) - p.eps, -1);     % distance to saved position drops below eps
        sigma = 'a_s';
end
end

function ev = guard(fval, dir)
% wraps a scalar guard function into the [value, isterminal, direction] form of odeset
ev = @(t,X) evOut(fval(t,X), dir);
end

function [value, isterminal, direction] = evOut(v, dir)
value = v;  isterminal = 1;  direction = dir;
end