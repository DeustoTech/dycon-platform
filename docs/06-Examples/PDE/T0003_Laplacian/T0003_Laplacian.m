%% Parametros de discretizacion
N = 30;
xi = -1; xf = 1;
xline = linspace(xi,xf,N+2);
xline = xline(2:end-1);
dx = xline(2) - xline(1);
%% Creamos el ODE 
A = FDLaplacian(xline);
%%%%%%%%%%%%%%%%  
a = -0.5; b = 0.5;
B = BInterior(xline,a,b,'min',false);
%%%%%%%%%%%%%%%%
FinalTime = 0.4;
dt = 0.001;
Y0 =sin(0.5*pi*xline');

dynamics = pde('A',A,'B',B,'InitialCondition',Y0,'FinalTime',FinalTime,'Nt',100);
dynamics.mesh{1}= xline;
%% Creamos Problema de Control
Y = dynamics.StateVector.Symbolic;
U = dynamics.Control.Symbolic;

YT = 0*cos(0.5*pi*xline');
epsilon = dx^5;
symPsi  = @(T,Y)   dx*(1/(2*epsilon))*(YT - Y).'*(YT - Y);
symL    = @(t,Y,U) dx*sum(abs(U));

iCP1 = Pontryagin(dynamics,symPsi,symL);
%%
iCP1.Target = YT;
%% Solve Gradient
tol = 1e-5;
%
U0 = zeros(iCP1.Dynamics.Nt,iCP1.Dynamics.ControlDimension);
[UOptDyCon,JOptDycon] = GradientMethod(iCP1,U0,'tol',tol,'Graphs',false,'DescentAlgorithm',@ConjugateDescent,'MaxIter',300,'display','all')
%% fmincon
options = optimoptions(@fminunc,'display','iter','SpecifyObjectiveGradient',true);
UoptFminCon = fminunc(@(U) Control2Functional(iCP1,U),U0,options);

%%
DynFminCon = copy(iCP1.Dynamics);
DynFminCon.label = 'Dycon Toolbox';
solve(DynFminCon,'Control',UoptFminCon)
%%
DynDyCon = copy(iCP1.Dynamics);
solve(DynDyCon,'Control',UOptDyCon)
DynDyCon.label = 'MATLAB - fmincon';
%%
solve(iCP1.Dynamics,'Control',U0)
iCP1.Dynamics.label = 'Free Dynamics';

%%
animation([DynFminCon DynDyCon, iCP1.Dynamics],'YLim',[-0.3 0.3],'YLimControl',[-50 50],'xx',0.025,'Target',YT)