function A = FEFractionalLaplacian(s,L,N)
% description: Compute the rigidity matrix for solving the Poisson problem
%                   $$(-\Delta)^s u = F  \ \in (-L,L)$$
%                   where $u=0, \in R(-L,L)$ using linear finite elements on a mesh of N points
% autor: UmbertoB
% MandatoryInputs:   
%   s: 
%       name: fractrio
%       d: [1x1]
%       class: ControlProblem
%       dimension: [1x1]
% OptionalInputs:
%   U0:
%       name: Initial Control 
%       description: matrix 
%       class: double
%       dimension: [length(iCP.tline)]
%       default:   empty
% Outputs:
%   A:
%       name: Mass Matrix of Fractional Laplacian
%       description: Mass Matrix of Fractional Laplacian
%       dimension: [NxN]
%       class:  double


x = linspace(-L,L,N+2);
x = x(2:end-1);
h = x(2)-x(1);
A = zeros(N,N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Normalization constant of the fractional Laplacian
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

c = (s*2^(2*s-1)*gamma(0.5*(1+2*s)))/(sqrt(pi)*gamma(1-s));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Elements A(i,j) with |j-i|>1
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:N-2
    for j=i+2:N
        k = j-i;
        if s==0.5 && k==2
                A(i,j) = 56*log(2)-36*log(3);           
        elseif s==0.5 && k~=2
            A(i,j) = -(4*((k+1)^2)*log(k+1)+4*((k-1)^2)*log(k-1)...
                -6*(k^2)*log(k)-((k+2)^2)*log(k+2)-((k-2)^2)*log(k-2));
        else
            P = 1/(4*s*(1-2*s)*(1-s)*(3-2*s));
            q = 3-2*s;
            B = P*(4*(k+1)^q+4*(k-1)^q-6*k^q-(k-2)^q-(k+2)^q);
            A(i,j) = -2*h^(1-2*s)*B;
        end       
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Elements of A(i,j) with j=1+1 ----- upper diagonal
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:N-1
    if s==0.5
       A(i,i+1) = 9*log(3)-16*log(2);
    else 
       A(i,i+1) = h^(1-2*s)*((3^(3-2*s)-2^(5-2*s)+7)/(2*s*(1-2*s)*(1-s)*(3-2*s))); 
    end    
end

A = A+A';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Elements on the diagonal
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:N
    if s==0.5
       A(i,i) = 8*log(2);
    else 
       A(i,i) = h^(1-2*s)*((2^(3-2*s)-4)/(s*(1-2*s)*(1-s)*(3-2*s)));
    end
end

A = c*A; 
