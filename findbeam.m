%{
Find the locations of beams
Input: max heat map among all the sensors, 1-d energy curve for all the
sensors, y-dimension location array.
Output: beams locations, correspond to each sensor.
%}
function beams=findbeam(maxdensematrix,denseline,xt)
% maxdense=max(maxdensematrix,[],2);
% beamslocation=[];
% len=86;
% for t=1:2
% before=0;
% for i=1:length(xt)-len
%         if sum(maxdense(i:i+len))>before
%             before=sum(maxdense(i:i+len));
%             bestbeam=[xt(i),xt(i+len)];
%             bestindex=i;
%         end
% end
% beamslocation=[beamslocation,bestbeam];
% maxdense(bestindex:bestindex+len)=0;
% end
% beams=zeros(size(denseline,1),2);
% for i=1:size(denseline,1)
%     energymax=0;
%     for j=1:length(beamslocation)-1
%         dense=denseline(i,:);
%         energy=sum(dense((xt>=beamslocation(j)) & (xt<beamslocation(j+1))));
%         if energy>energymax
%             beams(i,:)=[beamslocation(j),beamslocation(j+1)];
%             energymax=energy;
%         end
%     end
% end

smoothmaxline=smooth(sum(maxdensematrix,2),40,'lowess');
diffmax=[0;diff(smoothmaxline)];
beamslocation=[];
beamsindex=[];
signdiffmax=sign(diffmax);
before=signdiffmax(1);
before1=0;
before2=0;
for k=2:length(signdiffmax)
    if signdiffmax(k)~=before
    if signdiffmax(k)==1& before1==-1& before2==1
        beamslocation=[beamslocation,xt(k)];
        beamsindex=[beamsindex,k];
        threshold=smoothmaxline(k);
    end
    before2=before1;
    before1=signdiffmax(k);
    end
    before=signdiffmax(k);
end
% display(beamslocation)
a=smoothmaxline>0.5*threshold;
before=a(1);
for u=2:beamsindex(1)
    if a(u)~=before
        beamslocation=[xt(u),beamslocation];
        beamsindex=[u,beamsindex];
        break
    end
    before=a(u);
end
% display(beamslocation)
before=a(beamsindex(end)-1);
for u=beamsindex(end)+1:length(xt)
     if a(u)~=before
        beamslocation=[beamslocation,xt(u)];
        beamsindex=[beamsindex,u];
        break
    end
    
end
% display(beamslocation)
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