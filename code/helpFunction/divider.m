%version 1.1
%isFair=1 adding points is based on distance isFair=2 adding of points based on edges
function   [X,Y]=divider(X,Y,n,isFair)



try
    if isFair==1
    else
        isFair=0 ;
    end
catch
    
isFair=0;
end
switch isFair
    case 0
T1=0;
T2=0;

for i=1:length(X)-1
    temp1=0;
    temp1=linspace(X(i),X(i+1),n+2)  ;
    
    T1=[T1,temp1(1:end-1)];
end
T1=[T1,temp1(end)];
X=T1(2:end);


for i=1:length(Y)-1
    temp2=0;
    temp2=linspace(Y(i),Y(i+1),n+2)  ;
    
    T2=[T2,temp2(1:end-1)];
end
T2=[T2,temp2(end)];
Y=T2(2:end);

    case 1

dists= sqrt( (X(2:end)-X(1:end-1)).^2 + (Y(2:end)-Y(1:end-1)).^2) ;


n1=round((dists./min(dists))*n);
T1=0;
T2=0;

for i=1:length(X)-1
  
    temp1=0;
    temp1=linspace(X(i),X(i+1),n1(i)+2)  ;
    
    T1=[T1,temp1(1:end-1)];
end
T1=[T1,temp1(end)];
X=T1(2:end);


for i=1:length(Y)-1
    temp2=0;
    temp2=linspace(Y(i),Y(i+1),n1(i)+2)  ;
    
    T2=[T2,temp2(1:end-1)];
end
T2=[T2,temp2(end)];
Y=T2(2:end);
end


end