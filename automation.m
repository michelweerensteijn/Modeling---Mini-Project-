clc;
clear all;

%transition rows=states, columns=i/p symbols

symbols = {'H+','H0','V+','V0'};
states  = {'q0','qB','qL','qP'};

delta = { 'q0', 'qL', 'q0', 'qB';     % from q0
          'qB', 'qP', 'q0', 'qB';     % from qB
          'q0', 'qL', 'qL', 'qP';     % from qL
          'qB', 'qP', 'qL', 'qP' };   % from qP
Q0 = 'q0';      % initial state
QF = {'qP'};    % accepting state


isDeterministic=all(cellfun(@ischar, delta(:)));
isComplete= ~any(cellfun(@isempty, delta(:)));
fprintf('Deterministic :%d, complete: %d\n\n', isDeterministic,isComplete);

%trying the automation sequence

tests={{'H+','V+','H+','H0','V+','V0'}, %question (goes to side horizontally, then goes down vertically)
    {'V+', 'V+', 'V0', 'H+', 'H+', 'H0'}, %goes down vertically, then left
    {'H+','H0','V+','V+'},%keeps going down, not parked 
     {'V0','H+','H+'}, %keeps going left, not parked
     {'H0','V0','H+'}};

for k=1:numel(tests)
    [acc,path]=runAutomation(tests{k}, symbols, states, delta, Q0, QF);
    fprintf('sigma=%-28s states: %-26s -> %s\n',strjoin(tests{k}, ''), ...
        strjoin(path, ''),ternary(acc, 'ACCEPT(parked state)', 'reject (non-parked state)'));
end



function[acc,path]=runAutomation(seq, symbols,states,delta, Q0,QF)

%input sequentially
q=Q0; 
path={q};

for k=1:numel(seq)
    i=find(strcmp(states, q));
    j=find(strcmp(symbols, seq{k}));
    q=delta{i,j};
    path{end+1}=q;
end
acc=any(strcmp(QF, q));
end

function out=ternary(c, a,b)
if c, out=a; 
else, out=b;
end
end

