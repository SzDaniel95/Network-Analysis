function [ C ] = closeness2( szomszedsagiMatrix )
% Closeness számítása az alabbi keplettel: C(i)=(n-1)/(SUM(L(i,j)))
% ahol L(i,j) i és j közötti legrövidebb út
% C = closeness2( Adjacency_matrix, Number_of_nodes )
% Sztancsik Dániel
% INPUT: adjacency matrix, adj
% OUTPUT: closeness centrality
% Other routines used: simple_dijkstra.m
csucsokSzama=length(szomszedsagiMatrix);
    C=zeros(1,csucsokSzama);
        for i=1:csucsokSzama
            C(i)=(csucsokSzama-1)/sum( simple_dijkstra(szomszedsagiMatrix,i));
        end

end

