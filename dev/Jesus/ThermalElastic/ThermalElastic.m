%% Wave Equation on Square Domain
% This example shows how to solve the wave equation using the |solvepde|
% function.

% Copyright 1994-2015 The MathWorks, Inc.
%% Problem Definition
%
% The standard second-order wave equation is
% 
% $$ \frac{\partial^2 u}{\partial t^2} - \nabla\cdot\nabla u = 0.$$
%
% To express this in toolbox form, note that the |solvepde| function
% solves problems of the form
%
% $$ m\frac{\partial^2 u}{\partial t^2} - \nabla\cdot(c\nabla u) + au =
% f.$$
%
% So the standard wave equation has coefficients $m = 1$, $c = 1$, $a = 0$,
% and $f = 0$.
c = 1;
a = 0;
m = 1;

%% Geometry
% Solve the problem on a square domain. The |squareg| function describes
% this geometry. Create a |model| object and include the geometry. Plot the
% geometry and view the edge labels.
numberOfPDE = 1;
model = createpde(numberOfPDE);
geometryFromEdges(model,@circleg);
pdegplot(model,'EdgeLabels','on'); 
ylim([-1.1 1.1]);
axis equal
title 'Geometry With Edge Labels Displayed';
xlabel x
ylabel y

%% Specify PDE Coefficients
specifyCoefficients(model,'m',0.001*m,'d',0.001*eye(385),'c',c,'a',a,'f',@source); % HMax 0.2
%specifyCoefficients(model,'m',m,'d',0.05*eye(1453),'c',c,'a',a,'f',@source); % Hmax 0.1
%specifyCoefficients(model,'m',m,'d',0.01*eye(5849),'c',c,'a',a,'f',@source);
%specifyCoefficients(model,'m',m,'d',0.01*eye(9273),'c',c,'a',a,'f',@source);

%% Boundary Conditions
% Set zero Dirichlet boundary conditions on the left (edge 4) and right (edge
% 2) and zero Neumann boundary conditions on the top (edge 1) and bottom
% (edge 3).
applyBoundaryCondition(model,'dirichlet','Edge',1:model.Geometry.NumEdges,'u',0);
% applyBoundaryCondition(model,'dirichlet','Edge',[2,4],'u',0);
% applyBoundaryCondition(model,'dirichlet','Edge',[1,3],'u',0);

%applyBoundaryCondition(model,'neumann','Edge',([1 3]),'g',0);

%% Generate Mesh
% Create and view a finite element mesh for the problem.
%generateMesh(model,'Hmax',0.1);
generateMesh(model,'Hmax',0.2);

figure
pdemesh(model);
ylim([-1.1 1.1]);
axis equal
xlabel x
ylabel y

%% Create Initial Conditions
% The initial conditions:
%
% * $u(x,0) = \arctan\left(\cos\left(\frac{\pi x}{2}\right)\right)$.
% * $\left.\frac{\partial u}{\partial t}\right|_{t = 0} = 3\sin(\pi x)
% \exp\left(\sin\left(\frac{\pi y}{2}\right)\right)$.
%
% This choice avoids putting energy into the higher vibration modes
% and permits a reasonable time step size.

u0 = @(location) 0*atan(cos(pi/2*location.x));
ut0 = @(location) 0*sin(pi*location.x).*exp(sin(pi/2*location.y));
setInitialConditions(model,u0,ut0);

%% Define Solution Times
% Find the solution at 31 equally-spaced points in time from 0 to 5.
n = 20;
FinalTime = 20;
tlist = linspace(0,FinalTime,n);

%% Calculate the Solution 
% Set the |SolverOptions.ReportStatistics| of |model| to |'on'|.
model.SolverOptions.ReportStatistics ='on';
result = solvepde(model,tlist);
u = result.NodalSolution;

%% Animate the Solution
% Plot the solution for all times. Keep a fixed vertical scale by first
% calculating the maximum and minimum values of |u| over all times, and
% scale all plots to use those $z$-axis limits.
fig = figure;

umax = max(max(u));
umin = min(min(u));

tspan_fine = linspace(tlist(1),tlist(end),200);

uinterp = interp1(tlist,u',tspan_fine);
uinterp = uinterp';

ang = 20;
for i = 1:length(tspan_fine)
    pt = pdeplot(model,'XYData',uinterp(:,i),'ZData',uinterp(:,i), ...
                  'Mesh','off','ColorBar','off');
    lightangle(pt.Parent,40,40)
    daspect([1 1 0.2])
    axis(pt.Parent,'off')
    
%     axis([-1 1 -1 1 umin umax]); 
    caxis([umin umax]);
    zlim([umin umax])
    xlabel x
    ylabel y
    zlabel u
    percen = tspan_fine(i)/FinalTime;
    title(num2str(percen,'.%.2f')+"%")
    %if percen < 0.5
    ang = ang + 0.5;
    %end
   view(ang,25) 

    pause(0.01)
end
%%

%%
% To play the animation, use the |movie(M)| command.
function value = source(domain,state)

    r2 = domain.x.^2 + domain.y.^2;
    theta = atan2(domain.y,domain.x);
    
    r  = sqrt(r2);
    alpha = 0.2;
    
    value = 30*(exp(-2*pi*((r-0.7).^2/(alpha)^2)/0.5) - 0.05);
    %value = 30*cos(-2*pi*(r2)).*(1./(r2+0.01));

    FinalTime = 20;
    k = 500;

   % value = value-1e5*(state.u.*(1+exp(-2*k*(state.u-0.4))).^-1).*(1+exp(-2*k*(state.time-0.95*FinalTime)));
   
   alphatime = 0.1*FinalTime;
   zplane = 0.3 - 0.25*exp(-((state.time-0.6*FinalTime)/alphatime).^2) + 0.2*sin(3*theta).^2;
   
   value = value-1e8*(state.u.*(1+exp(-2*k*(state.u-  zplane))).^-1);
end


