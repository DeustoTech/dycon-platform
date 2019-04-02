function GetSymbolicalGradient(iP)
% description: Creates the iCP.dH_du property that contains a numeric function that 
%               returns the value of the gradient given the dynamics solution, 
%               $Y$ and the associated control, $U$.
% little_description: Creates the iCP.dH_du property that contains a numeric function that 
%               returns the value of the gradient given the dynamics solution, 
%               $Y$ and the associated control, $U$. 
% autor: JOroya
% MandatoryInputs:   
%  iCP: 
%    name: Control Problem
%    description: 
%    class: ControlProblem
%    dimension: [1x1]
    syms t
    %%
    iode   = iP.ode;
    L   = iP.J.L.Symbolic; 
    %% Creamos las variables simbolica 
    symU   = iode.Control.Symbolic;
    % Obtenemos el vector Symbolico Y = [y1 y2 y3 ...]^T
    symY   = iode.StateVector.Symbolic;
    % Creamos el vector Symbolico   P = [p1 p2 p3 ...]
    
    symP  =  sym('p', [length(symY),1]);
    if iP.ode.lineal    
        dH_du =(iode.B.'*symP).' + gradient(formula(L),symU).';
        dH_du = dH_du.';
    else
        dH_du = gradient(formula(iP.hamiltonian),symU).';
    end
    %
    iP.gradient.sym = symfun(dH_du,[t symY.' symP.' symU.']);
    % Pasamos esta funcion a una function_handle
    iP.gradient.num = matlabFunction(dH_du,'Vars',{t,symY,symP,symU});
            

end