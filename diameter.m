function value = diameter(adj)
% Atmero szamitas az excentralitasbol
% INPUT: adjacency matrix, adj
% OUTPUT: diameter
% Other routines used: vertex_eccentricity.m
value=max( vertex_eccentricity(adj) );

end