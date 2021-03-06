% Third step of the four-part algorithm in the main loop.

%===============================================================================
%> @file
%>
%> @brief Third step of the four-part algorithm in the main loop.
%===============================================================================
%>
%> @brief Third step of the four-part algorithm in the main loop.
%>
%> The main loop repeatedly executes four steps until the parameter
%> <code>problemData.isFinished</code> becomes <code>true</code>.
%> These four steps are:
%>
%>  1. darcy_2dv/preprocessStep.m
%>  2. darcy_2dv/solveStep.m
%>  3. darcy_2dv/postprocessStep.m
%>  4. darcy_2dv/outputStep.m
%> 
%> This routine is executed third in each loop iteration.
%> It decides whether the main loop is to be terminated (i.e., the
%> end of the simulation time is reached).
%> It also terminates the main loop if the problem is marked to be stationary.
%>
%> @param  problemData  A struct with problem parameters and precomputed
%>                      fields (either filled with initial data or the solution
%>                      from the previous loop iteration), as provided by 
%>                      darcy_2dv/configureProblem.m and 
%>                      darcy_2dv/preprocessProblem.m. @f$[\text{struct}]@f$
%> @param  nStep        The current iteration number of the main loop. 
%>
%> @retval problemData  The input struct enriched with post-processed data
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
function problemData = postprocessStep(problemData, nStep)
problemData.isFinished = problemData.isStationary || nStep >= problemData.numSteps;
end % function

