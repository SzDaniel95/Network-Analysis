function [ P ] = kozossegSzinezoPaletta( kozossegekSzama )
%Palattát készít a plot-hoz. Amennyiben a 8 alapszín elég, akkor azokat
%használja, amennyiben több kell, random mód generálja az RGB színkódokat
%Sztancsik Dániel
if(kozossegekSzama < 9)
    P=zeros(1,3,8);
    P(:,:,1)=[1 1 0];
    P(:,:,2)=[1 0 1];
    P(:,:,3)=[0 1 1];
    P(:,:,4)=[1 0 0];
    P(:,:,5)=[0 1 0];
    P(:,:,6)=[0 0 1];
    P(:,:,7)=[1 1 1];
    P(:,:,8)=[0 0 0];
else
    P=zeros(1,3,kozossegekSzama);
    for i=1:kozossegekSzama
        P(:,1,i)=rand(1);
        P(:,2,i)=rand(1);
        P(:,3,i)=rand(1);
    end
    

end

