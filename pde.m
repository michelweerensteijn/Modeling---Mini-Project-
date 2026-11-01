clc;
clear all;

%parameters assumed

f.rho  = 1240;        % [kg/m^3]   density
f.c    = 1800;        % [J/(kg K)] specific heat capacity
f.k    = 0.13;        % [W/(m K)]  thermal conductivity
f.a    = 0.4e-3;      % [m]        side of the square cross-section (0.4 mm nozzle)
% heat exchange through the sides
f.hair = 10;          % [W/(m^2 K)] convection to air (no part-cooling fan)
f.hbed = 100;         % [W/(m^2 K)] contact with the heated bed temp
f.Te   = 25;          % [C] environment (as in Q1.5)
f.Tb   = 60;          % [C] heated bed (typical for PLA)
f.Tn   = 210;          % [C] nozzle temperature

A = 0.080;  B = 0.050;          % metres (Q1.4)
Tlap = 8;   %seconds one lap

%derived coeffs from report

Ac= f.a^2;
alpha = f.k/(f.rho*f.c);
lair=f.hair*3*f.a/(f.rho*f.c*Ac);
lbed=f.hbed*1*f.a/(f.rho*f.c*Ac);
lambda=lair+lbed;
Tuni=(lair*f.Te+lbed*f.Tb)/lambda; %uniform temperature


fprintf('alpha = %.2e m^2/s, lam_air = %.4f 1/s, lam_bed = %.4f 1/s\n', alpha, lair, lbed);
fprintf('Local cooling time constant tau = 1/lam = %.1f s\n', 1/lambda);
fprintf('Final (uniform) temperature T_inf = %.1f C\n\n', Tuni);

w=2*pi/Tlap;
spd= @(t) w*sqrt(A^2*sin(w*t).^2+B^2*cos(w*t).^2);
L=integral(spd, 0, Tlap);

fprintf('Ellipse parameterL=%.1f mm, printed in %.0f s\n', 1000*L, Tlap);

ds=1e-3;
N= round(L/ds);
ds=L/N;
sc=((1:N)'-0.5)*ds;
dt=5e-3;
dt_max= 1/(2*alpha/ds^2+lambda);   %explicit Euler

fprintf('N = %d cells, ds = %.3f mm, dt = %.3f s (stability limit %.2f s)\n\n', ...
        N, 1000*ds, dt, dt_max);

tEnd=80; %simulated time

t=0:dt:tEnd;

nt=numel(t);

ell=min(cumtrapz(t, spd(t)),L); %print length

ell(t>=Tlap)= L;

%for growing domain

T=f.Tn*ones(N,1); 
Tsave=nan(N, nt);   %not printed yet

for n=1:nt
    printing=t(n)<Tlap;
    if printing
        kn=min(N,max(1,ceil(ell(n)/ds)));
        act=(1:N)'<kn;%already printed
        T(kn)=f.Tn; %on nozzle
        Tl=[T(1); T(1:N-1)]; %left neighbour
        Tr= [T(2:N); T(N)];
    else
        kn=N+1;
        act=true(N,1);
        Tl = [T(N); T(1:N-1)];                    
        Tr = [T(2:N); T(1)];
    end
    Ts=T;
    Ts((1:N)'>kn)=NaN;
    if printing,
        Ts(kn)=f.Tn
    end
    Tsave(:,n)=Ts; %store

    %now calculating the PDE for every cell
    dTdt=alpha*(Tl-2*T+Tr)/ds^2+lair*(f.Te-T)+lbed*(f.Tb-T);
    T(act)=T(act)+dt*dTdt(act);
end

Tmax=max(Tsave, [], 1);
Tmin=min(Tsave, [], 1);
Tmean=mean(Tsave, 1, 'omitnan');
tol=1;
iu= find(t>Tlap &(Tmax-Tmin)<tol, 1);


fprintf('Smallest spread after printing: %.2f C\n', min(Tmax(t > Tlap) - Tmin(t > Tlap)));
fprintf('Nearly uniform (spread < %.0f C) at t = %.1f s  (%.1f s after printing ended)\n', ...
        tol, t(iu), t(iu) - Tlap);
fprintf('Mean temperature then: %.1f C (T_inf = %.1f C)\n', Tmean(iu), Tuni);


%plotting

figure('Name','Q1.6', 'Position', [80 80 1100 750]);
 
subplot(2,2,1);                                   % T(s,t) map: growing domain
imagesc(t, 1000*sc, Tsave, 'AlphaData', double(~isnan(Tsave))); axis xy;
colormap(gca, hot); cb = colorbar; ylabel(cb, 'T [^oC]');
hold on; plot(t, 1000*ell, 'c', 'LineWidth', 1.2);
xlabel('t [s]'); ylabel('s along path [mm]'); xlim([0 40]);
title('T(s,t): domain grows while printing');
 
subplot(2,2,2);                                   % snapshots along the path
snap = [2 4 6 Tlap 12 20 40];
hold on;
for j = 1:numel(snap)
    [~, nj] = min(abs(t - snap(j)));
    plot(1000*sc, Tsave(:,nj), 'LineWidth', 1.2, 'DisplayName', sprintf('t = %g s', snap(j)));
end
grid on; xlabel('s along path [mm]'); ylabel('T [^oC]');
title('temperature along the filament'); legend('Location','northeast');
 
subplot(2,2,3);                                   % uniformity
plot(t, Tmax, 'r', t, Tmin, 'b', t, Tmean, 'k--', 'LineWidth', 1.2); hold on;
plot([t(iu) t(iu)], [0 f.Tn], 'g:', 'LineWidth', 1.2);
plot([0 tEnd], [Tuni Tuni], 'k:');
grid on; xlabel('t [s]'); ylabel('T [^oC]'); ylim([0 f.Tn+10]);
title(sprintf('max / min / mean, uniform after %.0f s', t(iu)));
legend('max','min','mean','nearly uniform','T_\infty','Location','northeast');
 
subplot(2,2,4);                                   % top view at end of printing
[~, ne] = min(abs(t - (Tlap - dt)));
phi = zeros(N,1);                                 % map arc length -> angle on ellipse
pg  = linspace(0, 2*pi, 4001);
sg  = cumtrapz(pg/w, spd(pg/w));
phi(:) = interp1(sg, pg, sc);
scatter(1000*(0.125 + A*cos(phi)), 1000*(0.125 + B*sin(phi)), 18, Tsave(:,ne), 'filled');
axis equal; grid on; colormap(gca, hot); cb = colorbar; ylabel(cb, 'T [^oC]');
xlabel('x [mm]'); ylabel('y [mm]'); title(sprintf('top view at t = %.0f s (end of printing)', Tlap));