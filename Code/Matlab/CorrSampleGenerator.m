function [x, y]=CorrSampleGenerator(type,n,dim,dependent, noise)
% Author: Cencheng Shen
% Generate sample data x and y for testing independence based on given
% distribution.
%
% Parameters:
% type specifies the type of distribution,
% n is the sample size, dim is the dimension
% dependent specifies whether the data are dependent or not, by default 1
% noise specifies the noise level, by default 0. 
if nargin<4
    dependent=1; % by default generate dependent samples
end
if nargin<5
    noise=0; % default noise level
end

eps=mvnrnd(0,1,n); % Gaussian noise added to Y
% if noise~=0
%     eps=mvnrnd(0,1,n); % Gaussian noise added to Y
% else
%     eps=zeros(n,1);
% end

% High-dimensional decay
A=ones(dim,1);
%A=A./(ceil(dim*rand(dim,1))); %random decay
for d=1:dim
    A(d)=A(d)/d; %fixed decay
end
d=dim;

% Generate x by uniform distribution first, which is the default distribution used by many types; store the weighted summation in xA.
x=unifrnd(-1,1,n,d);
xA=x*A;
% Generate x independently by uniform if the null hypothesis is true, i.e., x is independent of y.
if dependent==0
    x=unifrnd(-1,1,n,d);
end

% The following paramter is used for the type 0 outlier model only.
% Note that the mixture probability is specified by noise, which should be
% in [0,1].
pp=noise;
mix=zeros(n,1);
mix(1:ceil(n*pp))=1;
u=mix;

switch type % In total 20 types of dependency + the type 0 outlier model
    case 0 %Test Outlier Model
        x=mvnrnd(zeros(n,d),eye(d));
        y=repmat((u>0),1,d).*(x) + repmat((u==0),1,d).*mvnrnd(-5*ones(n, d),eye(d));
        x=repmat((u>0),1,d).*(x)+repmat((u==0),1,d).*mvnrnd(5*ones(n, d),eye(d));
        if dependent==0
            x=mvnrnd(zeros(n,d),eye(d));
            x=repmat((u>0),1,d).*(x)+repmat((u==0),1,d).*mvnrnd(5*ones(n, d),eye(d));
        end
    case 1 %Linear
        y=xA+1*noise*eps;
    case 2 %Cubic
        y=128*(xA-1/3).^3+48*(xA-1/3).^2-12*(xA-1/3)+80*noise*eps;
    case 3 %Exponential
        x=unifrnd(0,3,n,d);
        y=exp(x*A)+10*noise*eps;
        if dependent==0
            x=unifrnd(0,3,n,d);
        end
    case 4 %Step Function
        if dim>1
            noise=1;
        end
        y=(xA>0)+1*noise*eps;
    case 5 %Joint Normal; note that dim should be no more than 10 as the covariance matrix for dim>10 is no longer positive semi-definite
        rho=1/(d*2);
        cov1=[eye(d) rho*ones(d)];
        cov2=[rho*ones(d) eye(d)];
        covT=[cov1' cov2'];
        x=mvnrnd(zeros(n,2*d),covT,n);
        y=x(:,d+1:2*d)+0.5*noise*repmat(eps,1,d);
        if dependent==0
            x=mvnrnd(zeros(n,2*d),covT,n);
        end
        x=x(:,1:d);
    case 6 %Quadratic
        y=(xA).^2+0.5*noise*eps;
    case 7 %W Shape
        y=4*( ( xA.^2 - 1/2 ).^2 + unifrnd(0,1,n,d)*A/500 )+0.5*noise*eps;
    case 8 %Two Parabolas
        y=( xA.^2  + 2*noise*unifrnd(0,1,n,1)).*(binornd(1,0.5,n,1)-0.5);
    case 9 %Fourth root
        y=abs(xA).^(0.25)+noise/4*eps;
    case 10 %Log(X^2)
        x=mvnrnd(zeros(n, d),eye(d));
        y=log(x.^2)+3*noise*repmat(eps,1,d);
        if dependent==0
            x=mvnrnd(zeros(n, d),eye(d));
        end
    case {11,12,13} %Circle & Ecllipse & Spiral
        if d>1
            noise=1;
        end
        cc=0.4;
        if type==11
            rx=ones(n,d);
        end
        if type==12
            rx=5*ones(n,d);
        end
 
        if type==13
            rx=unifrnd(0,5,n,1);
            ry=rx;
            rx=repmat(rx,1,d);
            z=rx;
        else
            z=unifrnd(-1,1,n,d);
            ry=ones(n,1);
        end
        x(:,1)=cos(z(:,1)*pi);
        for i=1:d-1;
            x(:,i+1)=x(:,i).*cos(z(:,i+1)*pi);
            x(:,i)=x(:,i).*sin(z(:,i+1)*pi);
        end
        x=rx.*x;
        y=ry.*sin(z(:,1)*pi);
        if type==13
            y=y+cc*(dim-1)*noise*mvnrnd(zeros(n, 1),eye(1));
        else
            x=x+cc*noise*rx.*mvnrnd(zeros(n, d),eye(d));
        end
        if dependent==0
            if type==13
                rx=unifrnd(0,5,n,1);
                rx=repmat(rx,1,d);
                z=rx;
            else
                z=unifrnd(-1,1,n,d);
            end
            x(:,1)=cos(z(:,1)*pi);
            for i=1:d-1;
                x(:,i+1)=x(:,i).*cos(z(:,i+1)*pi);
                x(:,i)=x(:,i).*sin(z(:,i+1)*pi);
            end
            x=rx.*x;
            if type==13
            else
                x=x+cc*noise*rx.*mvnrnd(zeros(n, d),eye(d));
            end
        end
    case {14,15} %Square & Diamond
        u=repmat(unifrnd(-1,1,n,1),1,d);
        v=repmat(unifrnd(-1,1,n,1),1,d);
        if type==14
            theta=-pi/8;
        else
            theta=-pi/4;
        end
        eps=0.05*(d)*mvnrnd(zeros(n,d),eye(d),n);
        x=u*cos(theta)+v*sin(theta)+eps;
        y=-u*sin(theta)+v*cos(theta);
        if dependent==0
            u=repmat(unifrnd(-1,1,n,1),1,d);
            v=repmat(unifrnd(-1,1,n,1),1,d);
            eps=0.05*(d)*mvnrnd(zeros(n,d),eye(d),n);
            x=u*cos(theta)+v*sin(theta)+eps;
        end
    case {16,17} %Sine 1/2 & 1/8
        x=repmat(unifrnd(-1,1,n,1),1,d)+0.02*(d)*mvnrnd(zeros(n,d),eye(d),n);
        if type==16
            theta=4;cc=1;
        else
            theta=16;cc=0.5;
        end
        y=sin(theta*pi*x)+cc*noise*repmat(eps,1,d);
        if dependent==0
            x=repmat(unifrnd(-1,1,n,1),1,d)+0.02*(d)*mvnrnd(zeros(n,d),eye(d),n);
        end
    case 18 %Multiplicative Noise
        x=mvnrnd(zeros(n, d),eye(d));
        y=mvnrnd(zeros(n, d),eye(d));
        if dim>1
            noise=1;
        end
        y=x.*y+0.5*noise*repmat(eps,1,d);
        if dependent==0
            x=mvnrnd(zeros(n, d),eye(d));
        end
    case 19 %Uncorrelated Binomial
        x=binornd(1,0.5,n,d);
        y=(binornd(1,0.5,n,1)*2-1);
        if dim>1
            noise=1;
        end
        y=x*A.*y+0.6*noise*eps;
        if dependent==0
            x=binornd(1,0.5,n,d);
        end
    case 20 %Independent clouds
        x=mvnrnd(zeros(n,d),eye(d),n)/3+(binornd(1,0.5,n,d)-0.5)*2;
        y=mvnrnd(zeros(n,d),eye(d),n)/3+(binornd(1,0.5,n,d)-0.5)*2;
end

%affine invariant
%x=x*cov(x)^(-0.5);
%y=y*cov(y)^(-0.5);