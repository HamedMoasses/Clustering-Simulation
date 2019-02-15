
% give a vector or matrix for normalizing between tow number or 0 and 1
% vect=normalVect([1,-2,4,1,11,4,5])
% vect=normalVect([1,-2,4,1,11,4,5],-2,1)
% vect=normalVect([1,-2,4;11,4,5])

function vect=normalVect(varargin)
if nargin==0
    msgbox('give a 1 argoment atleast');
    vect=[];
elseif ~isnumeric(varargin{1})
    msgbox('abnormal argoment');
    vect=[];
else
   vect=varargin{1}; 
if nargin==1
    vect=(vect-min(vect(:)))./(max(vect(:))-min(vect(:)));
elseif nargin==3 ||  nargin>3
    if varargin{2}~=varargin{3}
        vect=(vect-min(vect(:)))./(max(vect(:))-min(vect(:)));
        vMin=min([varargin{2},varargin{3}]);
        vMax=max([varargin{2},varargin{3}]);
        vDif=vMax-vMin;
        vect=(vect*vDif)+vMin;
        if nargin>3
            msgbox('we used 3 argoment only');
        end
    else
        vect=(vect-min(vect(:)))./(max(vect(:))-min(vect(:)));
        msgbox('abnormal limits: normaled 0: 1');
    end
end

end
end