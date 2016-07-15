% Computes various additional fields needed throughout the advection
% problem presented in @ref RAWFK2016 . These fields only contain
% information based on the underlying grid and are therefore constant in
% time but used in every step. They are saved as part of the grid.

%===============================================================================
%> @file computeDerivedGridData.m
%>
%> @brief Computes various additional fields needed throughout the advection
%>        problem presented in @ref RAWFK2016 . These fields only contain
%>        information based on the underlying grid and are therefore constant in
%>        time but used in every step. They are saved as part of the grid.
%===============================================================================
%>
%> @brief Computes various additional fields needed throughout the advection
%>        problem presented in @ref RAWFK2016 . These fields only contain
%>        information based on the underlying grid and are therefore constant in
%>        time but used in every step. They are saved as part of the grid.
%>
%> For every vertex of a triangle the columns of g.markV0TT0V indicate which triangle 
%> corresponds to this vertex.
%>
%> g.areaE0TbdrD provides the elementwise products of the vectors 
%> <code>g.areaE0T</code>, and <code>markE0TbdrD</code>.
%> @f$[3 \text{ cell}]@f$
%>
%> @param  g          The lists describing the geometric and topological 
%>                    properties of a triangulation (see 
%>                    <code>generateGridData()</code>) 
%>                    @f$[1 \times 1 \text{ struct}]@f$
%> @retval g          The lists describing the geometric and topological 
%>                    properties of a triangulation (see 
%>                    <code>generateGridData()</code>) 
%>                    @f$[1 \times 1 \text{ struct}]@f$
%>
%> This file is part of FESTUNG
%>
%> @copyright 2014-2015 Hennes Hajduk, Florian Frank, Balthasar Reuter, Vadym Aizinger
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
function g = computeDerivedGridData(g)
g.markV0TT0V = cell(3, 1);
g.areaE0TbdrD = cell(3, 1);
g.areaE0TbdrN = g.markE0TbdrN .* g.areaE0T;
for n = 1 : 3
  % Mark all elements sharing i-th vertex
  g.markV0TT0V{n} = g.markV0TV0T{n, 1} | g.markV0TV0T{n, 2} | g.markV0TV0T{n, 3}; 
  % Fix a bug in GNU Octave 4.0.0's implementation of sparse matrix concatenation
  if exist('OCTAVE_VERSION','builtin')
    g.markV0TT0V{n} = g.markV0TT0V{n} + 0 * speye(size(g.markV0TT0V{n}, 1), size(g.markV0TT0V{n}, 2));
  end % if
  g.areaE0TbdrD{n} = g.areaE0T(:,n) .* g.markE0TbdrD(:, n);
end % for
end % function