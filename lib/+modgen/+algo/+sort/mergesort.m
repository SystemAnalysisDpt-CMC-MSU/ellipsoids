function [x,indVec] = mergesort(x)
%--------------------------------------------------------------------------
% Syntax:       sx = mergesort(x);
%
% Inputs:       x is a vector of length n
%
% Outputs:      sx is the sorted (ascending) version of x
%
% Description:  This function sorts the input array x in ascending order
%               using the mergesort algorithm
%
% Complexity:   O(n * log(n))    best-case performance
%               O(n * log(n))    average-case performance
%               O(n * log(n))    worst-case performance
%               O(n)             auxiliary space
%
% Author:       Brian Moore
%               brimoor@umich.edu
%
% Date:         January 5, 2014
%--------------------------------------------------------------------------

% Knobs
kk = 15; % Insertion sort threshold, k >= 1

% Mergesort
n = length(x);
[x,indVec] = mergesorti(x,1,n,kk);

end

function [x,indVec] = mergesorti(x,ll,uu,kk)
% Sort x(ll:uu) via merge sort
% Note: In practice, x xhould be passed by reference
indVec=1:numel(x);
if iscolumn(x)
    indVec=indVec.';
end
%
% Compute center index
mm = floor((ll + uu) / 2);

% Divide...
if ((mm + 1 - ll) <= kk)
    % Sort x(ll:mm) via insertion sort
    x = insertionsorti(x,ll,mm);
else
    % Sort x(ll:mm) via insertion sort
    x = mergesorti(x,ll,mm,kk);
end
if ((uu - mm) <= kk)
    % Sort x((mm + 1):uu) via insertion sort
    x = insertionsorti(x,mm + 1,uu);
else
    % Sort x((mm + 1):uu) via merge sort
    x = mergesorti(x,mm + 1,uu,kk);
end

% ... and conquer
% Combine sorted arrays x(ll:mm) and x((mm + 1):uu)
x = merge(x,ll,mm,uu);


    function x = insertionsorti(x,ll,uu)
        % Sort x(ll:uu) via insertion sort
        % Note: In practice, x xhould be passed by reference
        
        for j = (ll + 1):uu
            pivot = x(j);
            pivotInd=indVec(j);
            i = j;
            while ((i > ll) && (x(i - 1) > pivot))
                x(i) = x(i - 1);
                indVec(i)=indVec(i-1);
                i = i - 1;
            end
            x(i) = pivot;
            indVec(i)=pivotInd;
        end
        
    end

    function x = merge(x,ll,mm,uu)
        % Combine sorted arrays x(ll:mm) and x((mm + 1):uu)
        % Note: In practice, x xhould be passed by reference
        
        % Note: In practice, use memcpy() or similar
        L = x(ll:mm);
        indLVec=indVec(ll:mm);
        
        % Combine sorted arrays
        i = 1;
        j = mm + 1;
        k = ll;
        while ((k < j) && (j <= uu))
            if (L(i) <= x(j))
                x(k) = L(i);
                indVec(k)=indLVec(i);
                i = i + 1;
            else
                x(k) = x(j);
                indVec(k)=indVec(j);
                j = j + 1;
            end
            k = k + 1;
        end
        
        % Note: In practice, use memcpy() or similar
        x(k:(j - 1)) = L(i:(i + j - k - 1));
        indVec(k:(j - 1)) = indLVec(i:(i + j - k - 1));
        
    end
end
