figure(1)
truth=sensorPos(:,2);
iteratelocation=zeros(4,used);
randomorder=randperm(11);
locationrand=location(:,randomorder);
baselinerand=baseline(:,randomorder);
for i=1:4    
    iteratelocation(i,1)=locationrand(i,1);
    for j=2:used
        if ((sqrt(var(locationrand(i,1:j-1)))*1+mean(locationrand(i,1:j-1)))>=locationrand(i,j)) & ((-sqrt(var(locationrand(i,1:j-1)))*1+mean(locationrand(i,1:j-1)))<=locationrand(i,j));
            iteratelocation(i,j)=0.5*locationrand(i,j)+0.5*iteratelocation(i,j-1);
        else
            iteratelocation(i,j)=iteratelocation(i,j-1);
        end
    end
    subplot(2,2,i)
    plot(abs(iteratelocation(i,:)-truth(i)));hold on
    plot(abs(baselinerand(i,1:used)-truth(i)));
    legend('our method','baseline');
    ylim([0,5])
    xlabel('cycles people walk through hallway')
    ylabel('deviation from truth')
    title(['sensor',num2str(i)])
end
%%
figure(2)
for i=1:4
    plot(abs(iteratelocation(i,:)-truth(i)));hold on
end
legend('sensor1','sensor2','sensor3','sensor4');
ylim([0,5])
xlabel('cycles people walk through hallway')
ylabel('deviation from truth')
title(['sensor',num2str(i)])
%%
truth=sensorPos(:,2);
randomresult=zeros(10,11);
randombaseline=zeros(10,11);
for used=2:11
iteratelocation=zeros(4,used);
for t=1:10
randomorder=randperm(11);
locationrand=location(:,randomorder);
baselinerand=baseline(:,randomorder);
for i=1:4    
    iteratelocation(i,1)=locationrand(i,1);
    for j=2:used
        if ((sqrt(var(locationrand(i,1:j-1)))*1+mean(locationrand(i,1:j-1)))>=locationrand(i,j)) & ((-sqrt(var(locationrand(i,1:j-1)))*1+mean(locationrand(i,1:j-1)))<=locationrand(i,j));
            iteratelocation(i,j)=0.5*locationrand(i,j)+0.5*iteratelocation(i,j-1);
        else
            iteratelocation(i,j)=iteratelocation(i,j-1);
        end
    end
end
randombaseline(t,used)=sum(abs(baselinerand(:,used)-truth));
randomresult(t,used)=sum(abs(iteratelocation(:,used)-truth));
end
end
%%
figure(3)
value=mean(randomresult(:,2:11));
err=var(randomresult(:,2:11));
partsize=2:11;
errorbar(partsize,value,err);hold on
valuebase=mean(randombaseline(:,2:11));
errbase=var(randombaseline(:,2:11));
partsize=2:11;
errorbar(partsize,valuebase,errbase);
legend('our method','baseline')
xlim([1,12])
title("deviation and variance from the truth")
xlabel("data cycles we use")
ylabel('average deviation and variance of sensors estimation')