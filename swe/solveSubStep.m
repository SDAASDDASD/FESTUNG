function pd = solveSubStep(pd, ~, nSubStep)
K = pd.K;
N = pd.N;
dt = pd.dt;

% Compute height from potentially different approximation orders:
% zbDiscLin is always linear (N=3) while cDisc(:,:,1) can be of any
% approximation order
hDisc = computeSumDataDiscDataDisc(pd.cDisc(:,:,1), -pd.zbDiscLin);

% Build right hand side vector
sysV = cell2mat(pd.globL) - cell2mat(pd.globLRI) - ...
       [ sparse(K*N,1); pd.nonlinearTerms + pd.bottomFrictionTerms] - ... 
       pd.riemannTerms;

% Compute solution at next time step using explicit or semi-implicit scheme
switch pd.schemeType
  case 'explicit'
    sysA = [ sparse(K*N,K*max(N,3)); pd.tidalTerms{1}; pd.tidalTerms{2} ];
    cDiscDot = pd.sysW \ (sysV - pd.linearTerms * pd.cDiscRK + sysA * hDisc );
    pd.cDiscRK = pd.omega(nSubStep) * pd.cDiscRK0 + (1 - pd.omega(nSubStep)) * (pd.cDiscRK + dt * cDiscDot);

  case 'semi-implicit'
    sysA = [ sparse(K*N,3*K*N); pd.tidalTerms{1}, sparse(K*N,2*K*N); pd.tidalTerms{2}, sparse(K*N,2*K*N) ];
    pd.cDiscRK = (pd.sysW + dt * (pd.linearTerms - sysA)) \ (pd.sysW * pd.cDiscRK + dt * sysV);
          
  otherwise
    error('Invalid time-stepping scheme')
end % switch
end % function