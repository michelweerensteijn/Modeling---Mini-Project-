function [A,B] = fullModel(p)
%from q1.2 states

C1=p.C1;
C2=p.C2;
C3=p.C3;
Mm=p.Mm;

A= [0 0 1 0 0 0;
      0 0 0 1 0 0;
      0 0 -(C1+C3)/Mm -C2/Mm p.Km/Mm 0;
      0 0 -C2/Mm -(C1+C3)/Mm 0 p.Km/Mm;
      0 0 -p.Km/p.Lm 0 -p.Rm/p.Lm 0;
      0 0 0 -p.Km/p.Lm 0 -p.Rm/p.Lm];

B= [0 0;
    0 0;
    0 0;
    0 0;
    1/p.Lm 0;
    0 1/p.Lm;]

end
