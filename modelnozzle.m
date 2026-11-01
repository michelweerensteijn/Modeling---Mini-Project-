clc;
clear all;

n.Ln   = 1e-3;     % [H]    inductor
n.Cn   = 100e-6;   % [F]    capacitor
n.Rn   = 14.4;     % [Ohm]  heater resistor (24 V / 40 W heater cartridge)
n.Ctn  = 10;       % [J/K]  thermal capacity of heater block + nozzle
n.Rtn  = 8;        % [K/W]  thermal resistance to environment (+ filament)
n.Te   = 25;       % [C]    environmental temperature
n.Umax = 24;       % [V]    supply voltage

f=@(t,x,u) nozzle(x,u,n);

%for steady state
Pmax=n.Umax^2/n.Rn;
Tss=n.Te + n.Rtn*Pmax;
fprintf('Power: P= %.1f W, steady-state temp= %.0fC\n', Pmax, Tss);

Temp=210; %printing temp set

Uhold  = sqrt((Temp - n.Te)*n.Rn/n.Rtn);
fprintf('Voltage to hold %.0f C: u_n = %.2f V (power %.1f W)\n', Temp, Uhold, Uhold^2/n.Rn);

tau_th= n.Rtn*n.Ctn;
wn= 1/sqrt(n.Ln*n.Cn);
zeta= 1/(2*n.Rn)*sqrt(n.Ln/n.Cn);
fprintf('Thermal time constant (tau) =%.0fs\n', tau_th);
fprintf('Electrical: wn =%.0f rad/s, zeta =%.2f, settles in ~%.1f ms\n', wn, zeta, 1000*4/(zeta*wn));
fprintf('Ratio of time scales ~ %.0e  -> stiff system, use ode23s\n\n', tau_th*zeta*wn/4);



%for 24v voltage 
x0=[n.Te ; 0; 0];
opts= odeset('RelTol',1e-7, 'AbsTol',1e-9);
[tA, xA]= ode23s(@(t,x) f(t,x,n.Umax), [0 600], x0, opts);

t210 = tA(find (xA(:,1)>=Temp, 1));            
fprintf('A) Full power: reaches %.0f C after %.1f s, T(600 s) = %.1f C\n', Temp, t210, xA(end,1));

%if hold
[tB, xB]=ode23s(@(t,x) f(t,x,Uhold), [0 600], x0, opts);
fprintf('Hold Voltage: T(600s)=%.1f C(target %0.f C)\n', xB(end,1), Temp);


%to plot

figure('Name','Q1.5 Modelling the nozzle', 'Position', [100 100 1000 650]);
subplot(2,2,1);
plot(tA, xA(:,1), 'r', tB, xB(:,1), 'b', 'LineWidth', 1.3); hold on;
plot([0 600], [Tss Tss], 'r:', [0 600], [Temp Temp], 'b:');
grid on; xlabel('t [s]'); ylabel('T_n [^oC]'); title('nozzle temperature');
legend(sprintf('u_n = %.0f V', n.Umax), sprintf('u_n = %.1f V', Uhold), ...
       'steady state 24 V', '210 ^oC', 'Location', 'southeast');
 
subplot(2,2,2);
P_A = xA(:,3).^2/n.Rn;  L_A = (xA(:,1) - n.Te)/n.Rtn;
plot(tA, P_A, 'r', tA, L_A, 'k--', 'LineWidth', 1.3); grid on;
xlabel('t [s]'); ylabel('[W]'); title('heat flows (24 V case)'); ylim([0 50]);
legend('heating  v_C^2/R_n', 'loss  (T_n-T_e)/R_{t,n}', 'Location', 'east');
 
% electrical start-up transient (zoom on first 30 ms)
[tE, xE] = ode23s(@(t,x) f(t, x, n.Umax), [0 0.03], x0, odeset(opts,'MaxStep',1e-5));
subplot(2,2,3);
plot(1000*tE, xE(:,3), 'b', 'LineWidth', 1.3); hold on;
plot([0 30], [n.Umax n.Umax], 'k:'); grid on;
xlabel('t [ms]'); ylabel('v_C [V]'); title('capacitor voltage (first 30 ms)');
 
subplot(2,2,4);
plot(1000*tE, xE(:,2), 'b', 'LineWidth', 1.3); hold on;
plot([0 30], n.Umax/n.Rn*[1 1], 'k:'); grid on;
xlabel('t [ms]'); ylabel('i_L [A]'); title('inductor current (first 30 ms)');

