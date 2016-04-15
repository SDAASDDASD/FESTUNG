function problemData = preprocessProblem(problemData)
%% Triangulation.
problemData.g = domainSquare(problemData.hmax); 
% Alternative: problemData.g = domainPolygon([0 1 1 0], [0 0 1 1], problemData.hmax);
if problemData.isVisGrid,  visualizeGrid(problemData.g);  end
%% Globally constant parameters.
problemData.K           = problemData.g.numT;  % number of triangles
problemData.N           = nchoosek(problemData.p + 2, problemData.p); % number of local DOFs
problemData.tau         = problemData.tEnd / problemData.numSteps;  % time step size

problemData.g.markE0Tint  = problemData.g.idE0T == 0;        % [K x 3] mark local edges that are interior
problemData.g.markE0TbdrD = ~problemData.g.markE0Tint;       % [K x 3] mark local edges on the Dirichlet boundary
problemData.g.markV0TbdrD = ismember(problemData.g.V0T, ...  % [K x 3] mark local vertices on the Dirichlet boundary
                            problemData.g.V0E(problemData.g.E0T(problemData.g.markE0TbdrD),:)); 
problemData.g = computeDerivedGridData(problemData.g);       % Precompute some repeatedly evaluated fields
%% Lookup table for basis function.
computeBasesOnQuad(problemData.N);
if problemData.isSlopeLim
  computeTaylorBasesV0T(problemData.g, problemData.N);
end % if
%% Computation of matrices on the reference triangle.
problemData.hatM              = integrateRefElemPhiPhi(problemData.N);
problemData.hatG              = integrateRefElemDphiPhiPhi(problemData.N);
problemData.hatRdiagOnQuad    = integrateRefEdgePhiIntPhiIntPerQuad(problemData.N);
problemData.hatRoffdiagOnQuad = integrateRefEdgePhiIntPhiExtPerQuad(problemData.N);
%% Assembly of time-independent global matrices.
problemData.globM = assembleMatElemPhiPhi(problemData.g, problemData.hatM);
if problemData.isSlopeLim
  globMTaylor = assembleMatElemPhiTaylorPhiTaylor(problemData.g, problemData.N);
  problemData.globMDiscTaylor = assembleMatElemPhiDiscPhiTaylor(problemData.g, problemData.N);
  problemData.globMCorr = spdiags(1./diag(globMTaylor), 0, problemData.K * problemData.N, problemData.K * problemData.N) * globMTaylor;
end % if
end % function