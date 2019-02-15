        %% at the end of work this action should be done
        % speling check:no
        % ordering and section and regulation of all code:yes
        % make an output folder and save the output charts and statistical variable in it:yes
        % explain all lines of codes:yes
        % making sure that all lines of code writed as standard:yes
        

        %% clear commands
        delete(allchild(0));% delete all figures and graphical objects
        clear;% Remove items from workspace, freeing up system memory
        clc;% clear the Console

        %% path commands
        file=matlab.desktop.editor.getActive;% get current script address
        try % if dont occur any error this block will run
            fileDetail=dir(file.Filename);% get current script details
            folderName=fileDetail.folder;% get current script folder name
        catch% else if an  error occurs then
            index=strfind( file.Filename,'\');% find index of back space(\) in path text
            folderName=file.Filename(1:index(end)-1);% select all path text from 1 to last Occurrence of \ as script folder name
        end
        paths=genpath(folderName);% make current path and all sub paths
        addpath(paths);% add all paths in known paths of matlab
        cd(folderName);% go to path that current script runned from that


        %% net building  commands
        net=[];% create an empty var as net object
        net.para.width=100;% width param of net
        net.para.length=100;% width param of net
        net.para.height=5;% width param of net
        net.para.side=4;% side of Polygon
        net.para.nodNum=300 ;net.para.nodNum=net.para.nodNum+1; % number of nodes of net work
        net.para.simPer=1500;% number of simulation period
        net.para.sInd=0;%period counter

        ph=pi/net.para.side;% used for shifting of area to be Attractive!
        t=linspace(0,1,net.para.side+1);% Generate linearly spaced vector( used for making polygon)
        x1=sin(2*pi*t+ph); x1=(((x1-min(x1))/(max(x1)-min(x1)))-0.5)* net.para.length;% x coordinate of area(after normalising)
        y1=-cos(2*pi*t+ph);y1=(((y1-min(y1))/(max(y1)-min(y1)))-0.5)*net.para.width;% y coordinate of area(after normalising)
        [x1,y1]=divider(x1,y1,200);% adding points between each pair of vertices
        scatter(x1,y1)


        %% special parameters of current work
        net.para.E0=1;%initial  energy parameter
        net.para.Cprob=0.05;%initial  ch probablity  parameter(LEAH,HEED,BEE,BEEM)
        net.para.pMin=10^-4;%minimum ch probablity
        net.para.R=25;% communication range
        net.para.sR=10;% sensing range
        
        net.para.dPkSize=100*8;%Data packet size
        net.para.brPkSize=25*8;%Broadcast packet size
        net.para.dhSize=25*8;%Data header size
        net.para.dComRat=0.8;%CH data compress rate
        net.para.chIt=0;% number of iteration in each network
        
    
        net.para.cmMeans.names={'NAI1','NAI2','NAI3','NAI4','NAI5' };% name of mean
        net.para.cmMeans.tr=[10,20,40,25,1000];%range of mean
        
        net.para.deAccIF.names=net.para.cmMeans.names{5};%Default acess interface
        net.para.deAccIF.tr=net.para.cmMeans.tr(5);%Default acess interface range

        
        
            
        t=linspace(0,1,50+1);% Generate linearly spaced vector( used for making polygon)
        net.para.Rx=sin(2*pi*t); net.para.Rx=(((net.para.Rx-min(net.para.Rx))/(max(net.para.Rx)-min(net.para.Rx)))-0.5)* net.para.R*2;% x coordinate of area(after normalising)
        net.para.Ry=cos(2*pi*t); net.para.Ry=(((net.para.Ry-min(net.para.Ry))/(max(net.para.Ry)-min(net.para.Ry)))-0.5)* net.para.R*2;% x coordinate of area(after normalising)
        
        
       
        
        
        %% initialisation
        r1=rand(1,net.para.nodNum); % random  number for x and y coordinates
        r2=randi(length(x1),1,net.para.nodNum);% intiger random  number for border x selection(is used for throwing in net area);
        r3=rand(1,net.para.nodNum);% random  number for z coordinates


        net.nodes.x=(sqrt(r1).*x1(r2))+(net.para.length/2);%x coordinates distribution
        net.nodes.y=(sqrt(r1).*y1(r2))+(net.para.width/2);%y coordinates distribution
        scatter(net.nodes.x, net.nodes.y);
        net.nodes.z=r3*net.para.height*0;%z coordinates distribution(here we set it to zero for all nodes)
        net.ind=1:net.para.nodNum;%index of nodes
        net.nInd=1:net.para.nodNum-1;% index of ch and normal nodes
        net.nodes.type=0*(net.ind)+1;% 1= normal , 2= cluster head.
        net.nodes.E=0*(net.ind)+((1-0.5).*rand(1,net.para.nodNum) + 0.5);% initial energy of  each node
        net.nodes.R=0*(net.ind)+net.para.R;%% communication range of each node
        net.nodes.Cprob=0*(net.ind)+net.para.Cprob;%initial ch probablity  parameter for each node
        net.nodes.Chprob = net.nodes.Cprob.* (net.nodes.E./net.para.E0);%dinamic ch probablity  parameter for each node
        net.nodes.ch=net.ind;% all nodes select itself as ch;
        net.nodes.chd=0*net.ind;% distance of each node from it's ch;
        net.nodes.deg=0*net.ind+1;% number of nodes that are in communication area of each node
        net.nodes.sSeg=0*net.ind+1;% number of nodes that select current node as ch

        
        net.nodes.x(end)=50;% sink x position
        net.nodes.y(end)=175;% sink y position
        net.nodes.type(end)=3;% sink type
        scatter(net.nodes.x,net.nodes.y)

        net.netDist=pdist2( [net.nodes.x;net.nodes.y]',[net.nodes.x;net.nodes.y]');%distance between all nodes

 
        %% base figure commands
        sc=get(0,'screensize');% get the screen information
        sc(1)=sc(1)+50;sc(2)=sc(2)+50;sc(3)=sc(3)-200;sc(4)=sc(4)-200;% make a custome screen
        baseFig=figure('name',['iot(LEACH,HEED,BEE,BEEM,smarBEEM,selfConcern)' ' area:' num2str(net.para.length) 'x'  num2str(net.para.length) ...
            ' nodes: ' num2str(net.para.nodNum-1) 'round: ' num2str(1) ],'NumberTitle','off','Position',sc);% make framework figure as base figure
%         H1=axes(baseFig);
%         H2=axes(baseFig);
%         H3=axes(baseFig);
%         H4=axes(baseFig);
%         H5=axes(baseFig);
%         H6=axes(baseFig);
        
        % making 6 subplot for 6 algorithm
        hs1=subplot(2,3,1);
        hs2=subplot(2,3,2); 
        hs3=subplot(2,3,3);
        hs4=subplot(2,3,4); 
        hs5=subplot(2,3,5); 
        hs6=subplot(2,3,6);
        
        
       % making common center circle as signal strength
        maxDist=ceil(sqrt(net.nodes.x(end)^2 +net.nodes.y(end)^2)); % find max distance between sink and origin(0,0)
        maxDist=maxDist+10-(mod(maxDist,10));% round ou it with 10 unit(e.g 184 -> 190)
        sLayer.t=linspace(0,2*pi,50); % make a circle with 50 point on it
        
        sLayer.sX=sin( sLayer.t);sLayer.sX=normalVect(sLayer.sX,-.5,.5);%single area unit x
        sLayer.sY=-cos(sLayer.t);sLayer.sY=normalVect(sLayer.sY,-.5,.5);%single area unit y

        net.sLayer.r= min(net.para.cmMeans.tr): min(net.para.cmMeans.tr):maxDist*2 ;% makeing Variable Radius vector
        net.sLayer.sX=(net.sLayer.r' *sLayer.sX)'+net.nodes.x(end);%concentric zone x
        net.sLayer.sY=(net.sLayer.r' *sLayer.sY)' +net.nodes.y(end);%concentric zone  y
                
        
        
        
        
        
        
        
        
        %% simulation
         net.baseFig=baseFig;% copy handle of  base figure into net base figure agent( it is a refrence type)

        [net.gridx,net.gridy]=meshgrid(0:10:net.para.length,0:10:net.para.width);% make a grid mesh with 10 meter distance
        [net.gridCx,net.gridCy]=meshgrid(5:10:net.para.length,5:10:net.para.width);% make another grid mesh as the center of above grid mesh( this tow grid are used for detection nodes position cell)
        net.gridCx=net.gridCx(:)';% convert x grid matrix to vector x coordinate
        net.gridCy=net.gridCy(:)';% convert y grid matrix to vector y coordinate
 
        % function 1: will converte  to a function
        net.gridDist=pdist2( [net.nodes.x(1:end-1),net.gridCx ;net.nodes.y(1:end-1),net.gridCy ]',[net.nodes.x(1:end-1),net.gridCx ;net.nodes.y(1:end-1),net.gridCy ]');%distance between all nodes with grid center points
        net.gridDist=net.gridDist(net.nInd,net.para.nodNum:end);% crop required section of distande matrix
        [M,I]=min(net.gridDist,[],2);% here we used an simple algorithm to determine each node in network is belong to which cell in grid network
        coverage=  unique(I);% if we unique the number of centers that are selected  by normal nodes, based on minimum distance, in reality we get the number coverage area
        
        % statictical variables for gathering information abate networks performance and etc.
        net.st.chIt=[];% number of ch iteration
        net.st.ch=[];%  ch percentage
        net.st.alive=[];% number of ch alive nodes
        net.st.rE=[];% residual energy
        net.st.aE=[];% average energy
        net.st.coverage=[];%coverage of each network in each period
        
        % option of simulation
        net.disp=1; % if disp information in simulation time or not( 1= yes, 0 no thanks!)
        net.plot=0;% if network graphically in simulation time or not( 1= yes, 0 no)
        
        %copy prototype of base net,  on 7 networks, for running algorithms on them, they can distinguished by names easy
        DIRnet=net;DIRnet.id=1;
        LEACHnet=net;LEACHnet.id=1;
        HEEDHnet=net;HEEDHnet.id=2;
        BEEnet=net;BEEnet.id=3;
        BEEMnet=net;BEEMnet.id=4;
        smartBEEMnet=net;smartBEEMnet.id=5;
        SELFCONnet=net;SELFCONnet.id=6;
       
         for sInd=1:net.para.simPer
             
             delete(net.baseFig.Children)% each period all of subplot  are deleted and are drawn in continue
             net.baseFig.Name=['iot(LEACH,HEED,BEE,BEEM,smarBEEM,selfConcern)' ' area:' num2str(net.para.length) 'x'  num2str(net.para.length) ...
                 ' nodes: ' num2str(net.para.nodNum-1) 'round: ' num2str(sInd) ]; % in each period figure name is update with new period number
             % 6 algorithm are run consecutively and the results are update for nexs period as input and output
             %                DIRnet.para.sInd=sInd;       DIRnet=DIRECT(DIRnet);% if direct network is selected then unselect BEE, if you want to see plot mode other wise u can run all algorithm in same time
             LEACHnet.para.sInd=sInd;       LEACHnet=LEACH(LEACHnet);
             HEEDHnet.para.sInd=sInd;       HEEDHnet=HEED(HEEDHnet);
             BEEnet.para.sInd=sInd;         BEEnet=BEE(BEEnet);
             BEEMnet.para.sInd=sInd;         BEEMnet=BEEM(BEEMnet);
             smartBEEMnet.para.sInd=sInd;   smartBEEMnet=smartBEEM(smartBEEMnet);
             SELFCONnet.para.sInd=sInd;     SELFCONnet=SELFCON(SELFCONnet);
             
             % display period number and part each period with Discontinued line and return it new line
             disp(['round: ' num2str(sInd)  '  ---------------------------------------------' 10 ]);
             
             
             
             pause(0.005); %  is used for stop running for piece of time
        end
        
        
        %% save all network
        
        %% plot output
        iterH=figure('name','iteration number','NumberTitle','off' );
        plot(LEACHnet.st.chIt,'r','tag','LEACH');hold on;
        plot(HEEDHnet.st.chIt,'g','tag','HEED');hold on;
        plot(BEEnet.st.chIt,'b','tag','BEE');hold on;
        plot(BEEMnet.st.chIt,'c','tag','BEEM');hold on;
        plot(smartBEEMnet.st.chIt,'m','tag','smartBEEM');hold on;
        plot(SELFCONnet.st.chIt,'k','tag','SELFCON');hold on;
      
        xlabel('round');ylabel('iteration number');title('iteration number');
        legend(iterH.Children(1) , flip({iterH.Children(1).Children.Tag}) ); hold on

        
        
        
        chPerH=figure('name','ch percentage','NumberTitle','off' );
        plot(LEACHnet.st.ch,'r','tag','LEACH');hold on;
        plot(HEEDHnet.st.ch,'g','tag','HEED');hold on;
        plot(BEEnet.st.ch,'b','tag','BEE');hold on;
        plot(BEEMnet.st.ch,'c','tag','BEEM');hold on;
        plot(smartBEEMnet.st.ch,'m','tag','smartBEEM');hold on;
        plot(SELFCONnet.st.ch,'k','tag','SELFCON');hold on;
        
        xlabel('round');ylabel('ch percentage');title('ch percentage')
        legend(chPerH.Children(1) , flip({chPerH.Children(1).Children.Tag}) ); hold on
        
        
             
        covH=figure('name','coverage','NumberTitle','off' );
        plot(LEACHnet.st.coverage,'r','tag','LEACH');hold on;
        plot(HEEDHnet.st.coverage,'g','tag','HEED');hold on;
        plot(BEEnet.st.coverage,'b','tag','BEE');hold on;
        plot(BEEMnet.st.coverage,'c','tag','BEEM');hold on;
        plot(smartBEEMnet.st.coverage,'m','tag','smartBEEM');hold on;
        plot(SELFCONnet.st.coverage,'k','tag','SELFCON');hold on;
        
        xlabel('round');ylabel('coverage');title('coverage')
        legend(covH.Children(1) , flip({covH.Children(1).Children.Tag}) ); hold on
        
        
        
        
        
        
        AliveNodH=figure('name','alive nodes','NumberTitle','off' );
        plot(LEACHnet.st.alive,'r','tag','LEACH');hold on;
        plot(HEEDHnet.st.alive,'g','tag','HEED');hold on;
        plot(BEEnet.st.alive,'b','tag','BEE');hold on;
        plot(BEEMnet.st.alive,'c','tag','BEEM');hold on;
        plot(smartBEEMnet.st.alive,'m','tag','smartBEEM');hold on;
        plot(SELFCONnet.st.alive,'k','tag','SELFCON');hold on;
        
        xlabel('round');ylabel('alive nodes');title('alive nodes')
        legend(AliveNodH.Children(1) , flip({AliveNodH.Children(1).Children.Tag}) ); hold on
        
        
      
        
        resEnH=figure('name','residual Energy','NumberTitle','off' );
        plot(LEACHnet.st.rE,'r','tag','LEACH');hold on;
        plot(HEEDHnet.st.rE,'g','tag','HEED');hold on;
        plot(BEEnet.st.rE,'b','tag','BEE');hold on;
        plot(BEEMnet.st.rE,'c','tag','BEEM');hold on;
        plot(smartBEEMnet.st.rE,'m','tag','smartBEEM');hold on;
        plot(SELFCONnet.st.rE,'k','tag','SELFCON');hold on;
        
        xlabel('round');ylabel('residual Energy');title('residual Energy')
        legend(resEnH.Children(1) , flip({resEnH.Children(1).Children.Tag}) ); hold on
        
        
        
        AvEnH=figure('name','avrage Energy','NumberTitle','off' );
            plot(LEACHnet.st.aE,'r','tag','LEACH');hold on;
        plot(HEEDHnet.st.aE,'g','tag','HEED');hold on;
        plot(BEEnet.st.aE,'b','tag','BEE');hold on;
        plot(BEEMnet.st.aE,'c','tag','BEEM');hold on;
        plot(smartBEEMnet.st.aE,'m','tag','smartBEEM');hold on;
        plot(SELFCONnet.st.aE,'k','tag','SELFCON');hold on;
        
        xlabel('round');ylabel('avrage Energy');title('avrage Energy');
        legend(AvEnH.Children(1) , flip({AvEnH.Children(1).Children.Tag}) ); hold on
        

        
        
        

      
      
        
        
        
        
        
        
        
        %% save all figures
        saveas(baseFig, [ folderName '/outPut/baseFig_' num2str(net.para.nodNum) '_' num2str(net.para.length) ' x ' num2str(net.para.width)])
        saveas(iterH, [ folderName '/outPut/iterH' num2str(net.para.nodNum) '_' num2str(net.para.length) ' x ' num2str(net.para.width)])
        saveas(chPerH, [ folderName '/outPut/chPerH' num2str(net.para.nodNum) '_' num2str(net.para.length) ' x ' num2str(net.para.width)])
        saveas(AliveNodH, [ folderName '/outPut/AliveNodH' num2str(net.para.nodNum) '_' num2str(net.para.length) ' x ' num2str(net.para.width)])
        saveas(resEnH, [ folderName '/outPut/resEnH' num2str(net.para.nodNum) '_' num2str(net.para.length) ' x ' num2str(net.para.width)])
        saveas(AvEnH, [ folderName '/outPut/AvEnH' num2str(net.para.nodNum) '_' num2str(net.para.length) ' x ' num2str(net.para.width)])
        saveas(covH, [ folderName '/outPut/covH_' num2str(net.para.nodNum) '_' num2str(net.para.length) ' x ' num2str(net.para.width)])
        
        
        %% save each network separately
        %         save([ folderName '/outPut/net_' num2str(net.para.nodNum) '_' num2str(net.para.length) ' x ' num2str(net.para.width)],'net')
        %         save([ folderName '/outPut/DIRnet_' num2str(net.para.nodNum) '_' num2str(net.para.length) ' x ' num2str(net.para.width)],'DIRnet')
        %         save([ folderName '/outPut/LEACHnet_' num2str(net.para.nodNum) '_' num2str(net.para.length) ' x ' num2str(net.para.width)],'LEACHnet')
        %         save([ folderName '/outPut/HEEDHnet_' num2str(net.para.nodNum) '_' num2str(net.para.length) ' x ' num2str(net.para.width)],'HEEDHnet')
        %         save([ folderName '/outPut/BEEnet_' num2str(net.para.nodNum) '_' num2str(net.para.length) ' x ' num2str(net.para.width)],'BEEnet')
        %         save([ folderName '/outPut/BEEMnet_' num2str(net.para.nodNum) '_' num2str(net.para.length) ' x ' num2str(net.para.width)],'BEEMnet')
        %         save([ folderName '/outPut/smartBEEMnet_' num2str(net.para.nodNum) '_' num2str(net.para.length) ' x ' num2str(net.para.width)],'smartBEEMnet')
        %         save([ folderName '/outPut/SELFCONnet_' num2str(net.para.nodNum) '_' num2str(net.para.length) ' x ' num2str(net.para.width)],'SELFCONnet')
                save([ folderName '/outPut/net_' num2str(net.para.nodNum) '_' num2str(net.para.length) 'x' num2str(net.para.width)]);

        
        clc;
        








