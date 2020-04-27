%{
Find the sensor location
Input: 1-d density curve for sensors;xt, array of y dimension;beams:
location of beams for all the sensors;
Output: Predicted location for sensors
%}
function location=findlocation(denseline,xt,beams)
prediction=zeros(size(denseline,1),length(xt));
for i=1:size(prediction,1)
    step=xt(2)-xt(1);
    start=floor(beams(i,1)/step);
    final=floor(beams(i,2)/step);
    denseline(i,1:start)=0;
    denseline(i,final:end)=0;
    for j=1:length(xt)
        if xt(j)<=beams(i,1) || xt(j)>=beams(i,2)
            continue
        else
        simulation=vibrationfunc(xt,xt(j),beams(i,:));
        simulation=simulation/max(simulation);
        corr=corrcoef(denseline(i,:)/max(denseline(i,:)),simulation);
        prediction(i,j)=corr(1,2);
        end
    end
end
location=zeros(size(prediction,1),1);
for i=1:size(prediction,1)
    [value,argmax]=max(prediction(i,:));
    location(i)=xt(argmax);
end
end
