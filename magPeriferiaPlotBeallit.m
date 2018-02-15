function [ kirajzol, z ] = magPeriferiaPlotBeallit( C )
%Meret modositas, mag/periferia szerint
%Sztancsik Dániel

kirajzol=double(C);
for i=1:length(kirajzol)
    if(kirajzol(i)==1)
        %mag
        kirajzol(i)=5;
    else
        %periféria
        kirajzol(i)=2;
    end
end
%Szin modositas
z=zeros(0);
for i=1:length(C)
    if(C(i)==1)
        z=[z i];
    end
end

end

