function ulr= volts(t, ref,p)

%calculating ux,uv by ul, ur
[ux, ~] = invAxis(ref.x(t), p.ax, p);
[uy, ~] = invAxis(ref.y(t), p.ay, p);

ulr = [(ux+uy)/2; (ux-uy)/2];

end
