clear 
close all
Nx = 30; Ny = 30;

[~,~,A] = laplacian([Nx,Ny],{'NN' 'NN'});

xmin = -1; xmax = 1;
ymin = -1; ymax = 1;

xline = linspace(xmin,xmax,Nx);
yline = linspace(ymin,ymax,Ny);

v1 = 5;v2 = 2;

dx = xline(2) - xline(1);
dy = yline(2) - yline(1);

CoefDiff = 0.1;
%A = -(CoefDiff/(dx*dy))*A;
A = -diffusion_matrices(xline,yline,CoefDiff);
V = -advection_matrices(xline,yline,v1,v2);

C = A + V;
%C = A;


idyn = pde('A',C);


idyn.mesh = {xline,yline};

Nt = 50;
idyn.FinalTime  = 0.05;
idyn.dt         = idyn.FinalTime/Nt;

%%
[xms,yms] = meshgrid(xline,yline);

alpha = 0.75*dx;

Y0 = 0*xms;
Nsource = 10;

a = -10;b=10;
kmin =0; kmax = 10;

xminSource =  xmin; xmaxSource = xmax;
yminSource =  ymin; ymaxSource = ymax;

isB = 0;
for is = 1:Nsource
    y0 =  xminSource + (xmaxSource-xminSource).*rand(1,1);
    x0 =  yminSource + (ymaxSource-yminSource).*rand(1,1);
    %x0 = 0.5; y0 = 0.5;
    k  =  normrnd(0.5*kmax,0.1*kmax);
    k = 50;

    Y0   = Y0 + k*exp(-((xms-x0).^2  + (yms-y0).^2)/alpha^2);
    % save Soruces
    Sources(is).x0 = x0;
    Sources(is).y0 = y0;
end

Y0ms = reshape(Y0,Nx*Ny,1); 
idyn.InitialCondition = Y0ms;

[~ ,Y] = solve(idyn);
%%

% figure
% hold on
% line([Sources.x0],[Sources.y0],'Marker','.','LineStyle','none','MarkerSize',8,'Color','k')
% line([BadSources.x0],[BadSources.y0],'Marker','o','LineStyle','none','MarkerSize',10,'Color','k')
% 
% Ysh = reshape(Y(1,:)',Nx,Ny);
% 
% xline_100 = linspace(xmin,xmax,100);
% yline_100 = linspace(ymin,ymax,100);
% 
% [xms_100 ,yms_100] = meshgrid(xline_100,yline_100);
% Ysh_100 = griddata(xms,yms,Ysh,xms_100,yms_100);
% isurf = surf(xms_100,yms_100,Ysh_100);
% shading interp;colormap jet
% caxis([0 0.05*kmax])
% view(0,-90)
% colorbar
% axis('off')
% title('Initial Condition')
%%

figure
hold on
line([Sources.x0],[Sources.y0],'Marker','.','LineStyle','none','MarkerSize',8,'Color','k')
line([Sources.x0],[Sources.y0],'Marker','o','LineStyle','none','MarkerSize',10,'Color','k')

Ysh = reshape(Y(1,:)',Nx,Ny);

xline_100 = linspace(xmin,xmax,100);
yline_100 = linspace(ymin,ymax,100);

[xms_100 ,yms_100] = meshgrid(xline_100,yline_100);
Ysh_100 = griddata(xms,yms,Ysh,xms_100,yms_100);
isurf = surf(xms_100,yms_100,Ysh_100);
shading interp;colormap jet
caxis([0 0.1*kmax])
view(0,-90)
colorbar
axis('off')

%%
pause(0.5)    

for it = 2:length(idyn.tspan)
    Ysh = reshape(Y(it,:)',Nx,Ny);
    Ysh_100 = griddata(xms,yms,Ysh,xms_100,yms_100);
    isurf.ZData =  Ysh_100;
    isurf.Parent.Title.String = "t = " + idyn.tspan(it) ;
    pause(0.01)
end

%5
%error('s')


%%
adjoint = copy(idyn);
adjoint.dt = 2*adjoint.dt
adjoint.A = A - V;
YT = Y(end,:);
Y0_iter = 0.0*Y(1,:)';
Y0_iter_ms = reshape(Y0_iter,Nx,Ny);

%
figure
isurf = surf(xms,yms,Y0_iter_ms);
shading interp;colormap jet
caxis([0 0.1*kmax])
view(0,-90)
colorbar
axis('off')
hold on

LengthStep = 1e-2;
for iter = 1:100
idyn.InitialCondition = Y0_iter;

[~ , Yiter ] = solve(idyn);

adjoint.InitialCondition = Yiter(end,:) - YT;

normPnew = norm(adjoint.InitialCondition)


[~ , Piter ] = solve(adjoint);
Piter = flipud(Piter);

Y0_iter = Y0_iter - LengthStep*Piter(1,:)';
Y0_iter(Y0_iter<0) = 0;
Y0_iter = 0.99*Y0_iter + 0.01*Y(1,:)';


if mod(iter,1) == 0
Y0_iter_ms = reshape(Y0_iter,Nx,Ny);
isurf.ZData =  Y0_iter_ms;
isurf.Parent.Title.String = "Iter = "+iter;
x= xms;y = yms; a = Y0_iter_ms;

lMaxInd = localMaximum(a,1000); 
%lMaxInd = FastPeakFind(a);

%[ypeaks ylocks ] = arrayfun(@(iy) findpeaks(Y0_iter_ms(:,iy)),1:Ny,'UniformOutput',false);
%[xpeaks xlocks ] = arrayfun(@(ix) findpeaks(Y0_iter_ms(ix,:)),1:Nx,'UniformOutput',false);



if exist('pm')
    delete(pm)
end 
pm = plot3(x(lMaxInd),y(lMaxInd),0*a(lMaxInd),'ko','markersize',10,'linewidth',1.5); 

pause(0.01)

end
end


