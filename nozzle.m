function dx= nozzle(x,u,n)
%x=[Tn;iL;vc], u=u_n
Tn=x(1); 
iL=x(2);
vc=x(3);

W_in=vc^2/n.Rn;
W_out=(Tn-n.Te)/n.Rtn;

dx=[(W_in- W_out)/n.Ctn;
    (u-vc)/n.Ln;
    (iL-vc/n.Rn)/n.Cn];
end

