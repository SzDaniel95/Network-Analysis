function [ ret, elapsedTime ] = autoNetworkAnalyser( varargin )
%     'Debrecen_w1_edges.csv'
%     'Gyor_w1_edges.csv'
%     'Miskolc_w1_edges.csv'
%     'Pecs_w1_edges.csv'
%     'Szeged_w1_edges.csv'
%
%     System Requirements: MATLAB R2016a
%     Inputs: str_edge - .csv/.xlsx file with edges
%     Output: ret is a Table with data
%             elapsedTime is elapsed time in second   
%
%     Usage:
%     [data,time]=autoNetworkAnalyser('Szeged_w1_edges.csv','Miskolc_w1_edges.csv','Pecs_w1_edges.csv','Debrecen_w1_edges.csv','Gyor_w1_edges.csv')
%     data=autoNetworkAnalyser('Szeged_w1_edges.csv')
%
%   Functions from these sites:
%   https://www.mathworks.com/help/matlab/graph-and-network-algorithms.html
%   http://strategic.mit.edu/downloads.php?page=matlab_networks
%   https://sites.google.com/site/bctnet/measures/list
%   
%
%   Author: Sztancsik Dániel

       tic;% Start timer
       format long;
       if(nargin==0)
           errordlg('Nem adtal meg fajlt !','Fajl Hiba');
           return
       end
       for i=1:nargin
           if(exist(varargin{i},'file')==0)
               errordlg('Nem letezo fajlt adtal meg!','Fajl Hiba');
               return
           end
       end
       if(nargin > 7)
           errordlg('Maximum 7 fajl adhato meg!','Hiba');
           return
       end
       

       %% Városnevek kinyerése a fájlnevekbõl
       inputCity=cell(1,nargin);
       for i=1:nargin
           C = strsplit(varargin{i},'_');
           inputCity(i)=C(1);
       end
       
       %% Plot
%        7 fele plotolas lehetseges
%            'b-o'
%            'm-+'
%            'c-*'
%            'r-^'
%            'g-x'
%            'k-s'
%            'y-d'
           plotColor='bmcrgky';
           plotMarker='o+*^xsd';
       %% Szomszédsági mátrix
       for i = 1:nargin
           %súlyozott
           data=szomszedsagiMatrix(varargin{i},1);
           currentVar = sprintf('adjMatrixW%d',i);
           assignin('base', currentVar, data);
           %súlyozatlan:
           data=weight_conversion(data, 'binarize');
           currentVar = sprintf('adjMatrixUW%d',i);
           assignin('base', currentVar, data);
       end
       
        %% Graf legenerálás
        h = waitbar(0,'Please wait...','Name','Creating Graph Object');
        for i = 1:nargin
            currentVar = sprintf('adjMatrixW%d',i);
            adjMatrix=evalin('base', currentVar);
            data = digraph(adjMatrix);
            currentVar = sprintf('G%d',i);
            assignin('base', currentVar, data);
            waitbar(i / nargin)
        end
        close(h)
        
       %% Alapvetõ adatok
       h = waitbar(0,'Please wait...','Name','Computing');
       elekSzama=zeros(nargin,1);
       csucsokSzama=zeros(nargin,1);
       avgDegree=zeros(nargin,1);
       for i = 1:nargin
           currentVar = sprintf('adjMatrixUW%d',i);
           adjMatrix=evalin('base', currentVar);
           elekSzama(i)=nnz(adjMatrix);
           csucsokSzama(i)=size(adjMatrix,1);
           avgDegree(i)=(2*elekSzama(i))/csucsokSzama(i);
           waitbar(i / nargin)
       end
       close(h)
       %% Atmero
       h = waitbar(0,'Please wait...','Name','Diameter');
       atmero=zeros(nargin,1);
       for i = 1:nargin
           currentVar = sprintf('adjMatrixUW%d',i);
           adjMatrix=evalin('base', currentVar);
           atmero(i)=diameter(adjMatrix);
           waitbar(i / nargin)
       end
       close(h)
      %% Sugar
       h = waitbar(0,'Please wait...','Name','Radius');
       radius=zeros(nargin,1);
       for i = 1:nargin
           currentVar = sprintf('adjMatrixUW%d',i);
           adjMatrix=evalin('base', currentVar);
           radius(i)=graph_radius(adjMatrix);
           waitbar(i / nargin)
       end
       close(h)
      %% Atlagos legrovidebb uthossz
       h = waitbar(0,'Please wait...','Name','Average path length');
       avgPathLength=zeros(nargin,1);
       for i = 1:nargin
           currentVar = sprintf('adjMatrixUW%d',i);
           adjMatrix=evalin('base', currentVar);
           avgPathLength(i)=ave_path_length(adjMatrix);
           waitbar(i / nargin)
       end
       close(h)
       %% Graf suruseg
       h = waitbar(0,'Please wait...','Name','Density');
       density=zeros(nargin,1);
       for i = 1:nargin
           currentVar = sprintf('adjMatrixUW%d',i);
           adjMatrix=evalin('base', currentVar);
           density(i)=density_dir(adjMatrix);
           waitbar(i / nargin)
       end
       close(h)
       %% Core/Periphery
       h = waitbar(0,'Please wait...','Name','Core/Periphery');
       corePeriphery=zeros(nargin,1);
       for i = 1:nargin
           currentVar = sprintf('adjMatrixW%d',i);
           adjMatrix=evalin('base', currentVar);
           [~,corePeriphery(i)]=core_periphery_dir(adjMatrix);
           waitbar(i / nargin)
       end
       close(h)
       %% Clustering coefficient
       h = waitbar(0,'Please wait...','Name','Clustering coefficient');
       f = figure('Visible','off');
       hold on
       clusteringCoefficientAVG=zeros(nargin,1);
       for i = 1:nargin
           currentVar = sprintf('adjMatrixW%d',i);
           adjMatrix=evalin('base', currentVar);
           cCoefficient=clustering_coef_wd(weight_conversion(adjMatrix, 'normalize'));
           clusteringCoefficientAVG(i)=mean(cCoefficient);
           cCoefficient=(sort(cCoefficient,'descend'));
           currentVar = sprintf('%c-%c',plotColor(i),plotMarker(i));
           loglog(cCoefficient,currentVar)
           waitbar(i / nargin)
       end
       title('Clustering coefficient')
       xlabel('k')
       ylabel('C(k)')
       legend(inputCity,'FontSize',14)
       hold off
       close(h)
       figure(f)
       %% Degree distribution
       h = waitbar(0,'Please wait...','Name','Degree distribution');
       f = figure('Visible','off');
       hold on
       for i = 1:nargin
           currentVar = sprintf('G%d',i);
           G = evalin('base', currentVar);
           degreeDistribution=indegree(G)+outdegree(G);
           currentVar = sprintf('%c-%c',plotColor(i),plotMarker(i));
           [ x, y ] = countForPlot( degreeDistribution );
           plot(x,y,currentVar)
           waitbar(i / nargin)
       end
       
       title('Degree distribution')
       xlabel('Degree')
       ylabel('Frequency')
       legend(inputCity,'FontSize',14)
       hold off
       close(h)
       figure(f)
       %% Eccentricity
       h = waitbar(0,'Please wait...','Name','Eccentricity');
       f = figure('Visible','off');
       hold on
       for i = 1:nargin
           currentVar = sprintf('adjMatrixUW%d',i);
           adjMatrix=evalin('base', currentVar);
           data=vertex_eccentricity(adjMatrix);
           currentVar = sprintf('%c-%c',plotColor(i),plotMarker(i));
           [ x, y ] = countForPlot( data );
           plot(x,y,currentVar)
           waitbar(i / nargin)
       end
       
       title('Vertex eccentricity')
       ylabel('Frequency')
       xlabel('Eccentricity')
       legend(inputCity,'FontSize',14)
       hold off
       close(h)
       figure(f)
       %% Betweenness - unweighted
       h = waitbar(0,'Please wait...','Name','Betweenness centrality');
       f = figure('Visible','off');
       hold on
       for i = 1:nargin
           currentVar = sprintf('G%d',i);
           G = evalin('base', currentVar);
           betweenness_centrality=centrality(G,'betweenness');
           betweenness_centrality=(sort(betweenness_centrality,'descend'));
           currentVar = sprintf('%c-%c',plotColor(i),plotMarker(i));
           loglog(betweenness_centrality,currentVar)
           waitbar(i / nargin)
       end
       
       title('Betweenness Centrality')
       ylabel('Betweenness Centrality')
       xlabel('Nodes')
       legend(inputCity,'FontSize',14)
       hold off
       close(h)
       figure(f)
       %% Closeness unweighted
       h = waitbar(0,'Please wait...','Name','Closeness centrality');
       f = figure('Visible','off');
       hold on
       for i = 1:nargin
           currentVar = sprintf('adjMatrixUW%d',i);
           adjMatrix=evalin('base', currentVar);
           kozelseg=closeness2(adjMatrix);
           data=sort(kozelseg,'descend');
           currentVar = sprintf('%c-%c',plotColor(i),plotMarker(i));
           loglog(1:(length(data)),data,currentVar)
           waitbar(i / nargin)
       end
       
       title('Closeness Centrality')
       ylabel('Closeness Centrality')
       xlabel('Nodes')
       legend(inputCity,'FontSize',14)
       hold off
       close(h)
       figure(f)
       %% Weighted in-degree - Degree centrality
       h = waitbar(0,'Please wait...','Name','Degree centrality');
       f = figure('Visible','off');
       hold on
       for i = 1:nargin
           currentVar = sprintf('G%d',i);
           G = evalin('base', currentVar);
           wdegree_centrality=centrality(G,'indegree','Importance',G.Edges.Weight);
           wdegree_centrality=(sort(wdegree_centrality,'descend'));
           currentVar = sprintf('%c-%c',plotColor(i),plotMarker(i));
           loglog(wdegree_centrality,currentVar)
           waitbar(i / nargin)
       end
       
       title('Degree centrality')
       ylabel('Weighted In-Degree')
       xlabel('Nodes')
       legend(inputCity,'FontSize',14)
       hold off
       close(h)
       figure(f)
       %% PageRank
       h = waitbar(0,'Please wait...','Name','PageRank');
       f = figure('Visible','off');
       hold on
       for i = 1:nargin
           currentVar = sprintf('G%d',i);
           G = evalin('base', currentVar);
           pagerank=centrality(G,'pagerank');
           pagerank=sort(pagerank,'descend');
           currentVar = sprintf('%c-%c',plotColor(i),plotMarker(i));
           semilogx(pagerank,currentVar)
           waitbar(i / nargin)
       end
       
       title('PageRank')
       ylabel('PageRank')
       xlabel('Nodes')
       legend(inputCity,'FontSize',14)
       hold off
       close(h)
       figure(f)
       
       %% Tablazat
       
       ret = table(elekSzama,csucsokSzama,avgDegree,atmero,radius,avgPathLength,density,corePeriphery,clusteringCoefficientAVG,'RowNames',inputCity','VariableNames',{'Links' 'Nodes' 'AVG_Degree' 'Diameter' 'Radius' 'AVG_Path_Length' 'Density' 'CorePeriphery' 'AVG_Clustering_Coefficient'});
       
       %% Base Worksapce cleaning
       for i = 1:nargin
           currentVar = sprintf('clear adjMatrixW%d',i);
           evalin('base',currentVar)
       end
       for i = 1:nargin
           currentVar = sprintf('clear adjMatrixUW%d',i);
           evalin('base',currentVar)
       end
       for i = 1:nargin
           currentVar = sprintf('clear G%d',i);
           evalin('base',currentVar)
       end
       
      %% Elapsed time
         elapsedTime=toc; 
         %in seconds
       
end

