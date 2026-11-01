function [qn,g]=fsmStep(delta,q,sigma)

%every step is measured

idx=find(strcmp(delta(:,1),q)&strcmp(delta(:,2),sigma),1);
if isempty(idx)
    qn=q;
    g=''; %shows if undefined

else
    qn=delta{idx, 3};
    g=delta{idx, 4};
end
end
