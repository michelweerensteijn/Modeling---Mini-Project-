function R= harmK(t,c0, a, b, k, w)

%position, velocity, acceleration, jerk

t=t(:).';
R=zeros(4, numel(t)); 
R(1,:)=c0;

for j = 1:numel(k)
    W = k(j)*w;  C = cos(W*t);  S = sin(W*t);
    R(1,:) = R(1,:) + a(j)*C        + b(j)*S;
    R(2,:) = R(2,:) - a(j)*W*S      + b(j)*W*C;
    R(3,:) = R(3,:) - a(j)*W^2*C    - b(j)*W^2*S;
    R(4,:) = R(4,:) + a(j)*W^3*S    - b(j)*W^3*C;

end
end
