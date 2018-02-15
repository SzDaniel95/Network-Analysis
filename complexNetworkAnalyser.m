function  out  = complexNetworkAnalyser(str_edge,str_node)
%   Complex Network Analyser
%
%   System Requirements: MATLAB R2016a
%   Input: str_edge - .csv/.xlsx file with edges
%   Input: str_node - .csv/.xlsx file with node names (not necessary)
%   Output: out variable is a struct with requested datasets
%
%   Usage:
%    out  =  complexNetworkAnalyser('Szeged_w1_edges.csv')
%    out  =  complexNetworkAnalyser('Szeged_w1_edges.csv', 'Szeged_w1_nodes.csv')
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
        help complexNetworkAnalyser
        return
    end
     if(exist(str_edge,'file')==0)
               errordlg('Nem létezõ fájlt adtál meg!','Fájl Hiba');
               return
     end
     prompt = 'A szomszédsági mátrix súlyozott legyen ? (i/n)\n';
     temp2 = input(prompt,'s');
    
        if (strcmp(temp2,''))
             temp2='n';
        end
        if(temp2=='i')
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
                h = waitbar(0,'Please wait...','Name','Kerem varjon');
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
        fprintf('Elek szama: %d\n',elekSzama);
        fprintf('Csucsok szama: %d\n',csucsokSzama);
        avgDegree=(2*elekSzama)/csucsokSzama;
        out.atlagFok=avgDegree;
        fprintf('Atlagos fokszam: %4.2f\n',avgDegree);
        
        
        
        %% Gráf kirajzolás
        
        prompt = 'Meg szeretnéd jeleníteni a gráfot ? (i/n)\n';
        temp = input(prompt,'s');
       
        if (strcmp(temp,''))
            temp='n';
        end
        if(temp=='i')
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
        if(temp=='i')
            if(length(nodeNames)~=1)
             prompt = 'Meg szeretnéd jeleníteni a csúcsok cimkéit ? (i/n)\n';
             temp2 = input(prompt,'s');
             
             if (strcmp(temp2,''))
                    temp2='n';
             end
             if(temp2=='i')
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
        prompt = 'Ki szeretnéd számítattni a gráf átmerõjet ? (i/n)\n';
        temp = input(prompt,'s');
        
        if (strcmp(temp,''))
            temp='n';
        end
        if(temp=='i')
                
               atmero=diameter(adjMatrix);
               out.atmero=atmero;
               fprintf('Atmero: \n');
               disp(atmero);
        
        end
        
        
        %% Radius
        prompt = 'Ki szeretnéd számítattni a gráf sugarát ? (i/n)\n';
        temp = input(prompt,'s');
        
        if (strcmp(temp,''))
            temp='n';
        end
        if(temp=='i')
               
            radius=graph_radius(adjMatrix);
            out.radius=radius;
            fprintf('Radius: \n');
            disp(radius);
        end
        
        %% Density
        prompt = 'Ki szeretnéd számítattni a gráf sûrûségét ? (i/n)\n';
        temp = input(prompt,'s');
      
        if (strcmp(temp,''))
            temp='n';
        end
        if(temp=='i')
               
            density=density_dir(adjMatrix);
            out.density=density;
            fprintf('Density: \n');
            disp(density);
        end
        
        %% Vertex eccentricity
        prompt = 'Ki szeretnéd számítattni a csúcsok excentricitását ? (i/n)\n';
        temp = input(prompt,'s');
      
        if (strcmp(temp,''))
            temp='n';
        end
        if(temp=='i')
                
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
        prompt = 'Ki szeretnéd számítattni a klaszterezettségi együtthatót ? (i/n)\n';
        temp = input(prompt,'s');
        
        if (strcmp(temp,''))
            temp='n';
        end
        if(temp=='i')
             
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
            fprintf('Atlagos klaszterezettsegi egyutthato\n');
            disp(avgClusteringCoefficient);
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
        prompt = 'Meg szeretnéd jeleníteni a Fokszámeloszlást ? (i/n)\n';
        temp = input(prompt,'s');
       
        if (strcmp(temp,''))
            temp='n';
        end
        if(temp=='i')
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
        prompt = 'Meg szeretnéd jeleníteni a Fokszám centralitást ? (i/n)\n';
        temp = input(prompt,'s');
      
        if (strcmp(temp,''))
            temp='n';
        end
        if(temp=='i')
                
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
        prompt = 'Ki szeretnéd számítattni az Átlagos legrövidebb úthosszt ? (i/n)\n';
        temp = input(prompt,'s');
     
        if (strcmp(temp,''))
            temp='n';
        end
        if(temp=='i')
                
                atl_hossz=ave_path_length(adjMatrix);
                out.atlagosUthossz=atl_hossz;
                fprintf('Atlagos legrovidebb uthossz: \n');
                disp(atl_hossz);
        
        end
        
        %% Core/Periphery
        prompt = 'Ki szeretnéd számítattni a gráf Mag-periféria értékét ? (i/n)\n';
        temp = input(prompt,'s');
   
        if (strcmp(temp,''))
            temp='n';
        end
        if(temp=='i')
                
                [C,q]=core_periphery_dir(adjMatrix);
                out.magPeriferia=C;
                out.core_periphery=q;
                
                fprintf('Core/periphery: \n');
                disp(q);
                %C = 1  core
                %C = 0  periphery
               [kirajzol, z ] = magPeriferiaPlotBeallit( C );
               figure;
               p2=plot(G,'Layout','force','MarkerSize',kirajzol);
               highlight(p2,z,'NodeColor','g');
               title('Core/Periphery')

        
        
        end
        
        %% Betweenness 
        prompt = 'Meg szeretnéd jeleníteni a Köztiség Centralitás értékeit ? (i/n)\n';
        temp = input(prompt,'s');
       
        if (strcmp(temp,''))
            temp='n';
        end
        if(temp=='i')
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
        
        %% Closeness Centrality
        prompt = 'Meg szeretnéd jeleníteni a Közelség Centralitás értékeit ? (i/n)\n';
        temp = input(prompt,'s');
        
        if (strcmp(temp,''))
            temp='n';
        end
        if(temp=='i')
                               
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
        prompt = 'Meg szeretnéd jeleníteni a PageRank értékeket ? (i/n)\n';
        temp = input(prompt,'s');
      
        if (strcmp(temp,''))
            temp='n';
        end
        if(temp=='i')
                
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
        
         %% Shortest Path 
           temp='i';
           while(temp=='i')
                prompt = 'Szeretnéd megkeresni a legrövidebb utat két csúcs között ? (i/n)\n';
                temp = input(prompt,'s');
                
                if (strcmp(temp,''))
                    temp='n';
                end
                %nincsennek csucs cimkek
                if(temp=='i')
                    if(length(nodeNames)==1)
                        var=0;
                        while(var < 1 || var > csucsokSzama || isnan(var))
                            prompt={'Kérem írja be a kezdõ csúcs számat'};
                            cim = 'Kezdõ csúcs';
                            answer = inputdlg(prompt,cim,[1 40]);
                            if(isempty(answer))
                                var=0;
                            else
                                var = str2double(answer{1});
                            end
                            if(var < 1 || var > csucsokSzama || isnan(var))
                               warning('Nem megfelelõ érték!') 
                            end
                        end
                        nodeNumberSource=var;
                        var=0;
                        while(var < 1 || var > csucsokSzama || isnan(var))
                            prompt={'Kérem írja be a cél csúcs számát'};
                            cim = 'Cél csúcs';
                            answer = inputdlg(prompt,cim,[1 40]);
                            if(isempty(answer))
                                var=0;
                            else
                                var = str2double(answer{1});
                            end
                            if(var < 1 || var > csucsokSzama || isnan(var))
                               warning('Nem megfelelõ érték!') 
                            end
                        end
                        nodeNumberTarget=var;
                        [TR,D] = shortestpathtree(G,nodeNumberSource,nodeNumberTarget);
                        figure;
                        p = plot(G,'Layout','force');
                        highlight(p,TR,'EdgeColor','r','LineWidth',2.5)
                        highlight(p,[nodeNumberSource nodeNumberTarget],'NodeColor','r','MarkerSize',5)
                        %[~,d] = shortestpath(G,nodeNumberSource,nodeNumberTarget);
                        fprintf('Az útvonal hossza: \n');
                        disp(D);
                    end

                end
                %Vannak csucs cimkeke
                if(temp=='i')
                    if(length(nodeNames)~=1)
                        f=figure('pos',[500 150 400 100],'Name','Kerem valassza ki a kezdo csucsot a legordulo listabol','NumberTitle','off');
                        assignin('base', 'f', f);
                        tempVar=0;
                        assignin('base', 'tempVar', tempVar);
                        fprintf('Kerem valassza ki a kezdo csucsot\n');
                        uiControlPopUp( nodeNames );
                        f=evalin('base', 'f');
                        waitfor(f)
                        nodeNumberSource=evalin('base', 'tempVar');
                        tempVar=0;
                        assignin('base', 'tempVar', tempVar);
                        fprintf('Kerem valassza ki a cel csucsot\n');
                        f=figure('pos',[500 150 400 100],'Name','Kerem valassza ki a cel csucsot a legordulo listabol','NumberTitle','off');
                        assignin('base', 'f', f);
                        uiControlPopUp( nodeNames );
                        f=evalin('base', 'f');
                        waitfor(f)
                        nodeNumberTarget=evalin('base', 'tempVar');
                        if(nodeNumberSource~=0 && nodeNumberTarget~=0)
                            [TR,D] = shortestpathtree(G,nodeNumberSource,nodeNumberTarget);
                            figure;
                            p = plot(G,'Layout','force');
                            highlight(p,TR,'EdgeColor','r','LineWidth',2.5)
                            highlight(p,[nodeNumberSource nodeNumberTarget],'NodeColor','r','MarkerSize',5)
                            %[~,d] = shortestpath(G,nodeNumberSource,nodeNumberTarget);
                            fprintf('Az útvonal hossza ');
                            disp(string(nodeNames(nodeNumberSource)));
                            fprintf('  és ');
                            disp(string(nodeNames(nodeNumberTarget)));
                            fprintf('  között:\n');
                            disp(D);
                        else
                            warning('Nem választottál csúcspontot !');
                        end
                        %Valtozok torlese a base-bol
                        evalin('base','clear tempVar')
                        evalin('base','clear f')
                        evalin('base','clear popup')
                   end
                end
           end
        %% Maximum flow,maximalis folyam 
           temp='i';
           while(temp=='i')
                prompt = 'Szeretnéd megkeresni a maximalis folyamot két csúcs között ? (i/n)\n';
                temp = input(prompt,'s');
                
                if (strcmp(temp,''))
                    temp='n';
                end
                %nincsennek csucs cimkek
                if(temp=='i')
                    if(length(nodeNames)==1)
                            var=0;
                            while(var < 1 || var > csucsokSzama || isnan(var))
                                prompt={'Kérem írja be a kezdõ csúcs számat'};
                                cim = 'Kezdõ csúcs';
                                answer = inputdlg(prompt,cim,[1 40]);
                                if(isempty(answer))
                                     var=0;
                                else
                                     var = str2double(answer{1});
                                end
                                if(var < 1 || var > csucsokSzama || isnan(var))
                                   warning('Nem megfelelõ érték!') 
                                end
                            end
                            nodeNumberSource=var;
                            var=0;
                            while(var < 1 || var > csucsokSzama || isnan(var) || var==nodeNumberSource)
                                prompt={'Kérem írja be a cél csúcs számát'};
                                cim = 'Cél csúcs';
                                answer = inputdlg(prompt,cim,[1 40]);
                                if(isempty(answer))
                                    var=0;
                                else
                                    var = str2double(answer{1});
                                end
                                if(var < 1 || var > csucsokSzama || isnan(var) || var==nodeNumberSource)
                                   warning('Nem megfelelõ érték!') 
                                end
                            end
                            nodeNumberTarget=var;
                            [mf,GF,cs,ct] = maxflow(G,nodeNumberSource,nodeNumberTarget);
                            figure;
                            p = plot(G,'Layout','force');
                            highlight(p,GF,'EdgeColor','r','LineWidth',2.5)
                            highlight(p,cs,'NodeColor','red')
                            highlight(p,ct,'NodeColor','green')
                            highlight(p,[nodeNumberSource nodeNumberTarget],'NodeColor','m','MarkerSize',5)
                            st = GF.Edges.EndNodes;
                            labeledge(p,st(:,1),st(:,2),GF.Edges.Weight);
                            fprintf('Maximális folyam: \n');
                            disp(mf);
                    end

                end
                %Vannak csucs cimkeke
                if(temp=='i')
                    if( length(nodeNames)~=1)
                        f=figure('pos',[500 150 400 100],'Name','Kerem valassza ki a kezdo csucsot a legordulo listabol','NumberTitle','off');
                        assignin('base', 'f', f);
                        tempVar=0;
                        assignin('base', 'tempVar', tempVar);
                        fprintf('Kerem valassza ki a kezdo csucsot\n');
                        uiControlPopUp( nodeNames );
                        f=evalin('base', 'f');
                        waitfor(f)
                        nodeNumberSource=evalin('base', 'tempVar');
                        tempVar=0;
                        assignin('base', 'tempVar', tempVar);
                        fprintf('Kerem valassza ki a cel csucsot\n');
                        f=figure('pos',[500 150 400 100],'Name','Kerem valassza ki a cel csucsot a legordulo listabol','NumberTitle','off');
                        assignin('base', 'f', f);
                        uiControlPopUp( nodeNames );
                        f=evalin('base', 'f');
                        waitfor(f)
                        nodeNumberTarget=evalin('base', 'tempVar');
                        if(nodeNumberSource~=0 && nodeNumberTarget~=0 && nodeNumberSource~=nodeNumberTarget)
                            [mf,GF,cs,ct] = maxflow(G,nodeNumberSource,nodeNumberTarget);
                            figure;
                            p = plot(G,'Layout','force');
                            highlight(p,GF,'EdgeColor','r','LineWidth',2.5)
                            highlight(p,cs,'NodeColor','red')
                            highlight(p,ct,'NodeColor','green')
                            highlight(p,[nodeNumberSource nodeNumberTarget],'NodeColor','m','MarkerSize',5)
                            st = GF.Edges.EndNodes;
                            labeledge(p,st(:,1),st(:,2),GF.Edges.Weight);
                            fprintf('Maximalis folyam: ');
                            disp(string(nodeNames(nodeNumberSource)));
                            fprintf('  es ');
                            disp(string(nodeNames(nodeNumberTarget)));
                            fprintf('  kozott:\n');
                            disp(mf);
                        else
                            warning('Nem választottál csúcspontot vagy megegyezik a kezdõ és a cél csúcs !');
                        end
                        %Valtozok torlese a base-bol
                        evalin('base','clear tempVar')
                        evalin('base','clear f')
                        evalin('base','clear popup')
                    end
                end
           end
        
        %% Kozossegkereses
        prompt = 'Meg szeretnéd jeleníteni a közösségeket ? (i/n)\n';
        temp = input(prompt,'s');
        
        if (strcmp(temp,''))
            temp='n';
        end
        if(temp=='i')
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
              fprintf('Közösségek száma: %d\n',max(M));
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
             prompt = 'Meg szeretnéd jeleníteni külon is a közösségeket ? (i/n)\n';
             temp = input(prompt,'s');

             if (strcmp(temp,''))
                temp='n';
             end 
              %Subplotolas a kozossegeknek
             if(temp=='i')
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
                       %uj abra
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