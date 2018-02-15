function [ x, y ] = countForPlot( input )
% [x,y]= countForPlot( input )
%  Output:
%   x - Data
%   y - Frequency
x=[];
y=[];
for j=min(input):max(input)
    z=0;
    for i=1:length(input)
        if(input(i)==j)
            z=z+1;
        end
        
    end
    x=[x j];
    y=[y z];
    
end
end

