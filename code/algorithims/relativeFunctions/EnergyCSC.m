
        %energy consumpation for selfConcern_mimo comunication
        % mimo features
        % d01=40;  d02=90 about;
        % 3 level energy consumpation(low, medium,  high)
        % 2 level bandwidth(low, high )
        % multi interface(below 40, between 40 and 90, more than 90)

        function netE=EnergyCSC(netE)
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Energy parameter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ETX=50*0.000000001;
        ERX=50*0.000000001;
        Eelec=ETX;  %Transmission/Receiving (Eelect)

        %Transmit Amplifier types
        Emp1=10*0.000000000001;% low power
        Emp2=15*0.000000000001;% low power
        Emp3=0.0013*0.000000000001;% heigh power
        %Data Aggregation Energy
        d01=40;%level one d0
        d02=sqrt(Emp1/Emp3);%level two d0

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Energy parameter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%

        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%--cluster head and nod index extraction--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        chsIndex=find(netE.nodes.type==2 &  netE.nodes.E>0);% inital alive ch index
        chsIndexBin= (netE.nodes.type==2 &  netE.nodes.E>0);% inital alive ch index
        chsIndexBin(end)=[];
        
        nodIndex=find(netE.nodes.type==1 &  netE.nodes.E>0);%all normal alive nodes index
        allNodeIndex=find(netE.nodes.type==1 | netE.nodes.type==2 &  netE.nodes.E>0);%all normal alive nodes index

        k=netE.para.dhSize+netE.para.dPkSize  ;%packet size
        kComp=(1-netE.para.dComRat) ;% compressed bits
        kLow=0.9 ;%low data rate
        klOWcOMP= kComp * kLow;

        %% this section will convert to a function named unqueDEg(find uniqe number and repeation of each)
        %ch degree finding
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




        %% 2 level data Rate(low, high)
        % low data Rate cofficient
        dataRateCriteria=50*k;% below  or equal 6 kilo byte bit is low and
        lowDataRateInd= ( k*netE.nodes.sSeg(allNodeIndex)<=dataRateCriteria);% below 40
        heighDataRateInd= (k*netE.nodes.sSeg(allNodeIndex)>dataRateCriteria);% more than about 90
        
        %% 3 level interface(below 40, between 40 and 90, more than 90)
        shortDistNodeIndex= (netE.nodes.chd(allNodeIndex)<=d01);% below 40
        mediumDistNodeIndex= ((netE.nodes.chd(allNodeIndex)>d01) & (netE.nodes.chd(allNodeIndex)<=d02)  ); % between 40 and about 90
        longDistNodeIndex= (netE.nodes.chd(allNodeIndex)>d02);% more than about 90
        
        % make 6 type means to do 6 ranking interface for different condition: 2 level data rate ,3 level distance based(we changed here a little to adapt it with logic)
        NAI11_Ind=allNodeIndex(lowDataRateInd &  shortDistNodeIndex);% low data rate, short distance
        NAI12_Ind=allNodeIndex(lowDataRateInd &  mediumDistNodeIndex);% low data rate, medium distance
        NAI3_Ind=allNodeIndex(lowDataRateInd &   longDistNodeIndex);% low data rate, long distance
        
        NAI4_Ind=allNodeIndex(heighDataRateInd & shortDistNodeIndex);% heigh data rate, short distance
        NAI5_Ind=allNodeIndex(heighDataRateInd & mediumDistNodeIndex);% % heigh data rate, medium distance
        NAI6_Ind=allNodeIndex(heighDataRateInd & longDistNodeIndex);%% heigh data rate, long distance
        
        %% 3 level energy consumpation(low, medium, high) with 2 level data rate for all nodes to sed unit packet 

        netE.nodes.E(NAI11_Ind)=netE.nodes.E(NAI11_Ind)- (Eelec*k*kLow  + Emp1*k*kLow.* netE.nodes.chd(NAI11_Ind).^2) ;% short distance and low data energy consumption
        netE.nodes.E(NAI12_Ind)=netE.nodes.E(NAI12_Ind)- (Eelec*k*kLow + Emp2*k*kLow.* netE.nodes.chd(NAI12_Ind).^2);% mediume distance   and low data energy consumption
        netE.nodes.E(NAI3_Ind)=netE.nodes.E(NAI3_Ind)-   (Eelec*k*kLow + Emp3*k*kLow.* netE.nodes.chd(NAI3_Ind).^4);% long distance  and low data energy consumption
        
        netE.nodes.E(NAI4_Ind)=netE.nodes.E(NAI4_Ind)- (Eelec*k + Emp1*k.* netE.nodes.chd(NAI4_Ind).^2);% short distance and heigh data energy consumption
        netE.nodes.E(NAI5_Ind)=netE.nodes.E(NAI5_Ind)- (Eelec*k + Emp2*k.* netE.nodes.chd(NAI5_Ind).^2);% mediume distance   and heigh data energy consumption
        netE.nodes.E(NAI6_Ind)=netE.nodes.E(NAI6_Ind)-  (Eelec*k + Emp3*k.* netE.nodes.chd(NAI6_Ind).^4);% long distance  and heigh data energy consumption
        
        
        
          % base
%         Communication Means       Data Rate                Transmission Range    Energy Consumption
%              NAI1                    Low                       10 m                  Low
%              NAI2                    Low                       20 m                  Low
%              NAI3                    Low                       40 m                  Medium
%              NAI4                    High                      25 m                  High
%              NAI5                    High                      1 km                  High
        
% Changed
%         Communication Means       Data Rate                Transmission Range    Energy Consumption
%              NAI1                    Low                       10 m                   Low
%              NAI2                    Low                       20 m                   Low
%              NAI3                    Low                   (bet 40 and90) 40 m        Medium
%              NAI4                    High                  (bet 40 and90) 40 m        Medium
%              NAI5                    High                      40m (25 in paper)      High
%              NAI6                    High                      1 km                   High

 

        %ch forwarding: each ch aggrigate n packet with k bit size and compress them by %80 for long distance and 10% for low dat rate
        NAI11_Ind=allNodeIndex(lowDataRateInd &  shortDistNodeIndex & chsIndexBin);% find chs that have short distance, low data
        NAI12_Ind=allNodeIndex(lowDataRateInd &  mediumDistNodeIndex & chsIndexBin);% find chs that have medium distance ,low data
        NAI3_Ind=allNodeIndex(lowDataRateInd &   longDistNodeIndex & chsIndexBin);% find chs that have long distance ,low data
        
        NAI4_Ind=allNodeIndex(heighDataRateInd & shortDistNodeIndex & chsIndexBin);% find chs that have short distance , heigh data
        NAI5_Ind=allNodeIndex(heighDataRateInd & mediumDistNodeIndex & chsIndexBin);% find chs that have medium distance , heigh data
        NAI6_Ind=allNodeIndex(heighDataRateInd & longDistNodeIndex & chsIndexBin);% find chs that have long distance , heigh data
        
        
        % applying short distance,medium and long distance  with low and heigh data energy consumption in chs
        netE.nodes.E(NAI11_Ind )=netE.nodes.E(NAI11_Ind)-  (Eelec*k*klOWcOMP + Emp1*k*klOWcOMP.* netE.nodes.chd(NAI11_Ind).^2).*netE.nodes.sSeg(NAI11_Ind);
        netE.nodes.E(NAI12_Ind)=netE.nodes.E(NAI12_Ind)-   (Eelec*k*klOWcOMP + Emp2*k*klOWcOMP.* netE.nodes.chd(NAI12_Ind).^2).*netE.nodes.sSeg(NAI12_Ind);
        netE.nodes.E(NAI3_Ind)=netE.nodes.E(NAI3_Ind)-     (Eelec*k*klOWcOMP + Emp3*k*klOWcOMP.* netE.nodes.chd(NAI3_Ind).^4).*netE.nodes.sSeg(NAI3_Ind);
        
        netE.nodes.E(NAI4_Ind )=netE.nodes.E(NAI4_Ind)-    (Eelec*k*kComp + Emp1*k*kComp.* netE.nodes.chd(NAI4_Ind).^2).*netE.nodes.sSeg(NAI4_Ind);
        netE.nodes.E(NAI5_Ind)=netE.nodes.E(NAI5_Ind)-     (Eelec*k*kComp + Emp2*k*kComp.* netE.nodes.chd(NAI5_Ind).^2).*netE.nodes.sSeg(NAI5_Ind);
        netE.nodes.E(NAI6_Ind)=netE.nodes.E(NAI6_Ind)-     (Eelec*k*kComp + Emp3*k*kComp.* netE.nodes.chd(NAI6_Ind).^4).*netE.nodes.sSeg(NAI6_Ind);
        
        % all nodes that their energy droped down to zero, change it to zero
        netE.nodes.E(netE.nodes.E<0)=0;

        end











