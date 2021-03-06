% First step of the four-part algorithm in the main loop. It evaluates the
% flux from subsurface problem to free surface flow problem.

%===============================================================================
%> @file
%>
%> @brief First step of the four-part algorithm in the main loop. It evaluates
%>        the flux from subsurface problem to free surface flow problem.
%===============================================================================
%>
%> @brief First step of the four-part algorithm in the main loop.
%>
%> The main loop repeatedly executes four steps until the parameter
%> <tt>problemData.isFinished</tt> becomes <tt>true</tt>.
%> These four steps are:
%>
%>  1. darcy_swe_2dv/preprocessStep.m
%>  2. darcy_swe_2dv/solveStep.m
%>  3. darcy_swe_2dv/postprocessStep.m
%>  4. darcy_swe_2dv/outputStep.m
%> 
%> This routine is executed first in each loop iteration.
%>
%> @param  problemData  A struct with problem parameters, precomputed
%>                      fields, and solution data structures (either filled
%>                      with initial data or the solution from the previous
%>                      loop iteration), as provided by 
%>                      darcy_swe_2dv/configureProblem.m  and 
%>                      darcy_swe_2dv/preprocessProblem.m @f$[\text{struct}]@f$
%> @param  nStep        The current iteration number of the main loop. 
%>
%> @retval problemData  The input struct enriched with preprocessed data
%>                      for this loop iteration. @f$[\text{struct}]@f$
%>
%> This file is part of FESTUNG
%>
%> @copyright 2014-2018 Balthasar Reuter, Florian Frank, Vadym Aizinger
%>
%> @author Balthasar Reuter, 2018
%> 
%> @par License
%> @parblock
%> This program is free software: you can redistribute it and/or modify
%> it under the terms of the GNU General Public License as published by
%> the Free Software Foundation, either version 3 of the License, or
%> (at your option) any later version.
%>
%> This program is distributed in the hope that it will be useful,
%> but WITHOUT ANY WARRANTY; without even the implied warranty of
%> MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%> GNU General Public License for more details.
%>
%> You should have received a copy of the GNU General Public License
%> along with this program.  If not, see <http://www.gnu.org/licenses/>.
%> @endparblock
%
function problemData = preprocessStep(problemData, nStep)
t = (nStep-1) * problemData.darcyData.tau;

if problemData.isCouplingDarcy
  % Reset water height for coupling
  problemData.hCouplingQ0E0T = 0;
end % if

if problemData.isCouplingSWE  % Coupling term for vertical velocity component
  qOrd = problemData.qOrd;
  
  % Upper edge (2) in Darcy problem is coupled to lower edge (1) in SWE problem:
  % Darcy values are evaluated on edge 2 and integrated over edge 1 in SWE grid data.
  [Q, W] = quadRule1D(qOrd);
  [Q1, Q2] = gammaMapQuadri(2, Q);
  
  % Evaluate q1, q2 in quadrature points (K_PM x R arrays)
  K = problemData.darcyData.g.numT;
  N = problemData.darcyData.N;
  q1Disc = reshape(problemData.darcyData.sysY(1 : K*N), N, K)';
  q2Disc = reshape(problemData.darcyData.sysY(K*N+1 : 2*K*N), N, K)';
  q1Q0E0T = q1Disc * problemData.darcyData.basesOnQuad.phi1D{qOrd}(:, :, 2).';
  q2Q0E0T = q2Disc * problemData.darcyData.basesOnQuad.phi1D{qOrd}(:, :, 2).';
  
  % Evaluate D in quadrature points
  if iscell(problemData.darcyData.DCont)
    DQ0E0T = cellfun(@(Kij) Kij(t, problemData.darcyData.g.mapRef2Phy(1, Q1, Q2), problemData.darcyData.g.mapRef2Phy(2, Q1, Q2)), problemData.darcyData.DCont, 'UniformOutput', false);
  else
    DQ0E0T = problemData.darcyData.DCont(t, problemData.darcyData.g.mapRef2Phy(1, Q1, Q2), problemData.darcyData.g.mapRef2Phy(2, Q1, Q2));
  end % if    
  
  % Compute combined values (K_PM x R arrays)
  if iscell(DQ0E0T) && ~isvector(DQ0E0T)
    u1CouplingQ0E0T = DQ0E0T{1,1} .* q1Q0E0T + DQ0E0T{1,2} .* q2Q0E0T;
    u2CouplingQ0E0T = DQ0E0T{2,1} .* q1Q0E0T + DQ0E0T{2,2} .* q2Q0E0T;
  elseif iscell(DQ0E0T)
    u1CouplingQ0E0T = DQ0E0T{1} .* q1Q0E0T;
    u2CouplingQ0E0T = DQ0E0T{2} .* q2Q0E0T;
  else
    u1CouplingQ0E0T = DQ0E0T .* q1Q0E0T;
    u2CouplingQ0E0T = DQ0E0T .* q2Q0E0T;
  end % if
  u1u1CouplingQ0E0T = u1CouplingQ0E0T .* u1CouplingQ0E0T;
  u1u2CouplingQ0E0T = u1CouplingQ0E0T .* u2CouplingQ0E0T;
  
  K = problemData.sweData.g.numT;
  N = problemData.sweData.N;
  markAreaE0T = problemData.sweData.g.markE0TbdrCoupling(:, 1) .* problemData.sweData.g.areaE0T(:, 1);
  
  JuCoupling = bsxfun(@times, markAreaE0T, (problemData.markE0TE0T * u1CouplingQ0E0T) * (repmat(W(:), 1, N) .* problemData.sweData.basesOnQuad2D.phi1D{qOrd}(:, :, 1)));
  problemData.sweData.globJuCoupling{1} = reshape((JuCoupling .* problemData.sweData.g.nuE0T(:, 1, 1)).', K*N, 1);
  problemData.sweData.globJuCoupling{2} = reshape((JuCoupling .* problemData.sweData.g.nuE0T(:, 1, 2)).', K*N, 1);
  problemData.sweData.globJwCoupling = reshape(bsxfun(@times, markAreaE0T .* problemData.sweData.g.nuE0T(:, 1, 2), (problemData.markE0TE0T * u2CouplingQ0E0T) * (repmat(W(:), 1, N) .* problemData.sweData.basesOnQuad2D.phi1D{qOrd}(:, :, 1))).', K*N, 1);
  problemData.sweData.globJuuCoupling{1} = reshape(bsxfun(@times, markAreaE0T .* problemData.sweData.g.nuE0T(:, 1, 1), (problemData.markE0TE0T * u1u1CouplingQ0E0T) * (repmat(W(:), 1, N) .* problemData.sweData.basesOnQuad2D.phi1D{qOrd}(:, :, 1))).', K*N, 1);
  problemData.sweData.globJuuCoupling{2} = reshape(bsxfun(@times, markAreaE0T .* problemData.sweData.g.nuE0T(:, 1, 2), (problemData.markE0TE0T * u1u2CouplingQ0E0T) * (repmat(W(:), 1, N) .* problemData.sweData.basesOnQuad2D.phi1D{qOrd}(:, :, 1))).', K*N, 1);
end % if
end % function
