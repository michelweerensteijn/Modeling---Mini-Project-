function [A, B] = xyDecoupledModel(p)
% State vector: X = [x; xdot; ix; y; ydot; iy] (with ix = il + ir, iy = il - ir)
% Input vector: U = [ux; uy] (with ux = ul + ur, uy = ul - ur)

c1 = p.C1;  c2 = p.C2;  c3 = p.C3;
Mm = p.Mm;  rm = p.rm;  Km = p.Km;  Lm = p.Lm;  Rm = p.Rm;

% coefficients
ax = (c1 + c2 + c3) / Mm;
ay = (c1 - c2 + c3) / Mm;

b  = rm * Km / (2 * Mm);
ke = 2 * Km / (rm * Lm); % back-emf term (same as p.c in shapes.m)

% x-axis subsystem: [x; xdot; ix]
Ax = [0,  1,   0;
    0, -ax,  b;
    0, -ke, -Rm/Lm];
Bx = [0; 0; 1/Lm];

% y-axis subsystem: [y; ydot; iy]
Ay = [0,  1,   0;
    0, -ay,  b;
    0, -ke, -Rm/Lm];
By = [0; 0; 1/Lm];

% Combine the x and y subsystems
A = blkdiag(Ax, Ay);
B = blkdiag(Bx, By);
end