function [u,iq]= invAxis(R,a,p)

%using the inverted dynamics needed in Q1.3 
% for i and u

iq  = (R(3,:) + a*R(2,:))/p.b;
diq = (R(4,:) + a*R(3,:))/p.b;
u   = p.Lm*diq + p.Rm*iq + (2*p.Km/p.rm)*R(2,:);

end
