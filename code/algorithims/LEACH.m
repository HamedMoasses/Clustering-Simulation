
% LEACH algorithm( ch random, ignores the energy levele in ch selection but not in data sending..., ch selction continue till All nodes are covered )
function  net=LEACH(net)

%% ch initial setting
net.nodes.type(1:end-1)=0*net.nodes.type(1:end-1)+1;%at the first of each iteration all nodes become  normal node
net.nodes.ch =net.ind;%make themselfs as their ch.
net.nodes.chd=0*net.ind;%this distance will be zero for all of them in first
net.nodes.sSeg=0*net.ind+1;

allAlive= find((net.nodes.type==1 | net.nodes.type==2) &   net.nodes.E>0) ;%all normal alive nodes index
allDied= find((net.nodes.type==1 | net.nodes.type==2) &   net.nodes.E<=0) ;%all normal alive nodes index
allcov=0;% this flag used for determining that all nodes can select atleast one ch or not
net.para.chIt=0;% used for ch iteration

%% spacial LEACH parameters
p=0.1;% percentage of nodes that can selecet as ch(but the final chs can be more or lower than this perentage);

%% iteration for ch selection
while (allcov==0)
    
    %% find chs, normal node and uncoverd nodes index
    chIndex=find(net.nodes.type==2 &  net.nodes.E>0);% inital alive ch index
    nodIndex=find(net.nodes.type==1 &  net.nodes.E>0);%all normal alive nodes index
    unCoverNodes= nodIndex(ismember(sum((net.netDist(nodIndex,chIndex)<=net.para.R),2),0)); % find all normal nodes that not covered
    
    %% determine chs using randon vector
    rTan=rand(1,length(unCoverNodes));% make a randome vector to select some tentative chs
    final=unCoverNodes(rTan<= (p./(1-p*mod(net.para.sInd*0+1,round(1/p)))));% all uncovered nodes that random number is lower than them are selected as final chs
    net.nodes.type(final)=2;% final nodes become ch types
    
    if isempty(unCoverNodes) % if all node are covered
        allcov=1;% make flag 1, to stop cycle
    else
     net.para.chIt=net.para.chIt+1;% count the number of iteration for ch selection
    end
end

%% this section is almost common for all alghorithms
chIndex=find(net.nodes.type==2 &  net.nodes.E>0);% inital alive ch index
nodIndex=find(net.nodes.type==1 &  net.nodes.E>0);%all normal alive nodes index


%% election( Which of the candidates go to the parliament?!) by normal nodes
CoverNodesDist= (net.netDist(nodIndex,chIndex)<=net.para.R).*net.netDist(nodIndex,chIndex); % find all normal nodes that  covered
CoverNodesDist(CoverNodesDist==0)=CoverNodesDist(CoverNodesDist==0)+round(max(CoverNodesDist(:))+10);% find distance between covered life nodes with chs

[val, ind]= min(CoverNodesDist,[],2);%minimume distance of each normal node form chs and indices of chs returned as val and ind
seChInd=unique(chIndex(ind'),'stable');% all chs that are selected,are saved in  seChInd var as indeces
unSeChInd=chIndex(~ismember(chIndex,seChInd));% all chs that aren't selected,are saved in  unSeChInd var as indeces
net.nodes.type(unSeChInd)=1;% all unselected chs types change back to normal nodes type( but can be ch and send directly)

net.nodes.ch(nodIndex)=chIndex(ind');% each node  gets  index of it's selection  ch
net.nodes.chd(nodIndex)=val';% each node  gets  distance to it's selection ch

net.nodes.ch(chIndex)=net.ind(end);% all  chs select sink as their ch
net.nodes.chd(chIndex)=net.netDist(chIndex,net.ind(end))';% % each ch  gets  distance to sink



%% enregy consumption
net=EnergyCN(net);

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
    disp(['LEACH iteration: ' num2str(net.para.chIt) ' ch number: '  num2str(length(chIndex)) ' alive: ' ...
        num2str(length(allAlive)) ' rE: '  num2str( net.st.rE(end) ) ' aE: '  num2str( net.st.aE(end) )  ' cove: '  num2str( net.st.coverage(end) )   ]);
end
titleText=[' iteration: ' num2str(net.para.chIt) ' ch number: '  num2str(length(chIndex))  ' cove: '  num2str( net.st.coverage(end) )...
      ' alive: ' num2str(length(allAlive)) 10 ' rE: '  num2str( net.st.rE(end) ) ' aE: '  num2str( net.st.aE(end) )  10  ];
%% ploting operation
 
if  net.plot
subplot(2,3,1);%current sub plot replaced last subplot 1
plot([net.nodes.x(seChInd) ;net.nodes.x(net.nodes.ch(seChInd))],[net.nodes.y(seChInd) ;net.nodes.y(net.nodes.ch(seChInd))],'g-','color',[0.5,0.9,0.5]);hold on; % plot related line between chs with their chs
plot([net.nodes.x(nodIndex) ;net.nodes.x(net.nodes.ch(nodIndex))],[net.nodes.y(nodIndex) ;net.nodes.y(net.nodes.ch(nodIndex))],'r-','color',[0.9,0.5,0.5]);hold on; % plot related line between nodes with their chs

plot (net.gridx,net.gridy,'--k',net.gridx',net.gridy','--k' ,'color',[0.8,0.8,0.8] );hold on; % plot grid area
% text( net.gridCx,net.gridCy  ,cellstr(string(net.gridCy))); can be  used for numbering of the grid cells
plot( net.gridCx(coverage) ,net.gridCy(coverage)  ,'.g');hold on; % marking of coverage grid cells with green points
plot( net.gridCx(unCoverage) ,net.gridCy(unCoverage)  ,'.r');hold on; % marking of uncoverage grid cells with red points

plot(net.nodes.x(nodIndex),net.nodes.y(nodIndex),'b*');hold on; % plot normal alive nodes
plot(net.nodes.x(seChInd),net.nodes.y(seChInd),'og');hold on;% plot selcted alive chs nodes
plot(net.nodes.x(allDied),net.nodes.y(allDied),'k*');hold on;% plot dead nodes(normal or chs)

% plot(net.sLayer.sX,net.sLayer.sY,'-','color',[.9 .9 .9]);hold on;
title(titleText,'fontSize', 8);xlabel('LEACH algorithm');
xlim([0,net.para.length]);
ylim([0,net.para.width]);
end
end