% will multiply an array of size m*n*t by an array of size n*k*t
% where t changes from tmin to tmax. N is a number of times calculations
% are repeated.

function testMatVector(m, n, k, tmin, tmax, N)

if nargin < 6
    N = 10;
end

if nargin < 5
    tmax = tmin;
end

import gras.gen.MatVector;

t1Vec = zeros(1,tmax-tmin+1);
t2Vec = zeros(1,tmax-tmin+1);

aDataCVec = cell(1,N);
bDataCVec = cell(1,N);
for i = 1:N
    aDataCVec{i} = rand(m,n,tmax);
    bDataCVec{i} = rand(n,k,tmax);
end

for t = tmin:tmax
    
    aCVec = cell(1,N);
    bCVec = cell(1,N);
    cCVec = cell(1,N);
    dCVec = cell(1,N);
    
    for i = 1:N
        aCVec{i} = aDataCVec{i}(:,:,1:t-tmin+1);
        bCVec{i} = bDataCVec{i}(:,:,1:t-tmin+1);
    end
    
    tic;
    for i = 1:N
        cCVec{i} = MatVector.rMultiply(aCVec{i}, bCVec{i});
    end
    t1Vec(t-tmin+1) = toc/N;
    
    tic;
    for i = 1:N;
        dCVec{i} = MatVector.rMultiply2(aCVec{i}, bCVec{i});
    end
    t2Vec(t-tmin+1) = toc/N;
    
    for i = 1:N
        tArray = cCVec{i} - dCVec{i};
        d = max(abs(tArray(:)));
        if( d > 1e-15 )
            error(['precision error: ', num2str(d)]);
        end
    end
    
end

if( tmax > tmin )
    figure; axes; hold on;
    
    plot(tmin:tmax, t1Vec, 'ro');
    plot(tmin:tmax, t2Vec, 'bo');
    ylim([0, 1.2*max([t1Vec,t2Vec])]);
    
    title(sprintf('results for arrays of size %dx%dxT and %dx%dxT', m, n, n, k))
    xlabel('T')
    legend('old method', 'new method');
end

end