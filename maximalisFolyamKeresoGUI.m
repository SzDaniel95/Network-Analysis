function [ mf, res ] = maximalisFolyamKeresoGUI( str_edge,str_node )

        %Súlyozott mártixal mûködik
        adjMatrix=szomszedsagiMatrix(str_edge,1);
        h = waitbar(0,'Please wait...','Name','Kérem várjon');
        [~,text]=xlsread(str_node,'B:B');
        text=text';
        for i=1:(length(text)-1)
            text(i)=text(i+1);
            waitbar(i /(length(text)-1))
        end
        close(h)
        nodeNames=text(1,1:(length(text)-1));
        G = digraph(adjMatrix,nodeNames);
        
        
        f=figure('pos',[500 150 400 100],'Name','Kerem valassza ki a kezdo csucsot a legordulo listabol','NumberTitle','off');
        assignin('base', 'f', f);
        tempVar=0;
        assignin('base', 'tempVar', tempVar);
        uiControlPopUp( nodeNames );
        f=evalin('base', 'f');
        waitfor(f)
        nodeNumberSource=evalin('base', 'tempVar');
        tempVar=0;
        assignin('base', 'tempVar', tempVar);
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
            res = sprintf('Maximális folyam %s és %s között: %d',string(nodeNames(nodeNumberSource)),string(nodeNames(nodeNumberTarget)),mf);
            xlabel(res)
        else
            warndlg('Nem megfelelõ csúcspont !', 'Warning' );
            res='Nem megfelelõ csúcspont !';
            mf='Nem megfelelõ csúcspont !';
        end
        %Valtozok torlese a base-bol
        evalin('base','clear tempVar')
        evalin('base','clear f')
        evalin('base','clear popup')
                    

end

