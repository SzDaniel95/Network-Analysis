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
%   Author: Sztancsik Dániel

    %% Verzio ellenorzes
        [v, ~] = version;
        newStr = split(v,'(');
        newStr = char(newStr(2));
        newStr = str2double(char(newStr(5)));
        
        if (newStr<6)
            warning('Ebben a MATLAB verzióban a program hibát adhat, kérem használjon újabb verziót!')
        end

    %% Fajlbeolvasas
    if(exist('str_edge','var'))
        format long;
    else
       
        errordlg('Nem adtál meg fájlt !','Fájl Hiba');
        help complexNetworkAnalyserGUI
        return
    end
     if(exist(str_edge,'file')==0)
               errordlg('Nem létezõ fájlt adtál meg!','Fájl Hiba');
               return
     end
     prompt = 'A szomszédsági mátrix súlyozott legyen ?';
     temp = questdlg(prompt,'Kérem válasszon!','Igen','Nem','Nem');
    
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
       
        %% Pontok nevének beolvasása
        
         if(exist('str_node','var'))
                 if(exist(str_node,'file')==0)
                   errordlg('Nem létezõ fájlt adtál meg!','Fájl Hiba');
                   return
                 end
                h = waitbar(0,'Please wait...','Name','Kérem várjon');
                [~,text]=xlsread(str_node,'B:B');
                text=text';
                for i=1:(length(text)-1)
                    text(i)=text(i+1);
                    waitbar(i /(length(text)-1))
                 end
                 close(h)
                 %Elcsúsztatás mivel a Label az elsõ cella
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
        
        %% Alapvetõ adatok kiírása
        
        elekSzama=nnz(adjMatrix);
        out.elekSzama=elekSzama;
        csucsokSzama=size(adjMatrix,1);
        out.csucsokSzama=csucsokSzama;
        avgDegree=(2*elekSzama)/csucsokSzama;
        out.atlagFok=avgDegree;
        
        
        
        %% Gráf kirajzolás
        
        prompt = 'Meg szeretnéd jeleníteni a gráfot ?';
        temp = questdlg(prompt,'Kérem válasszon!','Igen','Nem','Nem');
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
             prompt = 'Meg szeretnéd jeleníteni a csúcsok cimkéit ?';
             temp2 = questdlg(prompt,'Kérem válasszon!','Igen','Nem','Nem');
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
        prompt = 'Ki szeretnéd számítattni a gráf átmerõjet ?';
        temp = questdlg(prompt,'Kérem válasszon!','Igen','Nem','Nem');
        if (strcmp(temp,''))
            return;
        end
        if(strcmp(temp,'Igen'))
                
               atmero=diameter(adjMatrix);
               out.atmero=atmero;
               currentVar = sprintf('Átmérõ: %d',atmero);
               helpdlg(currentVar,'Átmérõ');
        
        end
        
        
        %% Radius
        prompt = 'Ki szeretnéd számítattni a gráf sugarát ?';
        temp = questdlg(prompt,'Kérem válasszon!','Igen','Nem','Nem');
        if (strcmp(temp,''))
            return;
        end
        if(strcmp(temp,'Igen'))
               
            radius=graph_radius(adjMatrix);
            out.radius=radius;
            currentVar = sprintf('Sugár: %d',radius);
            helpdlg(currentVar,'Sugár');
        end
        
        %% Density
        prompt = 'Ki szeretnéd számítattni a gráf sûrûségét ?';
        temp = questdlg(prompt,'Kérem válasszon!','Igen','Nem','Nem');
        if (strcmp(temp,''))
            return;
        end
        if(strcmp(temp,'Igen'))
               
            density=density_dir(adjMatrix);
            out.density=density;
            currentVar = sprintf('Sûrûség: %.6f',density);
            helpdlg(currentVar,'Sûrûség');
        end
        
        %% Vertex eccentricity
        prompt = 'Ki szeretnéd számítattni a csúcsok excentricitását ?';
        temp = questdlg(prompt,'Kérem válasszon!','Igen','Nem','Nem');
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
        prompt = 'Ki szeretnéd számítattni a klaszterezettségi együtthatót ?';
        temp = questdlg(prompt,'Kérem válasszon!','Igen','Nem','Nem');
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
            currentVar = sprintf('Átlagos klaszterezettség: %.6f',avgClusteringCoefficient);
            helpdlg(currentVar,'Átlagos klaszterezettség');
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
        prompt = 'Meg szeretnéd jeleníteni a Fokszámeloszlást ?';
        temp = questdlg(prompt,'Kérem válasszon!','Igen','Nem','Nem');
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
        prompt = 'Meg szeretnéd jeleníteni a Fokszám centralitást ?';
        temp = questdlg(prompt,'Kérem válasszon!','Igen','Nem','Nem');
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
        prompt = 'Ki szeretnéd számítattni az Átlagos legrövidebb úthosszt ?';
        temp = questdlg(prompt,'Kérem válasszon!','Igen','Nem','Nem');
        if (strcmp(temp,''))
            return;
        end
        if(strcmp(temp,'Igen'))
                
                atl_hossz=ave_path_length(adjMatrix);
                out.atlagosUthossz=atl_hossz;
                currentVar = sprintf('Legrövidebb úthosszak átlaga: %.6f',atl_hossz);
                helpdlg(currentVar,'Átlagos legrövidebb úthossz');
        
        end
        
        %% Core/Periphery
        prompt = 'Ki szeretnéd számítattni a gráf Mag-periféria értékét ?';
        temp = questdlg(prompt,'Kérem válasszon!','Igen','Nem','Nem');
        if (strcmp(temp,''))
            return;
        end
        if(strcmp(temp,'Igen'))
                
                [C,q]=core_periphery_dir(adjMatrix);
                out.magPeriferia=C;
                out.core_periphery=q;
                currentVar = sprintf('Mag/Periféria: %.6f',q);
                helpdlg(currentVar,'Mag/Periféria');
                %C = 1  core
                %C = 0  periphery
               [kirajzol, z ] = magPeriferiaPlotBeallit( C );
               figure;
               p2=plot(G,'Layout','force','MarkerSize',kirajzol);
               highlight(p2,z,'NodeColor','g');
               title('Core/Periphery')

        
        
        end
        
        %% Betweenness 
        prompt = 'Meg szeretnéd jeleníteni a Köztiség Centralitás értékeit ?';
        temp = questdlg(prompt,'Kérem válasszon!','Igen','Nem','Nem');
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
        prompt = 'Meg szeretnéd jeleníteni a Közelség Centralitás értékeit ?';
        temp = questdlg(prompt,'Kérem válasszon!','Igen','Nem','Nem');
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
        prompt = 'Meg szeretnéd jeleníteni a PageRank értékeket ?';
        temp = questdlg(prompt,'Kérem válasszon!','Igen','Nem','Nem');
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
        prompt = 'Meg szeretnéd jeleníteni a közösségeket ?';
        temp = questdlg(prompt,'Kérem válasszon!','Igen','Nem','Nem');
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
              currentVar = sprintf('Közösségek száma: %d',max(M));
              helpdlg(currentVar,'Közösségek száma');
              %kirajzol=M*1.1;%jobb láthatóság érdekében
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
             prompt = 'Meg szeretnéd jeleníteni külön is a közösségeket ?';
             temp = questdlg(prompt,'Kérem válasszon!','Igen','Nem','Nem');
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
                       title([num2str(j),'. közösség ', num2str(csucsSzam), ' db csúccsal'])
                       countSubplot=2;
                    else
                        H = subgraph(G,a);
                        subplot(2,2,countSubplot)
                        plot(H,'Layout','force');
                        csucsSzam=size(H.Nodes);
                        csucsSzam=csucsSzam(1);
                        title([num2str(j),'. közösség ', num2str(csucsSzam), ' db csúccsal'])
                        countSubplot=countSubplot+1;
                    end
              end
             end
                  
        end
       
end