function [ C ] = closeness2( szomszedsagiMatrix )
% Closeness sz�m�t�sa az alabbi keplettel: C(i)=(n-1)/(SUM(L(i,j)))
% ahol L(i,j) i �s j k�z�tti legr�videbb �t
% C = closeness2( Adjacency_matrix, Number_of_nodes )
% Sztancsik D�niel
% INPUT: adjacency matrix, adj
% OUTPUT: closeness centrality
% Other routines used: simple_dijkstra.m
csucsokSzama=length(szomszedsagiMatrix);
    C=zeros(1,csucsokSzama);
        for i=1:csucsokSzama
            C(i)=(csucsokSzama-1)/sum( simple_dijkstra(szomszedsagiMatrix,i));
        end

end

