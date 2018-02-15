function  out  = complexNetworkAnalyserGUI(str_edge,str_node)
%   Complex Network Analyser - GUI
%
%   System Requirements: MATLAB R2016a
%   Input: str_edge - .csv/.xlsx file with edges
%   Input: str_node - .csv/.xlsx file with node names (not necessary)
%   Output: out variable is a struct with requested datasets
%
%   Usage:
%    out  =  complexNetworkAnalyserGUI('Szeged_w1_edges.csv')
%    out  =  complexNetworkAnalyserGUI('Szeged_w1_edges.csv', 'Szeged_w1_nodes.csv')
%
%   Functions from these sites:
%   https://www.mathworks.com/help/matlab/graph-and-network-algorithms.html
%   http://strategic.mit.edu/downloads.php?page=matlab_networks
%   https://sites.google.com/site/bctnet/measures/list
%   
% 
%   https://www.mathworks.com/help/matlab/ref/graph.plot.highlight.html
%   https://hu.wikipedia.org/wiki/Gr%C3%A1felm%C3%A9leti_fogalomt%C3%A1r
%   https://hu.wikipedia.org/wiki/Kapcsolath%C3%A1l%C3%B3-elemz%C3%A9s
%
%   Author: Sztancsik D�niel

    %% Verzio ellenorzes
        [v, ~] = version;
        newStr = split(v,'(');
        newStr = char(newStr(2));
        newStr = str2double(char(newStr(5)));
        
        if (newStr<6)
            warning('Ebben a MATLAB verzi�ban a program hib�t adhat, k�rem haszn�ljon �jabb verzi�t!')
        end

    %% Fajlbeolvasas
    if(exist('str_edge','var'))
        format long;
    else
       
        errordlg('Nem adt�l meg f�jlt !','F�jl Hiba');
        help complexNetworkAnalyserGUI
        return
    end
     if(exist(str_edge,'file')==0)
               errordlg('Nem l�tez� f�jlt adt�l meg!','F�jl Hiba');
               return
     end
     prompt = 'A szomsz�ds�gi m�trix s�lyozott legyen ?';
     temp = questdlg(prompt,'K�rem v�lasszon!','Igen','Nem','Nem');
    
        if (strcmp(temp,''))
             temp='Nem';
        end
        if(strcmp(temp,'Igen'))
             sulyozott=1;
        else
            sulyozott=0;
        end
        adjMatrix=szomszedsagiMatrix(str_edge,sulyozott);
        out.szomszedsagiMatrix=adjMatrix;
       
        %% Pontok nev�nek beolvas�sa
        
         if(exist('str_node','var'))
                 if(exist(str_node,'file')==0)
                   errordlg('Nem l�tez� f�jlt adt�l meg!','F�jl Hiba');
                   return
                 end
                h = waitbar(0,'Please wait...','Name','K�rem v�rjon');
                [~,text]=xlsread(str_node,'B:B');
                text=text';
                for i=1:(length(text)-1)
                    text(i)=text(i+1);
                    waitbar(i /(length(text)-1))
                 end
                 close(h)
                 %Elcs�sztat�s mivel a Label az els� cella
                 %nodeNames=text(1,[1:(length(text)-1)]);
                nodeNames=text(1,1:(length(text)-1));
                out.csucsCimkek=nodeNames;
         else
               nodeNames=0;
         end
         
        
        %% Graf legeneralasa
        
        if(length(nodeNames)==1)
            G = digraph(adjMatrix);
        else
            G = digraph(adjMatrix,nodeNames);
        end
        
        out.graf=G;
        
        %% Alapvet� adatok ki�r�sa
        
        elekSzama=nnz(adjMatrix);
        out.elekSzama=elekSzama;
        csucsokSzama=size(adjMatrix,1);
        out.csucsokSzama=csucsokSzama;
        avgDegree=(2*elekSzama)/csucsokSzama;
        out.atlagFok=avgDegree;
        
        
        
        %% Gr�f kirajzol�s
        
        prompt = 'Meg szeretn�d jelen�teni a gr�fot ?';
        temp = questdlg(prompt,'K�rem v�lasszon!','Igen','Nem','Nem');
        if (strcmp(temp,''))
            return;
        end
        if(strcmp(temp,'Igen'))
           if(length(nodeNames)==1)
                 figure;
                 if(sulyozott==0)
                    plot(G,'Layout','force');
                 else
                     LWidths = 5*G.Edges.Weight/max(G.Edges.Weight);
                     plot(G,'Layout','force','LineWidth',LWidths)
                 end
           end
          
        end      
        if(strcmp(temp,'Igen'))
            if(length(nodeNames)~=1)
             prompt = 'Meg szeretn�d jelen�teni a cs�csok cimk�it ?';
             temp2 = questdlg(prompt,'K�rem v�lasszon!','Igen','Nem','Nem');
             if (strcmp(temp2,''))
                 temp2='Nem';
             end
             if(strcmp(temp2,'Igen'))
                 figure;
                 plot(G,'Layout','force','NodeLabel', nodeNames);
                 
                
             else
                 figure;
                 if(sulyozott==0)
                    plot(G,'Layout','force');
                 else
                     LWidths = 5*G.Edges.Weight/max(G.Edges.Weight);
                     plot(G,'Layout','force','LineWidth',LWidths)
                 end
             end
            end
        end

       
        %% Diameter
        prompt = 'Ki szeretn�d sz�m�tattni a gr�f �tmer�jet ?';
        temp = questdlg(prompt,'K�rem v�lasszon!','Igen','Nem','Nem');
        if (strcmp(temp,''))
            return;
        end
        if(strcmp(temp,'Igen'))
                
               atmero=diameter(adjMatrix);
               out.atmero=atmero;
               currentVar = sprintf('�tm�r�: %d',atmero);
               helpdlg(currentVar,'�tm�r�');
        
        end
        
        
        %% Radius
        prompt = 'Ki szeretn�d sz�m�tattni a gr�f sugar�t ?';
        temp = questdlg(prompt,'K�rem v�lasszon!','Igen','Nem','Nem');
        if (strcmp(temp,''))
            return;
        end
        if(strcmp(temp,'Igen'))
               
            radius=graph_radius(adjMatrix);
            out.radius=radius;
            currentVar = sprintf('Sug�r: %d',radius);
            helpdlg(currentVar,'Sug�r');
        end
        
        %% Density
        prompt = 'Ki szeretn�d sz�m�tattni a gr�f s�r�s�g�t ?';
        temp = questdlg(prompt,'K�rem v�lasszon!','Igen','Nem','Nem');
        if (strcmp(temp,''))
            return;
        end
        if(strcmp(temp,'Igen'))
               
            density=density_dir(adjMatrix);
            out.density=density;
            currentVar = sprintf('S�r�s�g: %.6f',density);
            helpdlg(currentVar,'S�r�s�g');
        end
        
        %% Vertex eccentricity
        prompt = 'Ki szeretn�d sz�m�tattni a cs�csok excentricit�s�t ?';
        temp = questdlg(prompt,'K�rem v�lasszon!','Igen','Nem','Nem');
        if (strcmp(temp,''))
            return;
        end
        if(strcmp(temp,'Igen'))
                
                eccen=vertex_eccentricity(adjMatrix);
                out.eccentricity=eccen;
                figure;

                [ x, y ] = countForPlot( eccen );
                plot(x,y,'b-o')
                title('Vertex eccentricity')
                ylabel('Frequency')
                xlabel('Eccentricity')
                
                figure;
                colormap jet
                nodeColor = eccen';
                plot(G,'MarkerSize',4,'NodeCData',nodeColor,'EdgeAlpha',0.25,'layout','force')
                title('Eccentricity')
                colorbar
                 
                
        end
        
        
        
        %% Clustering coefficient
        prompt = 'Ki szeretn�d sz�m�tattni a klaszterezetts�gi egy�tthat�t ?';
        temp = questdlg(prompt,'K�rem v�lasszon!','Igen','Nem','Nem');
        if (strcmp(temp,''))
            return;
        end
        if(strcmp(temp,'Igen'))
               
            if (sulyozott==1)
                %sulyozott
                cCoefficient=clustering_coef_wd(weight_conversion(adjMatrix, 'normalize'));
            else
                %sulyozatlan
                cCoefficient=clustering_coef_bd(adjMatrix);
            end
            
            avgClusteringCoefficient=mean(cCoefficient);
            out.clusteringCoefficient=cCoefficient;
            out.avgClusteringCoefficient=avgClusteringCoefficient;
            currentVar = sprintf('�tlagos klaszterezetts�g: %.6f',avgClusteringCoefficient);
            helpdlg(currentVar,'�tlagos klaszterezetts�g');
                cCoefficient=(sort(cCoefficient,'descend'));
                figure;loglog(cCoefficient,'b-o')                
               
                title('Clustering coefficient')
                ylabel('C(k)')
                xlabel('k')
                
                figure;
                colormap parula
                nodeColor = cCoefficient;
                plot(G,'MarkerSize',5,'NodeCData',nodeColor,'EdgeAlpha',0.25,'layout','force')
                title('Clustering coefficient')
                colorbar
      
        end
       
        %% - Degree distribution
        prompt = 'Meg szeretn�d jelen�teni a Foksz�meloszl�st ?';
        temp = questdlg(prompt,'K�rem v�lasszon!','Igen','Nem','Nem');
        if (strcmp(temp,''))
            return;
        end
        if(strcmp(temp,'Igen'))
            degreeDistribution=indegree(G)+outdegree(G);
            out.fokszamEloszlas=degreeDistribution;
            figure;
            histogram(degreeDistribution,'Normalization','probability');
            title('Degree distribution')
            xlabel('Degree')
            ylabel('Probability')
            [ x, y ] = countForPlot( degreeDistribution );
            figure; plot(x,y,'b-o')
            title('Degree distribution')
            xlabel('Degree')
            ylabel('Frequency')
            figure;
            colormap jet
            nodeColor = degreeDistribution;
            plot(G,'MarkerSize',5,'NodeCData',nodeColor,'EdgeAlpha',0.25,'layout','force')
            title('Degree distribution')
            colorbar
        
        end
            
        %% Degree centrality
        prompt = 'Meg szeretn�d jelen�teni a Foksz�m centralit�st ?';
        temp = questdlg(prompt,'K�rem v�lasszon!','Igen','Nem','Nem');
        if (strcmp(temp,''))
            return;
        end
        if(strcmp(temp,'Igen'))
                
               fokszam_centralitas=centrality(G,'indegree','Importance',G.Edges.Weight);
               out.fokszamCentralitas=fokszam_centralitas;
               fokszam_centralitas_csokkeno=(sort(fokszam_centralitas,'descend'));
               
               figure;loglog(1:(length(fokszam_centralitas_csokkeno)),fokszam_centralitas_csokkeno,'-o')
               
               title('Degree centrality')
               ylabel('In-Degree')
               xlabel('Nodes')
               
                figure;
                colormap jet
                nodeColor = fokszam_centralitas;
                plot(G,'MarkerSize',5,'NodeCData',nodeColor,'EdgeAlpha',0.25,'layout','force')
                title('Degree centrality')
                colorbar
                
        end
        
        
       
        %% Average path length
        prompt = 'Ki szeretn�d sz�m�tattni az �tlagos legr�videbb �thosszt ?';
        temp = questdlg(prompt,'K�rem v�lasszon!','Igen','Nem','Nem');
        if (strcmp(temp,''))
            return;
        end
        if(strcmp(temp,'Igen'))
                
                atl_hossz=ave_path_length(adjMatrix);
                out.atlagosUthossz=atl_hossz;
                currentVar = sprintf('Legr�videbb �thosszak �tlaga: %.6f',atl_hossz);
                helpdlg(currentVar,'�tlagos legr�videbb �thossz');
        
        end
        
        %% Core/Periphery
        prompt = 'Ki szeretn�d sz�m�tattni a gr�f Mag-perif�ria �rt�k�t ?';
        temp = questdlg(prompt,'K�rem v�lasszon!','Igen','Nem','Nem');
        if (strcmp(temp,''))
            return;
        end
        if(strcmp(temp,'Igen'))
                
                [C,q]=core_periphery_dir(adjMatrix);
                out.magPeriferia=C;
                out.core_periphery=q;
                currentVar = sprintf('Mag/Perif�ria: %.6f',q);
                helpdlg(currentVar,'Mag/Perif�ria');
                %C = 1  core
                %C = 0  periphery
               [kirajzol, z ] = magPeriferiaPlotBeallit( C );
               figure;
               p2=plot(G,'Layout','force','MarkerSize',kirajzol);
               highlight(p2,z,'NodeColor','g');
               title('Core/Periphery')

        
        
        end
        
        %% Betweenness 
        prompt = 'Meg szeretn�d jelen�teni a K�ztis�g Centralit�s �rt�keit ?';
        temp = questdlg(prompt,'K�rem v�lasszon!','Igen','Nem','Nem');
        if (strcmp(temp,''))
            return;
        end
        if(strcmp(temp,'Igen'))
                koztiseg=centrality(G,'betweenness','Cost',G.Edges.Weight);
                out.koztiseg=koztiseg;
                koztiseg_csokkeno=(sort(koztiseg,'descend'));
                figure;loglog(1:(length(koztiseg_csokkeno)),koztiseg_csokkeno,'b-o')
               
                title('Betweenness Centrality')
                ylabel('Betweenness Centrality')
                xlabel('Nodes')
                
                figure;
                colormap jet
                nodeColor = koztiseg;
                plot(G,'MarkerSize',5,'NodeCData',nodeColor,'EdgeAlpha',0.25,'layout','force')
                title('Betweenness Centrality')
                colorbar
   
        end
        
        %% Closeness Centrality:
        prompt = 'Meg szeretn�d jelen�teni a K�zels�g Centralit�s �rt�keit ?';
        temp = questdlg(prompt,'K�rem v�lasszon!','Igen','Nem','Nem');
        if (strcmp(temp,''))
            return;
        end
        if(strcmp(temp,'Igen'))
                               
                kozelseg=closeness2(adjMatrix);
                out.kozelseg=kozelseg;
                kozelseg_csokkeno=sort(kozelseg,'descend');
                
                figure;semilogx(1:(length(kozelseg_csokkeno)),kozelseg_csokkeno,'c-d')
                title('Closeness Centrality')
                ylabel('Closeness Centrality')
                xlabel('Nodes')
                
                
                colormap jet
                nodeColor = kozelseg';
                figure;plot(G,'MarkerSize',5,'NodeCData',nodeColor,'EdgeAlpha',0.25,'layout','force')
                title('Closeness Centrality')
                colorbar
        
        end
        
        %% PageRank
        prompt = 'Meg szeretn�d jelen�teni a PageRank �rt�keket ?';
        temp = questdlg(prompt,'K�rem v�lasszon!','Igen','Nem','Nem');
        if (strcmp(temp,''))
            return;
        end
        if(strcmp(temp,'Igen'))
               
                pagerank=centrality(G,'pagerank','Importance',G.Edges.Weight);
                out.pageRank=pagerank;
                pagerank_csokkeno=sort(pagerank,'descend');
                
                figure;semilogx(1:(length(pagerank_csokkeno)),pagerank_csokkeno,'c-d')
                
                title('PageRank')
                ylabel('PageRank')
                xlabel('Nodes')
                
                figure;
                colormap jet
                nodeColor = pagerank;
                plot(G,'MarkerSize',5,'NodeCData',nodeColor,'EdgeAlpha',0.25,'layout','force')
                title('PageRank')
                colorbar
        
        end
        
        %% Kozossegkereses
        prompt = 'Meg szeretn�d jelen�teni a k�z�ss�geket ?';
        temp = questdlg(prompt,'K�rem v�lasszon!','Igen','Nem','Nem');
        if (strcmp(temp,''))
            return;
        end
        if(strcmp(temp,'Igen'))
              M=community_louvain(adjMatrix);
              M=M';
              out.kozosseg=M;
              h=histogram(M);
              K=zeros(max(M),max(h.Values));
              kozossegPlot=sort(h.Values,'descend');
              plot(kozossegPlot,'b-o');
              title('Optimal Community Structure')
              ylabel('Number of nodes in community')
              xlabel('Communities')
              currentVar = sprintf('K�z�ss�gek sz�ma: %d',max(M));
              helpdlg(currentVar,'K�z�ss�gek sz�ma');
              %kirajzol=M*1.1;%jobb l�that�s�g �rdek�ben
              %Szinezes max 15 kozossegre
              P=kozossegSzinezoPaletta(max(M));
              

              
              for i=1:length(M)
                for j=1:max(M)
                    if(M(i)==j)
                        K(j,i)=i;
                    end
                end
              end
              figure;
              p=plot(G,'Layout','force');
              title('Community Structure')
              p.MarkerSize=6;
              %Kozosseg szinezes
              for j=1:max(M)%kozossegek szama
                    count=0;
                    for i=1:length(K)
                        if(K(j,i)>0)
                            count=count+1;
                        end
                    end
                    a=zeros(1,count);
                    count=1;
                    for i=1:length(K)
                        if(K(j,i)>0)
                            a(count) = K(j,i);
                            count=count+1;
                        end
                    end
                    highlight(p,a,'NodeColor',P(:,:,j));
              end
             prompt = 'Meg szeretn�d jelen�teni k�l�n is a k�z�ss�geket ?';
             temp = questdlg(prompt,'K�rem v�lasszon!','Igen','Nem','Nem');
             if (strcmp(temp,''))
                 temp='Nem';
             end
             %Subplotolas a kozossegeknek
             if(strcmp(temp,'Igen'))
              countSubplot=5;
              for j=1:max(M)%kozossegek szama
                    count=0;
                    for i=1:length(K)
                        if(K(j,i)>0)
                            count=count+1;
                        end
                    end
                    a=zeros(1,count);
                    count=1;
                    for i=1:length(K)
                        if(K(j,i)>0)
                            a(count) = K(j,i);
                            count=count+1;
                        end
                    end
                    if(countSubplot==5)
                       figure;
                       H = subgraph(G,a);
                       subplot(2,2,1)
                       plot(H,'Layout','force');
                       csucsSzam=size(H.Nodes);
                       csucsSzam=csucsSzam(1);
                       title([num2str(j),'. k�z�ss�g ', num2str(csucsSzam), ' db cs�ccsal'])
                       countSubplot=2;
                    else
                        H = subgraph(G,a);
                        subplot(2,2,countSubplot)
                        plot(H,'Layout','force');
                        csucsSzam=size(H.Nodes);
                        csucsSzam=csucsSzam(1);
                        title([num2str(j),'. k�z�ss�g ', num2str(csucsSzam), ' db cs�ccsal'])
                        countSubplot=countSubplot+1;
                    end
              end
             end
                  
        end
       
end