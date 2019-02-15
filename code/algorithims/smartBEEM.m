
%smartBEEM algorithm( in ch  selection and  data sending,  The energy level is taken into consideration, ch selction continue till All nodes are covered, aditional operation in regarding to BEE is hierarchy ch selction, to decrese coverage  )
function  net=smartBEEM(net)
%% ch initial setting
net.nodes.type(1:end-1)=0*net.nodes.type(1:end-1)+1;%at the first of each iteration all nodes become  normal node
net.nodes.ch =net.ind;%make themselfs as their ch.
net.nodes.chd=0*net.ind;%this distance will be zero for all of them in first
net.nodes.sSeg=0*net.ind+1;

allAlive= find((net.nodes.type==1 | net.nodes.type==2) &   net.nodes.E>0) ;%all normal alive nodes index
allDied= find((net.nodes.type==1 | net.nodes.type==2) &   net.nodes.E<=0) ;%all normal alive nodes index
allcov=0;% this flag used for determining that all nodes can select atleast one ch or not
net.para.chIt=0;% used for ch iteration


%% spacial smartBEEM parameters or setting
Cen=net.nodes.E(allAlive)./net.para.E0 ;%proportion of residual energy to maximum energy(
net.nodes.deg(allAlive)=sum((net.netDist(allAlive,allAlive)<=net.para.R),2); % find all normal node degree
Area=net.para.sR.^2;%senseing squre area, because here the sensing area assumed square not circle
Davg=pi*net.para.R.^2 *(length(allAlive)/ Area);%avrage density of all network
nodD=pi*net.para.R.^2 *(net.nodes.deg(allAlive)./ Area);%density of each node
dVe=nodD./Davg;%proportion of node density vector to network density
Cde=min([dVe;0*dVe+1],[],1);% cn need to be between 0 and 1
net.nodes.Chprob(allAlive) = net.nodes.Cprob(allAlive).*Cen.*Cde;%dinamic ch probablity  parameter for each node:in smartBEEM this probablity vector dont use ,but parts of it is used instead....

%% iteration for ch selection
while (allcov==0)
    %% find chs, normal node and uncoverd nodes index
    chIndex=find(net.nodes.type==2 &  net.nodes.E>0);% inital alive ch index
    nodIndex=find(net.nodes.type==1 &  net.nodes.E>0);%all normal alive nodes index
    unCoverNodes= nodIndex(ismember(sum((net.netDist(nodIndex,chIndex)<=net.para.R),2),0)); % find all normal nodes that not covered
    unCoverNodesBin=ismember( nodIndex,unCoverNodes);
    
    %% determine final chs using Triple condition
    rTan=rand(1,length(unCoverNodes));% make a randome vector to select some tentative chs
    c1= net.nodes.Cprob(unCoverNodes)>=rTan/3;% first condition; all uncoverd nodes that their Cprob(not Chprob!) of them is bigger or equal to random number
    c2=Cen(unCoverNodesBin)>=1;%second condition; all live uncoverd node that amount of their Cen parmeters is bigger or equal to 1
    c3=Cde(unCoverNodesBin)>=1;%third condition;  all live uncoverd node that amount of their Cde parmeters is bigger or equal to 1
    
    chSelfEleT=[c1;c2;c3];% Table 3. CH Self-election Table.
    final=unCoverNodes(sum(chSelfEleT,1)>=2);% all alive uncovered nodes that satisfied at least two conditions, become to final ch
    
    % reformation of final chs that have overlap each together
    final1=final(sum((net.netDist(final,final)<=net.para.R),2)==1);% chs that dont have any overlap
    final2=final(sum((net.netDist(final,final)<=net.para.R),2)>=2);% chs that have atleast one overlap
    try
        final1(end+1)=final2(end);
    catch
    end
    final=final1; % reformed final chs(maybe fewer than..)
    net.nodes.type(final)=2;% final nodes become ch nodes
    
    %% determine tentative chs using Triple condition
    tentChs=unCoverNodes(sum(chSelfEleT,1)<2);% all alive uncovered nodes that satisfied at least two conditions, become to final ch
    tentChsBin=ismember( nodIndex,tentChs );
    
    %% update cen and cde parameters of tentative chs and control operation
    Cen(tentChsBin)=Cen(tentChsBin)*2;
    Cde(tentChsBin)=Cde(tentChsBin)*2;
    if length(unCoverNodes)==1% this is an option, when we have one uncoverd node it can become to final ch, for preventing of more iteration
        net.nodes.type(unCoverNodes)=2;
    end
    if isempty(unCoverNodes) % if all node are covered
        allcov=1;% make flag 1, to stop cycle
    else
        net.para.chIt=net.para.chIt+1;% count the number of iteration for ch selection
    end
    
    
end

%% this section is almost common for all alghorithms
chIndex=find(net.nodes.type==2 &  net.nodes.E>0);% inital alive ch index
nodIndex=find(net.nodes.type==1 &  net.nodes.E>0);%all normal alive nodes index






%election( Which of the candidates go to the parliament?!) by normal nodes
CoverNodesDist= (net.netDist(nodIndex,chIndex)<=net.para.R).*net.netDist(nodIndex,chIndex); % find all normal nodes that  covered
CoverNodesDist(CoverNodesDist==0)=CoverNodesDist(CoverNodesDist==0)+round(max(CoverNodesDist(:))+10);% find distance between covered life nodes with chs

[val, ind]= min(CoverNodesDist,[],2);%minimume distance of each normal node form chs and indices of chs returned as val and ind
seChInd=unique(chIndex(ind'),'stable');% all chs that are selected,are saved in  seChInd var as indeces
unSeChInd=chIndex(~ismember(chIndex,seChInd));% all chs that aren't selected,are saved in  unSeChInd var as indeces
% net.nodes.type(unSeChInd)=1;% all unselected chs types change back to normal nodes type( but can be ch and send directly)

net.nodes.ch(nodIndex)=chIndex(ind');% each node  gets  index of it's selection  ch
net.nodes.chd(nodIndex)=val';% each node  gets  distance to it's selection ch

net.nodes.ch(chIndex)=net.ind(end);% all  chs select sink as their ch
net.nodes.chd(chIndex)=net.netDist(chIndex,net.ind(end))';% % each ch  gets  distance to sink



%%  function 2: will converte  to a function:finding degree of each ch node for energy consumption requirement
chs =net.nodes.ch([nodIndex,chIndex]);% find all chs that are selected by normal nodes or chs
unSelCh=chIndex(~ismember(chIndex,chs));% determine the unselected candidate chs by normal nodes
chs(end+1:end+length(unSelCh))=unSelCh;% ad it to ch list
mat=chs' * (chs./chs);% repeat css in row and make square matrix
smat1=mat./ mat';% divide this matrix to its transpose
smat1(smat1==1)=0;smat1=~smat1; % all elements that are 1 means a selection time by one of nodes
[C,ia,ic] =unique(chs,'stable');ia=ia';ic=ic';% unique the ches index and get the first occurence of each index and unique index

df=sum(smat1,2)';% sum of all columns in one column to determine number of selection each ch selection time
grReap=df(ia);% get degree of each ch
 

sinkInd=C==net.para.nodNum; % detrmin sink occurence index
C(sinkInd)=[];% delete sing from the list
grReap(sinkInd)=[];% and from number of selection vector
net.nodes.sSeg(C)=grReap*(1-net.para.dComRat);% compres it.

 





%% ch selection between chs
%% this section will convert to an algorithm later for leyer detection
chDistDist=net.netDist(chIndex,[chIndex,end]);%distance between chs,  as a matrix
sinkDistDist=net.netDist([chIndex,end],end);% distance between chs and sink
layerNumber=(sinkDistDist+10-(mod(sinkDistDist,10)))/10;% get layer number of each ch from sink
mat=layerNumber* (layerNumber./layerNumber)';
smat=mat'./ mat;smat=smat(1:end-1,:);
smat(smat<1)=0;smat=~smat;
smat=smat.*chDistDist;smat(smat==0)=max(smat(:))+10;
% smat(:,end+1)=sinkDistDist;
[val,in]=min(smat,[],2);
lastCh=[chIndex,net.para.nodNum];
lastCh=lastCh(in);

net.nodes.ch(chIndex)=lastCh;
net.nodes.chd(chIndex)=val';


%% enregy consumption
net=EnergyCSM(net);

[M,I]=min(net.gridDist(allAlive,:),[],2);% net.gridDist is the distance  matrix of all nodes from the senseing squre centers, here we can find minimum distance of each node from this centers and index of this centers
coverage=  unique(I);% number of centers that are selcted by one or more nodes,determine number of coverage area(10x10 squre area)
unCoverage=~ismember(1:size(net.gridDist,2),coverage');% ch selction iteration



%% statictics information gathering
net.st.chIt(end+1)=net.para.chIt;% ch selction iteration
net.st.ch(end+1)=length(chIndex)/length(net.nInd);% ch selction percentage
net.st.alive(end+1)=length(allAlive);% number of alive nodes
net.st.rE(end+1)=sum(net.nodes.E(allAlive));% sum of residual energy
net.st.aE(end+1)=sum(net.nodes.E(allAlive))/length(net.nInd);% avrage of residual energy
net.st.coverage(end+1)=length(coverage);% number of cavarage area

%% display current statictics information
if  net.disp
    disp(['smartBEEM iteration: ' num2str(net.para.chIt) ' ch number: '  num2str(length(chIndex)) ' alive: ' ...
        num2str(length(allAlive)) ' rE: '  num2str( net.st.rE(end) ) ' aE: '  num2str( net.st.aE(end) )  ' cove: '  num2str( net.st.coverage(end) )   ])
end
titleText=[' iteration: ' num2str(net.para.chIt) ' ch number: '  num2str(length(chIndex))  ' cove: '  num2str( net.st.coverage(end) )...
    ' alive: ' num2str(length(allAlive)) 10 ' rE: '  num2str( net.st.rE(end) ) ' aE: '  num2str( net.st.aE(end) )  10  ];
%% ploting operation
if  net.plot
subplot(2,3,5);%current sub plot replaced last subplot 1
plot([net.nodes.x(seChInd) ;net.nodes.x(net.nodes.ch(seChInd))],[net.nodes.y(seChInd) ;net.nodes.y(net.nodes.ch(seChInd))],'g-','color',[0.5,0.9,0.5]);hold on; % plot related line between chs with their chs
plot([net.nodes.x(nodIndex) ;net.nodes.x(net.nodes.ch(nodIndex))],[net.nodes.y(nodIndex) ;net.nodes.y(net.nodes.ch(nodIndex))],'r-','color',[0.9,0.5,0.5]);hold on; % plot related line between nodes with their chs

plot (net.gridx,net.gridy,'--k',net.gridx',net.gridy','--k' ,'color',[0.8,0.8,0.8] );hold on; % plot grid area
% text( net.gridCx,net.gridCy  ,cellstr(string(net.gridCy))); can be  used for numbering of the grid cells
plot( net.gridCx(coverage) ,net.gridCy(coverage)  ,'.g');hold on; % marking of coverage grid cells with green points
plot( net.gridCx(unCoverage) ,net.gridCy(unCoverage)  ,'.r');hold on; % marking of uncoverage grid cells with red points

plot(net.nodes.x(nodIndex),net.nodes.y(nodIndex),'b*');hold on; % plot normal alive nodes
plot(net.nodes.x(seChInd),net.nodes.y(seChInd),'og');hold on;% plot selcted alive chs nodes
plot(net.nodes.x(allDied),net.nodes.y(allDied),'k*');hold on;% plot dead nodes(normal or chs)

plot(net.sLayer.sX,net.sLayer.sY,'-','color',[.9 .9 .9]);hold on;
title(titleText,'fontSize', 8);xlabel('smartBEEM algorithm');
xlim([0,net.para.length]);
ylim([0,net.para.width]);
end
end