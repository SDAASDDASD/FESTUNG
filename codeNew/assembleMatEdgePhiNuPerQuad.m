function [retDiag, retOffdiag] = assembleMatEdgePhiNuPerQuad(g, markE0Tint, refEdgePhiIntPerQuad)
K = g.numT;
retDiag = cell(3,2); retOffdiag = cell(3,3,2);
for nn = 1 : 3
	for np = 1 : 3
		if isfield(g, 'areaNuE0TE0T')
			retOffdiag{nn,np,1} = 0.5 * kron(g.areaNuE0TE0T{nn,np,1}, refEdgePhiIntPerQuad(:,:,nn));
			retOffdiag{nn,np,2} = 0.5 * kron(g.areaNuE0TE0T{nn,np,2}, refEdgePhiIntPerQuad(:,:,nn));
		else
			retOffdiag{nn,np,1} = 0.5 * kron(bsxfun(@times,g.markE0TE0T{nn,np}, g.areaE0T(:,nn) .* g.nuE0T(:,nn,1)), refEdgePhiIntPerQuad(:,:,nn));
			retOffdiag{nn,np,2} = 0.5 * kron(bsxfun(@times,g.markE0TE0T{nn,np}, g.areaE0T(:,nn) .* g.nuE0T(:,nn,2)), refEdgePhiIntPerQuad(:,:,nn));
		end % if
	end % for
	if isfield(g, 'areaNuE0Tint')
		retDiag{nn,1} = 0.5 * kron(spdiags(g.areaNuE0Tint{nn,1}, 0, K, K), refEdgePhiIntPerQuad(:,:,nn));
		retDiag{nn,2} = 0.5 * kron(spdiags(g.areaNuE0Tint{nn,2}, 0, K, K), refEdgePhiIntPerQuad(:,:,nn));
	else
		retDiag{nn,1} = 0.5 * kron(spdiags(g.areaE0T(:,nn) .* g.nuE0T(:,nn,1) .* markE0Tint(:,nn), 0, K, K), refEdgePhiIntPerQuad(:,:,nn));
		retDiag{nn,2} = 0.5 * kron(spdiags(g.areaE0T(:,nn) .* g.nuE0T(:,nn,2) .* markE0Tint(:,nn), 0, K, K), refEdgePhiIntPerQuad(:,:,nn));
	end % if
end % for
end % function