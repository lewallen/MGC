function  [pMGC,statMGC,pLocalCorr,localCorr,optimalInd]=MGCPermutationTest(A,B,rep,option)
% Author: Cencheng Shen
% This function tests independent between two data sets, using MGC by a random permutation test.
% It outputs all local correlations, the sample MGC statistic, their
% p-values, and the estimated optimal scales.
%
% The inputs are:
% two distance matrices A & B,
% a parameter rep to specify the number of random permutations,
% an option to specify which global test to use, by 'mcor', 'dcor', 'mantel'.
%
% The outputs are:
% the sample MGC p-value, sample MGC test statistic,
% all local p-values, all local correlations, and the estimated optimal scales.
% Note the optimal scales are output as matrix single indices.
%
% Note that one should avoid report positive discovery via the minimal of
% all local p-values, as that will have multiple testing problem.

if nargin<3
    rep=1000; % use 1000 random permutations by default
end
if nargin<4
    option='mcor';  % use mcorr by default
end

sampleIndicator=0;
if strncmp(option,'mcor',4) || strncmp(option,'mgc',3)
    sampleIndicator=1; % only compute sample MGC for mcorr
end

if issymmetric(A)==false
    A=squareform(pdist(A));
end
if issymmetric(B)==false
    B=squareform(pdist(B));
end

% calculate all local correlations between the two data sets
localCorr=MGCLocalCorr(A,B,option);
[m,n]=size(localCorr);
if sampleIndicator==1
    statMGC=MGCSampleStat(localCorr); % sample MGC for the observed data
end
pLocalCorr=zeros(size(localCorr));pMGC=0;
n2=size(B,1);

% calculate the local correlations under permutation, to yield the p-values of all observed local correlations
for r=1:rep
    % use random permutations on the second data set
    per=randperm(n2);
    BN=B(per,per);
    tmp=MGCLocalCorr(A,BN,option);
    pLocalCorr=pLocalCorr+(tmp>=localCorr)/rep;
    if sampleIndicator==1
        tmp2=MGCSampleStat(tmp); % sample MGC for permuted data
        pMGC=pMGC+(tmp2>=statMGC)/rep;
    end
end
if sampleIndicator~=1 % other than mcorr, we do not implemented sample MGC yet, and the global statistic is always used
    pMGC=pLocalCorr(end);
    statMGC=localCorr(end);
end
% if reported p-value equals 0, the actual p-value is in fact <1/n. The reported
% p-value is thus changed to 1/n from 0.
% if min(min(pLocalCorr(2:end,2:end)))==0
%     pLocalCorr=pLocalCorr+1/rep;
% end
% pLocalCorr(pLocalCorr>1)=1;
% pLocalCorr(1,:)=1;pLocalCorr(:,1)=1;
% if min(min(pLocalCorr(2:end,2:end)))>pMGC
%     pMGC=min(min(pLocalCorr(2:end,2:end)));
% end

% estimate the optimal scales
warning('off','all');
[~,~,~,optimalInd]=FindLargestRectangles((pLocalCorr<=pMGC)&(localCorr>=statMGC), [0 0 1]);
optimalInd=find(optimalInd==1);
if (isempty(optimalInd))
    [~,~,~,optimalInd]=FindLargestRectangles((pLocalCorr<=pMGC), [0 0 1]);
    optimalInd=find(optimalInd==1);
    if (isempty(optimalInd) | optimalInd==m*n)
        optimalInd=m*n; % if the global scale is not selected in the largest rectangle while being optimal, we take the global scale instead.
    end
end