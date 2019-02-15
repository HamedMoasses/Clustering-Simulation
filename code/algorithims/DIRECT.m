% DIRECT algorithm all nodes send directional
function  net=DIRECT(net)

%% enregy consumption
allAlive= find((net.nodes.type==1 | net.nodes.type==2) &   net.nodes.E>0) ;%all normal alive nodes index
 
net.nodes.ch(allAlive)=net.ind(end);% all  chs select sink as their ch
net.nodes.chd(allAlive)=net.netDist(allAlive,net.ind(end))';% % each ch  gets  distance to sink

net=EnergyCN(net);
allAlive= find((net.nodes.type==1 | net.nodes.type==2) &   net.nodes.E>0) ;%all normal alive nodes index
allDied= find((net.nodes.type==1 | net.nodes.type==2) &   net.nodes.E<=0) ;%all normal alive nodes index


chIndex=find(net.nodes.type==2 &  net.nodes.E>0);% inital alive ch index
nodIndex=find(net.nodes.type==1 &  net.nodes.E>0);%all normal alive nodes index


[M,I]=min(net.gridDist(allAlive,:),[],2);% net.gridDist is the distance  matrix of all nodes from the senseing squre centers, here we can find minimum distance of each node from this centers and index of this centers
coverage=  unique(I);% number of centers that are selcted by one or more nodes,determine number of coverage area(10x10 senseing squre area)
unCoverage=~ismember(1:size(net.gridDist,2),coverage');% ch selction iteration 



net.st.chIt(end+1)=net.para.chIt;% ch selction iteration 
net.st.ch(end+1)=length(chIndex)/length(net.nInd);% ch selction percentage 
net.st.alive(end+1)=length(allAlive);% number of alive nodes
net.st.rE(end+1)=sum(net.nodes.E(allAlive));% sum of residual energy
net.st.aE(end+1)=sum(net.nodes.E(allAlive))/length(net.nInd);% avrage of residual energy
net.st.coverage(end+1)=length(coverage);% number of cavarage area



if  net.disp
disp(['direct iteration: ' num2str(net.para.chIt) ' ch number: '  num2str(length(chIndex)) ' alive: ' ...
num2str(length(allAlive)) ' rE: '  num2str( net.st.rE(end) ) ' aE: '  num2str( net.st.aE(end) )  ' cove: '  num2str( net.st.coverage(end) )   ]);
end
titleText=[' iteration: ' num2str(net.para.chIt) ' ch number: '  num2str(length(chIndex))  ' cove: '  num2str( net.st.coverage(end) )...
      ' alive: ' num2str(length(allAlive)) 10 ' rE: '  num2str( net.st.rE(end) ) ' aE: '  num2str( net.st.aE(end) )  10  ];


if  net.plot
subplot(2,3,3 );%current sub plot replaced last subplot 1
 plot([net.nodes.x(nodIndex) ;net.nodes.x(net.nodes.ch(nodIndex))],[net.nodes.y(nodIndex) ;net.nodes.y(net.nodes.ch(nodIndex))],'r-','color',[0.9,0.5,0.5]);hold on; % plot related line between nodes with their chs

plot (net.gridx,net.gridy,'--k',net.gridx',net.gridy','--k' ,'color',[0.8,0.8,0.8] );hold on; % plot grid area
% text( net.gridCx,net.gridCy  ,cellstr(string(net.gridCy))); can be  used for numbering of the grid cells
plot( net.gridCx(coverage) ,net.gridCy(coverage)  ,'.g');hold on; % marking of coverage grid cells with green points
plot( net.gridCx(unCoverage) ,net.gridCy(unCoverage)  ,'.r');hold on; % marking of uncoverage grid cells with red points

plot(net.nodes.x(nodIndex),net.nodes.y(nodIndex),'b*');hold on; % plot normal alive nodes
 plot(net.nodes.x(allDied),net.nodes.y(allDied),'k*');hold on;% plot dead nodes(normal or chs)

% plot(net.sLayer.sX,net.sLayer.sY,'-','color',[.9 .9 .9]);hold on;
title(titleText,'fontSize', 8);xlabel('HEED algorithm');
xlim([0,net.para.length]);
ylim([0,net.para.width]);   
end

end