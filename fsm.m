clc;
clear all;

%transition function
delta = { 'P','none','P','g0';
          'P','C',   'S','g1';
          'P','F',   'S','g1';
          'S','s',   'M','g2';
          'M','a_w', 'W','g3';
          'W','w',   'L','g4';
          'L','l',   'N','g5';
          'N','T_hi','R','g6';
          'R','a_s', 'P','g7' };
%current state, event, next state, output


out = struct( ...
  'g0', 'continue printing', ...
  'g1', 'stop printing, save (xp,yp) := (x,y)', ...
  'g2', 'move to (0,0)', ...
  'g3', 'start wiping at (0,0)', ...
  'g4', 'nozzle heater OFF, start loading filament', ...
  'g5', 'nozzle heater ON', ...
  'g6', 'move to saved position (xp,yp)', ...
  'g7', 'resume printing'); %output map

states={'P','S','M','W','L','N','R'};
pairs=strcat(delta(:,1), '|', delta(:,2));

isDeterministic= numel(unique(pairs))==numel(pairs); %deterministic
isBlocking=false;

for i=1:numel(states)
    if ~any(strcmp(delta(:,1), states{i})), isBlocking=true; end
end
fprintf('Deterministic: %d, Blocking %d\n\n', isDeterministic, isBlocking);



%example event taken

seq = {'none','none','C','s','a_w','w','l','T_hi','a_s', 'none','F','s','a_w','w','l','T_hi','a_s'};  
q='P' %initial state
fprintf('starting in state %s\n', q);

for k=1:numel(seq)

[qn,g]=fsmStep(delta, q, seq{k});
if isempty(g), txt='NO transisition, Ignored'; else, txt = out.(g);
end

 fprintf('%-2s --%-5s/ %-3s--> %-2s  : %s\n', q, seq{k}, g, qn, txt);
 q=qn;
end

[qn,g]=fsmStep(delta,'W','C');
fprintf('\nEvent C while wiping: state stays %s, output ''%s''\n', qn, g);