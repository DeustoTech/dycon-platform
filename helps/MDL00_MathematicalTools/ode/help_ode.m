%%
% Let's see an example of using class ode. For this we will solve a simple example.
%%
% $$ \begin{bmatrix}
% \dot{y}_1 \\
% \dot{y}_2
% \end{bmatrix} = \left(\begin{array}{c} u_{1}+\sin\left(y_{1}\,y_{2}\right)+y_{1}\,y_{2}\\ u_{2}+y_{2}+\cos\left(y_{1}\,y_{2}\right) \end{array}\right)
% $$
%%
% $$ y_1(1) = 1 / / y_2(1) = -1 $$
%%
Y = sym('y',[2 1]);
U = sym('u',[2 1]);
%%
% with these two variables, we can define the equation of the dynamics of the following form
%%
F = [ sin(Y(1)*Y(2)) +    (Y(1)*Y(2)) + U(1)   ; ...
         Y(2)        + cos(Y(1)*Y(2)) + U(2) ] ;
%
dynamics = ode(F,Y,U);
dynamics.Condition = [1,-1];
dynamics
%% 
% You can solve the equations with a single sentence 
solve(dynamics)
plot(dynamics)
%%
% Create final condition problems, choosing the solver
dynamics.Type = 'FinalCondition';
solve(dynamics,'RKMethod',@ode23)
plot(dynamics)
%% 
% other than a simpler interface for linear problems
A = [ -1 0 ; 0 -1];
B = [1 ; 1];
%%
dynamics = ode('A',A,'B',B);
dynamics.Condition = [1,-1];
solve(dynamics)
plot(dynamics)
%% 
% You can see mode in own tutorials