function uiControlPopUp( nodeNames )
% 
% 
%   PopUp felugró ablak a megállóhely kiválasztásához
%   Sztancsik Dániel

     f=evalin('base', 'f');
     popup = uicontrol('Style', 'popup','String', nodeNames,'Position', [15 15 350 50],'background','cyan','Value',2,'Callback',@Callbackfnc) ;
     assignin('base', 'f', f);
     assignin('base', 'popup', popup);
     
end
function Callbackfnc(app,event)
         
         popup=evalin('base', 'popup');
         tempVar  = get(popup,'Value');
         assignin('base', 'tempVar', tempVar);
         f=evalin('base', 'f');
         close(f);
         assignin('base', 'f', f);
         
                 
end
