
function [ eredmeny ] = szomszedsagiMatrix(str_edge,sulyozott)
%   Letrehozza a szomszedsagi matrixot a megkapott fajlbol
%   Bemenet:
%         str_edge: egy olyan fájl aminek elsõ oszlopa a source, második
%                         oszlopa target,hatodik oszopa a weights
%         sulyozott: 1 - eseten sulyozott, kulonben nem
% 
% 
% 
%   Sztancsik Dániel


 h = waitbar(0,'Please wait...','Name','Creating Adjacency Matrix');
 num = xlsread(str_edge);
 hossza=size(num);
 
 for i=1:hossza(1)
    if (isnan(num(i,1)) || isnan(num(i,2)))
%     sprintf('Nem megfelelo az excel fajl formatuma [NaN]')
    errordlg('Nem megfelelo az excel fajl formatuma [NaN]','Error');
    close(h)
    return
    end
    
end



hossza=size(num);
eredmeny=zeros(num(1,1));
meret=size(eredmeny);


for i=1:hossza(1)
    if(num(i,1)>meret)
        eredmeny=bovit(eredmeny,num(i,1));
    end
    if(num(i,2)>meret)
        eredmeny=bovit(eredmeny,num(i,2));
    end
    if (sulyozott==1)
     eredmeny(num(i,1),num(i,2))=floor(eredmeny(num(i,1),num(i,2))+num(i,6));
     

    else
        eredmeny(num(i,1),num(i,2))=1;
    end
     %eredmeny(num(i,2),num(i,1))=1
   waitbar(i / hossza(1))
    
end
close(h) 
end

function [ a ] = bovit( c , p )
%Matrix bovitese
%Input:
%c - mátrix amit boviteni kell
%p - meret amire kell boviteni
%Output: a - p X p -s c matrix
%Sztancsik Daniel
meret=size(c);
if ( meret(1)==meret(2))
    meret=meret(1);
    c=[c ; zeros(p-meret,meret)];
    meret2=size(c);
    meret2=meret2(1);
    a=[c zeros(meret2,p-meret)];

else
%     sprintf('Hiba! Nem negyzetes matrix')
    errordlg('Hiba! Nem negyzetes matrix','Error');
    close(h)
end


end
