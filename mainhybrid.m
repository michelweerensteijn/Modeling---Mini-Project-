clc; 
clear all;

%parameters
p.rm = 6.37e-3;  p.Lm = 2.5e-3;  p.Rm = 4.5;  p.Jm = 5.4e-6;  p.Km = 0.045;
p.m = 0.180;  p.mur = 0.004;  p.mulx = 0.003;  p.muly = 0.002;
p.dx = 0.250;  p.dy = 0.250;  p.Umax = 24;
p.Mm = 0.5*p.m*p.rm^2 + p.Jm;
p.C1 = p.rm^2/2*(p.mulx + p.muly);
p.C2 = p.rm^2/2*(p.mulx - p.muly);
p.C3 = 4*p.mur*p.rm^2;
p.ax = (p.C1 + p.C2 + p.C3)/p.Mm;
p.ay = (p.C1 - p.C2 + p.C3)/p.Mm;
p.b  = p.rm*p.Km/(2*p.Mm);

n.Ln = 1e-3;  n.Cn = 100e-6;  n.Rn = 14.4;  n.Ctn = 10;  n.Rtn = 8;
n.Te = 25;    n.Umax = 24;


p = hybridParams(p, n);
xc = 0.125;  yc = 0.125;  A_e = 0.080;  B_e = 0.050;  w = 2*pi/2;   %ellipse one lap in 2s
p.ref.x = @(t) harm(t, xc, A_e, 0, w);
p.ref.y = @(t) harm(t, yc, 0, B_e, w);
p.tC = 5;                                  %colour request C at t = 5s


delta = { 'P','none','P','g0'; %fsm 2.1
    'P','C',   'S','g1';
    'P','F',   'S','g1';
    'S','s',   'M','g2';
    'M','a_w', 'W','g3';
    'W','w',   'L','g4';
    'L','l',   'N','g5';
    'N','T_hi','R','g6';
    'R','a_s', 'P','g7' };


Rx0 = p.ref.x(0);  Ry0 = p.ref.y(0); %initial state
[~, ix0] = invAxis(Rx0, p.ax, p);
[~, iy0] = invAxis(Ry0, p.ay, p);
X0 = [Rx0(1); Rx0(2); ix0; Ry0(1); Ry0(2); iy0; p.Temp; p.Uhold/n.Rn; p.Uhold];


tEnd = 40;
[T, X, Q, Qt] = simulateHybrid(X0, p, delta, [0, tEnd]);


modeNames = 'PSMWLNR';
[~, qi] = ismember(cell2mat(Q), modeNames);     %modes
qT = interp1(Qt, qi, T, 'previous');            %at time point
col = lines(7);
tSw = Qt(2:end-1);                              %switching 

    % reconstructing u_l, u_r


%plotting

figure('Name', 'Q3.1', 'Position', [80 80 1100 750]);

subplot(2,2,1);                                
hold on;
for k = 1:7
    idx = qT == k;
    plot(1000*X(idx,1), 1000*X(idx,4), '.', 'Color', col(k,:), 'MarkerSize', 4);
end
plot(0, 0, 'ks', 'MarkerFaceColor', 'k');       
rectangle('Position', [0 0 1000*p.dx 1000*p.dy], 'LineStyle', ':');
axis equal; grid on; xlabel('x [mm]'); ylabel('y [mm]'); title('path, coloured by mode');
hl = zeros(1,7);
for k = 1:7, hl(k) = plot(nan, nan, '-', 'Color', col(k,:), 'LineWidth', 3); end
legend(hl, cellstr(modeNames.'), 'Location', 'northeast');

subplot(2,2,2);                                 
stairs(Qt, qi, 'g', 'LineWidth', 1.2); grid on;
set(gca, 'YTick', 1:7, 'YTickLabel', cellstr(modeNames.')); ylim([0.5 7.5]);
xlabel('t [s]'); title('mode q(t)');

subplot(2,2,3);                                 
plot(T, X(:,7), 'b', 'LineWidth', 1.2); hold on;
yline(p.Tref, 'r--');
for k = 1:numel(tSw), xline(tSw(k), ':', 'Color', [0.5 0.5 0.5]); end
grid on; xlabel('t [s]'); ylabel('T_n [^oC]'); title('nozzle temperature');

subplot(2,2,4);                                 
plot(T, 1000*X(:,1), 'b', T, 1000*X(:,4), 'r'); hold on;
for k = 1:numel(tSw), xline(tSw(k), ':', 'Color', [0.5 0.5 0.5]); end
grid on; xlabel('t [s]'); ylabel('[mm]'); title('tool head position'); legend('x', 'y');