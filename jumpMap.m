function [Xn, cn] = jumpMap(X, q, qn, p, c, t)
% The reset map for the transition from q to qn at time t.
Xn = X;  
cn = c;

switch [q '>' qn]
    case 'P>S'   % stop printing and save the position
        cn.xs = X(1);  cn.ys = X(4);
        cn.tp = (t - c.ts) + c.tp;          % print time at the moment of stopping
        Xn([2 3 5 6]) = 0;                  % velocities and currents set to 0
    case 'M>W'   % Stop at (0,0)
        Xn(1:6) = 0; % All dynamics to zero. So position, speed and currents.
    case 'R>P'   % u_m+ = 0, resume at the saved position
        R  = [p.ref.x(c.tp), p.ref.y(c.tp)];   % each column: [pos; vel; acc; jerk]
        [~, ix] = invAxis(p.ref.x(c.tp), p.ax, p);
        [~, iy] = invAxis(p.ref.y(c.tp), p.ay, p);
        Xn(1:6) = [c.xs; R(2,1); ix; c.ys; R(2,2); iy];
        % S>M, W>L, L>N, N>R: no jump in the state (only u_n changes,
        % and that is handled in fmode)
end
cn.ts = t;   % the new mode starts now
end