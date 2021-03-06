function corr = HHG(X,Y) 
% An auxiliary function that implements the HHG statistic from Heller 2012.
% The inputs are two distance matrices, and the output is the HHG statistic.
%
% This is a slow version that runs in O(n^3), 
% and a faster version is implemented by the original authors in a R package.
n=size(X,1);
S=zeros(n,n);

for i=1:n
    for j=1:n
        if (j~=i)
            tmp1=(X(i,:) <= X(i,j));
            tmp2=(Y(i,:) <= Y(i,j));
            t11=sum(tmp1.*tmp2)-2;
            t12=sum(tmp1.*(1-tmp2));
            t21=sum((1-tmp1).*tmp2);
            t22=sum((1-tmp1).*(1-tmp2));
            denom=(t11+t12)*(t21+t22)*(t11+t21)*(t12+t22);
            if (denom>0)
                S(i,j)=(n-2)*(t12*t21-t11*t22)^2/denom;
            end
        end
    end
end

corr=sum(sum(S)); %HHG is always non-negative