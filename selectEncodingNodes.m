
% include the file that contains the problem variables and builds the trees
buildingRoutingTrees;
% The following code define the failures secenario/scenarios where one or more links are failed
% based on these failures, the model will choose the best number and locations of nodes that are
% going to be encoding nodes. this way we can recover the packets stored
% in the nodes that sources of the failed links.
FailureScenarios={[42,81,116,150]};
numberOfFailScens=length(FailureScenarios);

% number of failed links in single failure scenario
failedLinksInScen= cellfun(@length, FailureScenarios);
failure_scen_var_length=0;

% total number of failed links in all scenarios
for f=1:length(FailureScenarios)
    failure_scen_var_length=failure_scen_var_length+failedLinksInScen(f);
end

% initialize the decicion variable and matrices
decisionVar=zeros(numberOfNodes+numberOfLinks+failure_scen_var_length*numberOfLinks+numberOfNodes*failure_scen_var_length,1);
numberOfVariables=length(decisionVar);
Aeq=zeros(numberOfNodes,numberOfVariables);
beq=zeros(numberOfNodes,1);
A=zeros(numberOfNodes,numberOfVariables);
b=zeros(numberOfNodes,1);

% 1- define the lower and the upper bounds
lb=zeros(numberOfVariables,1);
ub=ones(numberOfVariables,1);

% get sources and destination nodes of failed links
srcL=cell(1,numberOfFailScens);
destL=cell(1,numberOfFailScens);
for f=1:length(FailureScenarios)
    
    for l=1:failedLinksInScen(f)
        for j=1:numberOfLinks
            if networkF(j,3)==FailureScenarios{f}(1,l)
                srcL{f}(1,l)=networkF(j,1);
                destL{f}(1,l)=networkF(j,2);
            end
        end
    end
end

% highlight the failed links
for f=1:numberOfFailScens
    for l=1:failedLinksInScen(f)
        highlight(p,srcL{f}(1,l),destL{f}(1,l),'EdgeColor','y');       
    end
    highlight(p,gateways,'NodeColor','g');       
end
   

%% Failure constraint

failureIsDest=zeros(length(FailureScenarios)*numberOfNodes,numberOfLinks);
failureIsSrc=zeros(length(FailureScenarios)*numberOfNodes,numberOfLinks);
e=0;
esrc=0;
% Failure sources
for f=1:length(FailureScenarios)
    for k=1:failedLinksInScen(f)
        workingLinks=get_workingLinks_in_failureScen(f,failedLinksInScen,links,FailureScenarios);
        for i=1:numberOfNodes
            for j=1:length(workingLinks)
                bool=isAgateway(workingLinks(j),1,gateways,network);
                if networkF(workingLinks(j),1)==i  && bool==false
                    failureIsSrc(i+e,workingLinks(j)+esrc)=1;
                else
                    failureIsSrc(i+e,workingLinks(j)+esrc)=0;
                end
            end
        end
        e=e+numberOfNodes;
    end
end

%% failure destination
e=0;
edest=0;
for f=1:length(FailureScenarios)
    for k=1:failedLinksInScen(f)
        
        workingLinks=get_workingLinks_in_failureScen(f,failedLinksInScen,links,FailureScenarios);
        for i=1:numberOfNodes
            for j=1:length(workingLinks)
                bool=isAgateway(workingLinks(j),1,gateways,network);
                if networkF(workingLinks(j),2)==i && bool==false
                    failureIsDest(i+e,workingLinks(j)+edest)=-1;
                else
                    failureIsDest(i+e,workingLinks(j)+edest)=0;
                end
            end
        end
        e=e+numberOfNodes;
    end
end

% adjFailure Matrix
adjFailure=failureIsSrc(:,:)+failureIsDest(:,:);

% store all the sources of failed links in sourcesF matrix
sourcesF=cell(1,numberOfFailScens);
for f=1:numberOfFailScens
    for l=1:failedLinksInScen(f)
        for n=1:numberOfNodes
            for j=1:numberOfLinks
                if networkF(j,1)==n && networkF(j,3)==FailureScenarios{f}(1,l)
                    sourcesF{f}(1,l)=networkF(j,1);  
                end
            end
        end
    end
end
%% Failure scenario:indicate the failed links in each failure scenario
e=0;
fCol=numberOfNodes+1;
fColEnd=fCol-1+numberOfLinks;

gmmaCol=numberOfNodes+numberOfLinks+1;
etaCol=numberOfLinks + numberOfNodes+failure_scen_var_length*numberOfLinks;
GRow=0;

for f=1:numberOfFailScens
    for i=1: failedLinksInScen(f)
        workingLinks=get_workingLinks_in_failureScen(f,failedLinksInScen,links,FailureScenarios);
        for j= 1:numberOfNodes
            Aeq(GRow+j+e,fCol:fColEnd)=adjFailure(j+e,1:numberOfLinks);
            if isSource(j,FailureScenarios{f}(1,i))==1
                sum_lPrime=sum_Working_Links(j,gammaTree,workingLinks,network);
                beq(GRow+j+e)=1-sum_lPrime;
            else
                Aeq(GRow+j+e,etaCol+j+e)=1;
                beq(GRow+j+e)=0;
            end
        end
        fCol=fColEnd+1;
        fColEnd=fColEnd+numberOfLinks;
        e=e+numberOfNodes;
        
    end
end

%% This check if a destination node is exist for building the protective path
RowC7=numberOfNodes*failure_scen_var_length+1;

for f=1:numberOfFailScens
    for l=1:failedLinksInScen(f)
        sumPrimes=0;
        workingLinks=get_workingLinks_in_failureScen(f,failedLinksInScen,links,FailureScenarios);
        Aeq(RowC7,etaCol+1:etaCol+numberOfNodes)=1; 
        for j=1:length(workingLinks)
            if network(workingLinks(j),1)== network(FailureScenarios{f}(1,l),1)
                sumPrimes=sumPrimes+gammaTree(workingLinks(j));
            end
        end
        beq(RowC7)=1-sumPrimes;
        etaCol=etaCol+numberOfNodes;
        RowC7=RowC7+1;
    end
end


%% this is to determine if the node is the final destination or just serves as intermediate node in the protective path
e=0;
RowC8=0;
etaCol=numberOfLinks + numberOfNodes+failure_scen_var_length*numberOfLinks;
for f=1:numberOfFailScens
    for i=1: failedLinksInScen(f)
        workingLinks=get_workingLinks_in_failureScen(f,failedLinksInScen,links,FailureScenarios);
        for j= 1:numberOfNodes
            if nodesOutG(j)~=1
                A(j+e,etaCol+j+e)=1;
                sum_lPrime=sum_Working_Links(j,gammaTree,workingLinks,network);
                
                b(j+e)=sum_lPrime;
            end
        end
        e=e+numberOfNodes;
    end
end

RowC9=numberOfNodes*failure_scen_var_length+1;
etaCol=numberOfLinks + numberOfNodes+failure_scen_var_length*numberOfLinks;
e=0;
for f=1:numberOfFailScens
    for l=1:failedLinksInScen(f)
        for n=1:numberOfNodes
            workingLinks=get_workingLinks_in_failureScen(f,failedLinksInScen,links,FailureScenarios);
            for j=1:length(workingLinks)
                if isSource(n,workingLinks(j))==1 && networkF(workingLinks(j),2)==sourcesF{f}(1,l)
                    
                    A(RowC9,etaCol+n+e)=1;
                    b(RowC9)=1- gammaTree(workingLinks(j));
                    RowC9=RowC9+1;    
                end
            end
        end
        e=e+numberOfNodes;
    end
end



%% will the node be encoding node or not.
fRow=2*(numberOfNodes*failure_scen_var_length)+1;
fCol=numberOfNodes;
fColEnd=fCol+numberOfLinks-1;

for i=1:numberOfNodes
    for f=1:numberOfFailScens
        for j=1:failedLinksInScen(f)
            for k=1: numberOfLinks
                if network(k,2)==i && isAgateway(k,1,gateways,network)==false %&& isAgateway(k,2,gateways,network)==false
                    A(fRow,fCol+k)=1;
                    A(fRow,i)=-1;
                    b(fRow)=0;
                    fRow=fRow+1;
                end
            end
            fCol=fCol+numberOfLinks;
        end 
    end
    fCol=numberOfNodes;
end

%% objective function
f=zeros(numberOfVariables,1);
f(1:numberOfNodes,1)=1;
IntCon=1:numberOfVariables;
[x] = intlinprog(f,IntCon,A,b,Aeq,beq,lb,ub);


%% Optimization tree links (gammas variables)
if isempty(x)
    gammaTree=0;
    sigmaTree=0;
    enNodesOpt=0;
else
    
    gammaTree=logical(gammaTree);
    enNodesOpt=x(1:numberOfNodes);
    sigmaTree=x(numberOfNodes+1:numberOfNodes+failure_scen_var_length*numberOfLinks);
    sigmaTree=logical(sigmaTree);
    activeLinks=sum(logical(gammaTree));
    srcOptT=cell(1,numberOfFailScens);
    destOptT=cell(1,numberOfFailScens);
end


%% alternative path, sigma variables tree

srcOptAltT=cell(1,numberOfFailScens);
destOptAltT=cell(1,numberOfFailScens);
e=0;

if isempty(x)
    sigmaTree=0;
else
    for f=1:numberOfFailScens
        for l=1:failedLinksInScen(f)
            for j=1:numberOfLinks
                % activeAlterLinks=sum(logical(sigmaTree(e+l:numberOfLinks+e)));
                if sigmaTree(j+e)==1
                    srcOptAltT{f}(1,l)=network(j,1);
                    destOptAltT{f}(1,l)=network(j,2);
                end
            end
            e=e+numberOfLinks;
        end
    end
    
    % exclude zeros from the matrice when the failed link does not belong to
    % the tree
    
    for f=1:numberOfFailScens
        for l=1:failedLinksInScen(f)
            srcOptAltT{f}=srcOptAltT{f}(srcOptAltT{f}~=0);
            destOptAltT{f}=destOptAltT{f}(destOptAltT{f}~=0);
        end
    end
    srcOptAltT = srcOptAltT(~cellfun('isempty', srcOptAltT));
    destOptAltT = destOptAltT(~cellfun('isempty', destOptAltT));
    
    alterPathLength=cellfun(@length, srcOptAltT);
    for f=1:length(srcOptAltT)
        for l=1:alterPathLength(f)
            highlight(p,srcOptAltT{f}(1,l),destOptAltT{f}(1,l),'EdgeColor','c');
        end
    end
end
%% represent the results
if isempty(x)
    return;
else
    resu = cell(numberOfVariables,1);
    names = cell(numberOfVariables,1);
    for i = 1:numberOfNodes
        names{i} = ['Ne' '_' num2str(i)  ];
        resu{i} =    [names{i} ':  ' num2str(x(i))];
    end
    
    wf=0;
    k=numberOfNodes;
    for fScen=1:numberOfFailScens
        for fLink=1:failedLinksInScen(fScen)
            for i=k+1 :k+numberOfLinks
                names{i+wf}=['sigma' '_' num2str(fScen) '_' num2str(FailureScenarios{fScen}(1,fLink)) '_' num2str(i-k)];
                resu{i+wf} =    [names{i+wf} ':  ' num2str(x(i)+wf)];
            end
            wf=wf+numberOfLinks;
        end
    end
    
    wF=0;
    k=numberOfNodes+failure_scen_var_length*numberOfLinks;
    for i=k+1: k+numberOfLinks
        names{i+wF}=['gamma' '_' num2str(i-k)];
        resu{i+wF}= [names{i+wF} ': ' num2str(x(i)+wF)];
    end
    wF=wF+numberOfLinks;
    wf=0;
    k= numberOfLinks + numberOfNodes+failure_scen_var_length*numberOfLinks;
    for fScen=1:numberOfFailScens
        for fLink=1:failedLinksInScen(fScen)
            for i=k+1:k+numberOfNodes
                names{i+wf}=['eta' '_' num2str(fScen) '_' num2str(FailureScenarios{fScen}(1,fLink)) '_' num2str(i-k)];
                resu{i+wf}=[names{i+wf} ': ' num2str(x(i)+wf)];
            end
            wf=wf+numberOfNodes;
        end
    end
    ResTable=table(names,x);
end



%% Functions section
% check if the node is a gateway 
function bool =isAgateway(i,e,gateways,network)
numberOfGetways=length(gateways);
for g=1:numberOfGetways
    if network(i,e)==gateways(g)
        bool=true;
        break;
    else
        bool=false;
    end
end
end

% Get the total working links after failure scenarios
function suml_Prime=sum_Working_Links(n,gammaTree,workingLinks,network)
sumP=0;
for j=1:length(workingLinks)
    if network(workingLinks(j),1)==n
        sumP=sumP+gammaTree(workingLinks(j));
    end
end
suml_Prime=sumP;
end

% Get workin links after failure scenarios
function workingLinksInScen= get_workingLinks_in_failureScen(fScen,failedLinksInScen,links,FailureScenarios)
workingLinks=links;
for j=1:failedLinksInScen(fScen)
    workingLinks=workingLinks(workingLinks~=FailureScenarios{fScen}(1,j));
end
workingLinksInScen=workingLinks;
end

