%{
Find the locations of beams
Input: max heat map among all the sensors, 1-d energy curve for all the
sensors, y-dimension location array.
Output: beams locations, correspond to each sensor.
%}
function beams=findbeam(maxdensematrix,denseline,xt)
maxdense=max(maxdensematrix,[],2);
beamslocation=[];
len=86;
for t=1:2
before=0;
for i=1:length(xt)-len
        if sum(maxdense(i:i+len))>before
            before=sum(maxdense(i:i+len));
            bestbeam=[xt(i),xt(i+len)];
            bestindex=i;
        end
end
beamslocation=[beamslocation,bestbeam];
maxdense(bestindex:bestindex+len)=0;
end
beams=zeros(size(denseline,1),2);
for i=1:size(denseline,1)
    energymax=0;
    for j=1:length(beamslocation)-1
        dense=denseline(i,:);
        energy=sum(dense((xt>=beamslocation(j)) & (xt<beamslocation(j+1))));
        if energy>energymax
            beams(i,:)=[beamslocation(j),beamslocation(j+1)];
            energymax=energy;
        end
    end
end
end