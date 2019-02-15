function [groupN,grValue,grReap]=groupLable(trainLable)

 
groupN=0;
while(~isempty(trainLable))
    groupN=groupN+1;

    gr=(trainLable==trainLable(1));
    groupCluster(groupN).reap=sum(gr);
    groupCluster(groupN).grValue=trainLable(1);
    trainLable=trainLable(~gr);
end
grValue=([groupCluster.grValue]);
grReap=([groupCluster.reap]);
end