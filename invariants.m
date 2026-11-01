function ok = invariants(t, X, q, p, c)
% Returns true if the state X satisfies the invariant of mode q. c.ts is
% the time in which the current state began.
tol = 1e-6; % value for numerical tolerances 
x = X(1); 
y = X(4);
Tn = X(7); % nozzle temperature

switch q
    case 'P'
        ok = x>=0 && x<=p.dx && y>=0 && y<=p.dy && Tn >= p.Tref; % we stay within bounds and nozzle temperature high enough
    case 'S'
        ok = all(abs(X([2, 3, 5, 6])) < tol); %xdot, ix, ydot, iy are zero (with a numerical tolerance)
    case 'M'
        d = hypot(x,y); %distance from (x,y) to (0,0) 
        d0 = hypot(c.xs,c.ys); %distance from (xs,ys) to (0,0) 
        ok = d > 0 && d <= d0 + tol;
    case 'W'
        ok = abs(x)<tol && abs(y)<tol && (t - c.ts) < p.twipe + tol; % at (0,0) and wiping time not over yet
    case 'L'
        ok = abs(x)<tol && abs(y)<tol; % still at (0,0) while loading
    case 'N'
        ok = abs(x)<tol && abs(y)<tol && Tn < p.Tref + tol; % at (0,0) and nozzle not yet at reference temperature
    case 'R'
        d = hypot(x-c.xs, y-c.ys); 
        d0 = hypot(c.xs,c.ys);
        ok = d > 0 && d <= d0 + tol; % not yet back at the saved position, and never farther away than where we started
end
end