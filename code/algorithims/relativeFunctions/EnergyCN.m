        %energy consumption for normal wirless comunication

        % Leach,Heed and BEEM use this model  based on following attributes:
        % no mimo features
        % d0=40;
        % 2 level energy consumpation(low and  high)
        % 1 level bandwidth
        % 1 interface with
        function netE=EnergyCN(netE)
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Energy parameter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ETX=50*0.000000001;
        ERX=50*0.000000001;
        Eelec=ETX; %Transmission/Receiving (Eelect)

        %Transmit Amplifier types
        Emp1=10*0.000000000001;% low power
        Emp2=0.0013*0.000000000001;% heigh power
        %Data Aggregation Energy
        d0=40;%level one d0
        %   d0=sqrt(Emp1/Emp2);%level two d0

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Energy parameter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%

        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%--cluster head and nod index extraction--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        chsIndex=find(netE.nodes.type==2 &  netE.nodes.E>0);% inital alive ch index
        chsIndexBin= (netE.nodes.type==2 &  netE.nodes.E>0);% inital alive ch index
        chsIndexBin(end)=[];

        nodIndex=find(netE.nodes.type==1 &  netE.nodes.E>0);%all normal alive nodes index


        allNodeIndex=find(netE.nodes.type==1 | netE.nodes.type==2 &  netE.nodes.E>0);%all normal alive nodes index

        k=netE.para.dhSize+netE.para.dPkSize ;%packet size
        kComp=1;(1-netE.para.dComRat);% compressed bits

        %% 1 level interface(below 40,  more than 90)
        shortDistNodeIndex= (netE.nodes.chd(allNodeIndex)<=d0);% below 40
        longDistNodeIndex= (netE.nodes.chd(allNodeIndex)>d0);% more than about 90

        %% 2 level energy consumpation(low, high) for all nodes(noraml or chs) to send unit packet, applying short distance and long distance energy consumption for all nodes
        netE.nodes.E(shortDistNodeIndex)=netE.nodes.E(shortDistNodeIndex)- (Eelec*k + Emp1*k* netE.nodes.chd(shortDistNodeIndex).^2);% short distance
        netE.nodes.E(longDistNodeIndex)=netE.nodes.E(longDistNodeIndex)-   (Eelec*k+ Emp2*k * netE.nodes.chd(longDistNodeIndex).^4); %long distance




        %finding degree of each ch node for energy consumption requirement
        chs =netE.nodes.ch([nodIndex,chsIndex]);% find all chs that are selected by normal nodes or chs
        unSelCh=chsIndex(~ismember(chsIndex,chs));% determine the unselected candidate chs by normal nodes
        chs(end+1:end+length(unSelCh))=unSelCh;% ad it to ch list
        mat=chs' * (chs./chs);% repeat css in row and make square matrix
        smat=mat./ mat';% divide this matrix to its transpose to get first stage selecrtion degree matrix
        smat(smat==1)=0;smat=~smat;% all elements that are 1 means a selection time by one of nodes
        sSeg=netE.nodes.sSeg(chs);% get the selecrtion degree of each node
        mat1=(sSeg' * (sSeg./sSeg))';% create selection degree matrix of network
        smat=smat.*mat1;%make a linier matrx multiplication between first and second stage selecrtion degree matrix
        [C,ia,ic] =unique(chs,'stable');C=C';ia=ia';ic=ic';% unique the ches index and get the first occurence of each index and unique index

        df=sum(smat,2)';% get the selecrtion degree of each ch node(sum of all columns in one column)
        grReap=df(ia);% find selecrtion degree of each ch in first occurrence of ch index using ia index

        sinkInd=C==netE.para.nodNum;% detrmin sink occurence index
        C(sinkInd)=[];% delete sing from the list
        grReap(sinkInd)=[];% and from number of selection vector
        netE.nodes.sSeg(C)=grReap;%update the selection degree of each ch


        %ch reciving energy consumption:  each ch recive n packet with k bit size
        netE.nodes.E(C)=netE.nodes.E(C)- (Eelec*k)*netE.nodes.sSeg(C);



        %ch forwarding: each ch aggregate  n packet with k bit size and   and send them with to level energy consumption
        shortDistNodeIndex=shortDistNodeIndex & chsIndexBin; % find chs that have short distance with their chs
        longDistNodeIndex=longDistNodeIndex   & chsIndexBin;% find chs that have long distance with their chs

        % applying short distance and long distance energy consumption in chs
        netE.nodes.E(shortDistNodeIndex)=netE.nodes.E(shortDistNodeIndex)- ((Eelec*k*kComp + Emp1*k*kComp.* netE.nodes.chd(shortDistNodeIndex).^2).*netE.nodes.sSeg(shortDistNodeIndex));% short distance energy consumption
        netE.nodes.E(longDistNodeIndex)=netE.nodes.E(longDistNodeIndex)-   ((Eelec*k*kComp + Emp2*k*kComp.* netE.nodes.chd(longDistNodeIndex).^4).*netE.nodes.sSeg(longDistNodeIndex));% long distance enrgy consumption

        % all nodes that their energy droped down to zero, change it to zero
        netE.nodes.E(netE.nodes.E<0)=0;

        end











