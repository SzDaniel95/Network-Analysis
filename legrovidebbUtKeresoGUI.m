function [ D, res ] = legrovidebbUtKeresoGUI( str_edge,str_node )
        
%         D - t�vols�g a k�t cs�cs k�z�tt
%         res - sz�veg a k�t cs�cs cimk�j�vel �s az eredm�nnyel
%         Nem s�lyozott m�rtix

        adjMatrix=szomszedsagiMatrix(str_edge,0);
        h = waitbar(0,'Please wait...','Name','K�rem v�rjon');
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
        if(nodeNumberSource~=0 && nodeNumberTarget~=0)
            [TR,D] = shortestpathtree(G,nodeNumberSource,nodeNumberTarget);
            figure;
            p = plot(G,'Layout','force');
            highlight(p,TR,'EdgeColor','r','LineWidth',2.5)
            highlight(p,[nodeNumberSource nodeNumberTarget],'NodeColor','r','MarkerSize',5)
            res = sprintf('Az �tvonal hossza %s �s %s k�z�tt: %d',string(nodeNames(nodeNumberSource)),string(nodeNames(nodeNumberTarget)),D);
            xlabel(res)
        else
            warndlg('Nem v�lasztott�l cs�cspontot !','Warning');
            res='Nem v�lasztott�l cs�cspontot !';
            D='Nem v�lasztott�l cs�cspontot !';
        end
        %Valtozok torlese a base-bol
        evalin('base','clear tempVar')
        evalin('base','clear f')
        evalin('base','clear popup')
                   
        

end

