function []=CORRData(aList,rep1,rep2,pre1,alpha)

% aList = {'BNU1','BNU2','BNU3'};
% aList =  {'DC1','HNU1','IACAS'};
% aList= {'IBATRT','IPCAS1','IPCAS2'};
% aList= {'IPCAS5','JHNU','KKI21'};
% aList= {'LMU3','MPG1','MRN'};
% aList= {'NYU1','NYU2','SWU3','SWU1'};
% aList=  {'SWU4','UM','UPSM1','SWU2'};
% aList= {'Utah1','UWM','XHCUMS'};
% CORRData(aList)

if nargin<1
    aList = {'BNU1','BNU2','BNU3','DC1','HNU1','IACAS','IBATRT','IPCAS1','IPCAS2','IPCAS5','IPCAS6','IPCAS8','JHNU','KKI21','LMU3','MPG1','MRN','NKI24mx645','NKI24mx1440','NKI24std2500','NYU1','NYU2','SWU1','SWU2','SWU3','SWU4','UM','UPSM1','Utah1','UWM','XHCUMS'};
end
if nargin<2
    rep1=25;
end
if nargin<3
    rep2=100;
end
if nargin<4
    pre1='../../../../Data/CORR/';
end
if nargin<5
    alpha=0.05;
end
option=[0,2,0,0];
for l=1:length(aList);
    str1=aList(l);str1=str1{1,1};
    fileDir=strcat(pre1,str1,'/');
    allFiles = dir( fileDir );
    allNames = { allFiles.name };
    indStr = strfind(allNames,'session_1');
    indStr = find(~cellfun(@isempty,indStr));
    allNames=allNames(indStr);
    
    n=length(allNames);
    fileName=allNames(1);
    load(strcat(fileDir,fileName{1,1}));
    [region,timestep]=size(roi_data);
    
    X=zeros(n,timestep,region);
    Y=mvnrnd(0,1,timestep);
    distP=squareform(pdist(Y));
    power=zeros(7,1);
    p1=zeros(7,1);
    
    for j=1:n
        fileName=allNames(j);
        load(strcat(fileDir,fileName{1,1}));
        X(j,:,:)=roi_data(:,1:timestep)';
    end
    
    for r=1:region
%         r
        distC=squareform(pdist(X(:,:,r)'));
        %distP=squareform(pdist(X2(:,:,i)));
        [p1(1), p1(2), p1(3), p1(4),p1(5),p1(6),p1(7)]=CorrPermDistTest(distC,distP,rep1,rep2,'tmp',option);
        for tt=1:7
            if p1(tt)<alpha
                power(tt)=power(tt)+1/region;
            end
        end
    end
    
    fileS=strcat(pre1,str1,'FalseDetection.mat');
    save(fileS,'power','alpha','n','timestep','region','str1');
end