function problemData = solveSubStep(problemData, ~, nSubStep)
K = problemData.K;
N = problemData.N;

% Assembly of time-dependent global matrices
globG = assembleMatElemDphiPhiFuncDiscVec(problemData.g, problemData.hatG, problemData.u1Disc, problemData.u2Disc);
globR = assembleMatEdgePhiPhiValUpwind(problemData.g, problemData.hatRdiagOnQuad, ...
                                         problemData.hatRoffdiagOnQuad,  problemData.vNormalOnQuadEdge);
% Building the system
sysA = -globG{1} - globG{2} + globR;

for species = 1:problemData.numSpecies
  % L2 projections of algebraic coefficients
  fDisc  = projectFuncCont2DataDisc(problemData.g, @(x1,x2) problemData.fCont{species}(problemData.timeLvls(nSubStep),x1,x2), ...
                                    2*problemData.p, problemData.hatM, problemData.basesOnQuad);

  % Assembly of Dirichlet boundary contributions
  globKD = assembleVecEdgePhiIntFuncContVal(problemData.g, problemData.g.markE0TbdrD, ...
            @(x1,x2) problemData.cDCont{species}(problemData.timeLvls(nSubStep),x1,x2),  problemData.vNormalOnQuadEdge, N, ...
            problemData.basesOnQuad, problemData.g.areaE0TbdrD);

  % Assembly of Neumann boundary contributions
  gNUpwind = @(x1,x2) (problemData.gNCont{species}(problemData.timeLvls(nSubStep),x1,x2) <= 0) .* problemData.gNCont{species}(problemData.timeLvls(nSubStep),x1,x2);
  globKN = assembleVecEdgePhiIntFuncCont(problemData.g, problemData.g.markE0TbdrN, ...
            gNUpwind, N, problemData.basesOnQuad);

  % Assembly of the source contribution
  globL = problemData.globM * reshape(fDisc', K*N, 1);

  % right hand side
  sysV = globL - globKD - globKN;

  % Computing the discrete time derivative
  cDiscDot = problemData.globM \ (sysV - sysA * problemData.cDiscRK{nSubStep, species});

  % Apply slope limiting to time derivative
  if problemData.isSlopeLim{species}
    cDiscDotTaylor = projectDataDisc2DataTaylor(reshape(cDiscDot, [N K])', problemData.globM, problemData.globMDiscTaylor);
    cDiscDotTaylorLim = applySlopeLimiterTaylor(problemData.g, cDiscDotTaylor, problemData.g.markV0TbdrD, NaN(K,3), problemData.basesOnQuad, problemData.typeSlopeLim{species});
    cDiscDotTaylor = reshape(cDiscDotTaylorLim', [K*N 1]) + problemData.globMCorr * reshape((cDiscDotTaylor - cDiscDotTaylorLim)', [K*N 1]);
    cDiscDot = reshape(projectDataTaylor2DataDisc(reshape(cDiscDotTaylor, [N K])', problemData.globM, problemData.globMDiscTaylor)', [K*N 1]);
  end % if

  % Compute next step
  problemData.cDiscRK{nSubStep + 1, species} = problemData.omega(nSubStep) * problemData.cDiscRK{1, species} + (1 - problemData.omega(nSubStep)) * (problemData.cDiscRK{nSubStep, species} + problemData.tau * cDiscDot);

  % Limiting the solution
  if problemData.isSlopeLim{species}
    cDV0T = computeFuncContV0T(problemData.g, @(x1, x2) problemData.cDCont{species}(problemData.timeLvls(nSubStep), x1, x2));
    problemData.cDiscRK{nSubStep + 1, species} = reshape(applySlopeLimiterDisc(problemData.g, reshape(problemData.cDiscRK{nSubStep + 1, species}, [N K])', problemData.g.markV0TbdrD, ...
                            cDV0T, problemData.globM, problemData.globMDiscTaylor, problemData.basesOnQuad, problemData.typeSlopeLim{species})', [K*N 1]);
  end % if
end % for

end % function