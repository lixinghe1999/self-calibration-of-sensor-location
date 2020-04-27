%{ 
Compute heat map
Input: vision data, size: time length * 2(left and right); t, time array,
associated with vibration data; vib: vibration data, time length
*4(sensors)
Output: heatmap for sensors, the max heat map among those maps.
%}
function [maxdensematrix,densematrix]=compute(vision,t,vib)
overlap=5;
x=linspace(0,2,5);
stepx=0.5;
y=linspace(0,14,201);
stepy=(14)/200;
channel=size(vib,2);
densematrix=zeros(length(y),length(x),channel);
maxdensematrix=zeros(length(y),length(x));
rate=length(vib)/length(vision);
for i=1:channel
    for j=1:length(t)
        tchange=ceil(j/rate);
        position=vision(tchange,:);
        if position(1)<=0 || position(1)>=2 || position(2)<=0 || position(2)>=14
            continue
        else
        xposition=ceil(position(1)/stepx);
        yposition=ceil(position(2)/stepy);  
        if isnan(vib(j))
            vib(j,i)=0;
        end
        densematrix(yposition,xposition,i)=densematrix(yposition,xposition,i)+(vib(j,i))^2;
        end
    end
temp=densematrix(:,:,i);
for k=overlap+1:length(y)-overlap
densematrix(k,:,i)=sum(temp(k-overlap:overlap+k,:),1);
end
maxdensematrix=maxdensematrix.*(maxdensematrix>=densematrix(:,:,i))+densematrix(:,:,i).*(maxdensematrix<densematrix(:,:,i));
end
end