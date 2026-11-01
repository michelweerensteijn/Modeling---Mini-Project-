function [T, X, Q, Qt] = simulateHybrid(X0, p, delta, tspan, maxEvents)
%checking flow active mode,guard, fsm,jumps


if nargin < 5, maxEvents = 1000; end
tStart = tspan(1);  tEnd = tspan(2);

c  = struct('xs', 0, 'ys', 0, 'ts', tStart, 'tp', 0);  
q  = initialMode(X0, p);                                %initial mode
T  = tStart;   X = X0(:).';                             %time and state
Q  = {q};      Qt = tStart;                             %modes and start times


tol = {'RelTol', 1e-6, 'AbsTol', 1e-9, 'MaxStep', 0.01}; %using stiff solver

while T(end) < tEnd
    x0 = X(end,:).';                                    %current state 
    [ev, sigma] = makeEvents(q, p, c);                  %guard 
    opts = odeset('Events', ev, tol{:});
    [t, x, te, xe] = ode15s(@(t,X) fmode(t, X, q, p, c), [T(end), tEnd], x0, opts);

    
    for k = 1:numel(t)
        if ~invariants(t(k), x(k,:).', q, p, c)
            warning('Invariant of mode %s violated at t = %.3f s', q, t(k));
            break
        end
    end

    if ~isempty(te)                                     %guard fired
        tE = te(end);   xE = xe(end,:).';               
        [qn, g] = fsmStep(delta, q, sigma);             %FSM next mode
        if strcmp(qn, q)                                %no transition 
            warning('No transition from mode %s on event %s', q, sigma);
            T = [T; t(2:end)];  X = [X; x(2:end,:)];
            break
        end
        [xNew, cNew] = jumpMap(xE, q, qn, p, c, tE);    
        fprintf('t = %6.2f s : %s --%s/%s--> %s\n', tE, q, sigma, g, qn);

        % store 
        %post jump conditions
        T = [T; t(2:end)];  X = [X; x(2:end,:)];
        T = [T; tE];        X = [X; xNew.'];
        q = qn;  c = cNew;
        Q{end+1} = q;  Qt(end+1) = tE;

        if numel(Q) >= maxEvents
            disp('Maximum number of events reached (possible Zeno behavior).');
            break
        end
    else                                                %no guard fired
        if ~strcmp(q, 'P')                              
            warning('Guard of mode %s (%s) never fired before t = %.1f s', q, sigma, tEnd);
        end
        T = [T; t(2:end)];  X = [X; x(2:end,:)];
        Q{end+1} = q;  Qt(end+1) = tEnd;                %end of plot
        break
    end
end
end