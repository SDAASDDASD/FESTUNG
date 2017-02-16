%
function ret = assembleVecEdgeMuFuncContVal(g, markE0Tbdr, funcCont, Nlambda, basesOnGamma )

KEdge = g.numE;

% Determine quadrature rule
p = Nlambda - 1;
qOrd = 2*p+1;
[Q, W] = quadRule1D(qOrd);

ret = zeros(KEdge, Nlambda);
Q2X1 = @(X1,X2) g.B(:,1,1)*X1 + g.B(:,1,2)*X2 + g.coordV0T(:,1,1)*ones(size(X1));
Q2X2 = @(X1,X2) g.B(:,2,1)*X1 + g.B(:,2,2)*X2 + g.coordV0T(:,1,2)*ones(size(X1));
for n = 1 : 3
    [Q1, Q2] = gammaMap(n, Q);
    funcOnQuad = funcCont(Q2X1(Q1, Q2), Q2X2(Q1, Q2));
    Kkn = markE0Tbdr(:, n) .* g.areaE0T(:,n);
    ret(g.E0T(:, n),:) = ret(g.E0T(:, n),:) + Kkn .* funcOnQuad * ( W' .* basesOnGamma.phi1D{qOrd}(:,:) );
end
ret = reshape(ret',KEdge*Nlambda,1);
end

