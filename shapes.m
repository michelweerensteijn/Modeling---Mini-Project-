clc;
clear all;

%parameter values

p.rm   = 6.37e-3;   % [m]      pulley radius (GT2, 20 teeth)
p.Lm   = 2.5e-3;    % [H]      motor inductance
p.Rm   = 4.5;       % [Ohm]    motor resistance
p.Jm   = 5.4e-6;    % [kg m^2] rotor inertia
p.Km   = 0.045;     % [Nm/A]   motor constant (= back-emf constant [Vs/rad])
p.m    = 0.180;     % [kg]     tool-head mass
p.mur  = 0.004;     % [Ns/m]   idler bearing friction
p.mulx = 0.003;     % [Ns/m]   linear rail friction x
p.muly = 0.002;     % [Ns/m]   linear rail friction y
p.dx   = 0.250;     % [m]      print area x
p.dy   = 0.250;     % [m]      print area y
p.Umax = 24;        % [V]      supply voltage (max |u_l|, |u_r|)


%solved from q1.2 and 1.3

p.Mm = 0.5*p.m*p.rm^2 + p.Jm;           
p.C1 = p.rm^2/2*(p.mulx + p.muly);
p.C2 = p.rm^2/2*(p.mulx - p.muly);
p.C3 = 4*p.mur*p.rm^2;


p.ax = (p.C1 + p.C2 + p.C3)/p.Mm;        
p.ay = (p.C1 - p.C2 + p.C3)/p.Mm;        
p.b  = p.rm*p.Km/(2*p.Mm);               
p.c  = 2*p.Km/(p.rm*p.Lm);     



[A, B] = fullModel(p);

h=p.rm/2;

%drawing ellipse
%x(t)=xc + Acos(wt)
%y(t)=yc + Bsin(wt)

xc=0.125;
yc=0.125;%in meters
A_mm=0.080;
B_mm=0.050; 

Tp=2;
w=2*pi/Tp;

refE.x=@(t) harm(t,xc,A_mm,0,w); %(t, offset,cos,sin,w)
refE.y=@(t) harm(t,yc,0, B_mm,w);

resE= shape(refE, Tp,p, A,B, true, 'Ellipse');


%drawing waterdrop
%   x = sin(phi)*sin(phi/2) = 0.5*cos(phi/2) - 0.5*cos(3*phi/2)
%   y = cos(phi)

s=0.060; %scaling
Th=4; w0= pi/Th; %one lap in 4s
k=1:3;
refH.x= @(t) harmK(t,xc,s*[0.5 0 -0.5], s*[0 0 0],k,w0);
refH.y= @(t) harmK(t,yc,s*[0 1 0], s*[0 0 0],k,w0); 
resH= shape(refH, Th,p, A,B, true, 'Waterdrop');

tTip= [0, Th]; %speed 0 at the sharp end

RxT=refH.x(tTip);
RyT=refH.y(tTip);


vTip = sqrt(RxT(2,:).^2 + RyT(2,:).^2);
fprintf('Raindrop: speed at the tip = %.1e m/s (start) and %.1e m/s (end of lap)\n', vTip(1), vTip(2));

%ellipse from rest
resC= shape(refE, 2*Tp, p, A, B, false, 'Ellipse, started from rest');

function res= shape(ref, tEnd, p, A, B, matchedshape, name)
h=p.rm/2

Rx= ref.x(0); 
Ry= ref.y(0);

%inverse

[~, ix0] = invAxis(Rx, p.ax, p);   [~, iy0] = invAxis(Ry, p.ay, p);
th_l = (Rx(1)+Ry(1))/p.rm;   th_r = (Rx(1)-Ry(1))/p.rm;     % inverse kinematics

if matchedshape

X0=[th_l; th_r; (Rx(2)+Ry(2))/p.rm; (Rx(2)-Ry(2))/p.rm; (ix0+iy0)/2; (ix0-iy0)/2];

else
    X0=[th_l;th_r; 0; 0; 0; 0]
end
opts = odeset('RelTol',1e-8,'AbsTol',1e-11,'MaxStep',2e-3);
[t, X] = ode45(@(t,X) A*X + B*volts(t, ref, p), [0 tEnd], X0, opts);

x=h*(X(:,1)+X(:,2));
y=h*(X(:,1)-X(:,2));

Rx=ref.x(t);
Ry=ref.y(t);

U=volts(t.', ref, p);
err= 1000*sqrt((x.'-Rx(1,:)).^2 + (y.'-Ry(1,:)).^2);


fprintf('%-28s max|ul|= %5.2f V, max|ur|= %5.2f V, max error= %.2e mm, final error= %.2e mm\n', name, max(abs(U(1,:))), max(abs(U(1,:))), max(err), err(end));

if max(abs(U(:)))>p.Umax, warning('%s: voltage exceeds the supply', name);
end
if any(x<0 | x>p.dx | y<0 | y>p.dy), warning('%s: leaves the print area', name);
end



figure('Name', name, 'Position', [100 100 1000 650]);
subplot(2,2,1);
plot(1000*Rx(1,:), 1000*Ry(1,:), 'k--', 1000*x, 1000*y, 'b', 'LineWidth', 1.3);
hold on; plot(1000*x(1), 1000*y(1), 'go', 'MarkerFaceColor','g');
rectangle('Position', [0 0 1000*p.dx 1000*p.dy], 'LineStyle', ':');
axis equal; axis([-10 1000*p.dx+10 -10 1000*p.dy+10]); grid on;
xlabel('x [mm]'); ylabel('y [mm]'); title([name ': path']);
legend('reference','simulated','start','Location','best');


subplot(2,2,2);
plot(t, 1000*Rx(1,:), 'k--', t, 1000*x, 'b', t, 1000*Ry(1,:), 'k:', t, 1000*y, 'r');
grid on; xlabel('t [s]'); ylabel('[mm]'); title('positions');
legend('x_{ref}','x','y_{ref}','y','Location','best');


subplot(2,2,3);
plot(t, U(1,:), 'b', t, U(2,:), 'r', 'LineWidth', 1.2); hold on;
yline(p.Umax,'k:'); yline(-p.Umax,'k:');
grid on; xlabel('t [s]'); ylabel('[V]'); title('motor voltages');
legend('u_l','u_r','Location','best');


subplot(2,2,4);
plot(t, err, 'b'); grid on; xlabel('t [s]'); ylabel('[mm]');
title('tracking error |p - p_{ref}|');


res=struct('t', t, 'x', x, 'y', y, 'U', U, 'err', err);
end
