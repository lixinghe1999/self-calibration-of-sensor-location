%Load data
%load('Experiments/data.mat');

%parameter setup
person=5;
t0 = data(person).t(1);
sensorPos = [[0.455, 2.900]; [0.455, 5.335]; [0.455, 6.550]; [0.455, 8.675]];
xt=linspace(0,14,201);
left=data(person).l;
right=data(person).r;
vision=(left+right)/2;
t=data(person).tVib;
vib=data(person).vAligned;

% Detect and divide the data into parts, one part come to 14 from 0
% points=[];
% temp=vision(:,2);
% while 1
% [m1,argmin]=min(temp);
% temp(max(1,argmin-80):min(argmin+80,length(temp)))=0;
% points=[points,argmin];
% if m1>=-10
%     break
% end
% end
% points=sort(points);
% points=[points,length(temp)];
% part=length(points)-1;
% points2=floor(points*length(vib)/length(vision));

%uniformly divide the data into 11 parts, and only use the first five.
part=11;
used=11;

distance=zeros(size(vib,2),used);
location=zeros(size(vib,2),used);
baseline=zeros(size(vib,2),used);
prediction=zeros(size(vib,2),used);
average=zeros(size(vib,2),used);

vib(isnan(vib))=0;

for i=1:used
%uniformly divide
vibnow=vib(floor((i-1)*length(vib)/part)+1:floor(i*length(vib)/part),:);
visionnow=vision(floor((i-1)*length(vision)/part)+1:floor(i*length(vision)/part),:);
tnow=t(floor((i-1)*length(t)/part)+1:floor(i*length(t)/part));

%divide based on extraction
% vibnow=vib(points2(i):points2(i+1),:);
% visionnow=vision(points(i):points(i+1),:);
% tnow=t(points2(i):points2(i+1));

%compute heatmap
[maxdensematrix,densematrix]=compute(visionnow,tnow,vibnow);

%convert to 1-d curve and also record average and max(baseline)
denseline=zeros(4,size(densematrix(:,:,1),1));
denseline(1,:)=sum(densematrix(:,:,1),2);
denseline(2,:)=sum(densematrix(:,:,2),2);
denseline(3,:)=sum(densematrix(:,:,3),2);
denseline(4,:)=sum(densematrix(:,:,4),2);
%average(:,i)=mean(denseline,2);
[m,argmax]=max(denseline,[],2);
average(:,i)=m;

denseline(1,:)=denseline(1,:)/max(denseline(1,:));
denseline(2,:)=denseline(2,:)/max(denseline(2,:));
denseline(3,:)=denseline(3,:)/max(denseline(3,:));
denseline(4,:)=denseline(4,:)/max(denseline(4,:));

beams=findbeam(maxdensematrix,denseline,xt);
location(:,i)=findlocation(denseline,xt,beams);
%record baseline and distance to sensor
baseline(:,i)=xt(argmax);
distance(:,i)=3-abs(location(:,i)-mean(beams,2));

%Revision
for j=1:4
    weights=zeros(1,4);
    estimation=zeros(4,1);
    for k=1:4
        if k==j           
            weights(k)=average(k,i);
            estimation(k)=location(k,i);
        elseif sum(abs(beams(k,:)-beams(j,:)))<6
            weights(k)=average(k,i);
            head=ceil(beams(j,1)/(14/200))+1;
            tail=ceil(beams(j,2)/(14/200))+1;
            if sum(denseline(j,head:head+43))>sum(denseline(j,tail-43:tail))
               estimation(k)=beams(j,1)+comparison(beams(k,:),average(k,i),distance(k,i),average(j,i));
%                  estimation(k)=beams(j,1)+distance(k,i)/(maxpoint(beams(k,:),distance(k,i))/maxpoint(beams(k,:),distance(j,i)));
            else
                 estimation(k)=beams(j,2)-comparison(beams(k,:),average(k,i),distance(k,i),average(j,i));
%                  estimation(k)=beams(j,2)-distance(k,i)/(maxpoint(beams(k,:),distance(k,i))/maxpoint(beams(k,:),distance(j,i)));
            end
        end
    end
     prediction(j,i)=weights*estimation/sum(weights);
end
end
%only use few of the data
location=location(:,1:used);
baseline=baseline(:,1:used);
prediction=prediction(:,1:used);
newlocation=[];
newprediction=[];
for i=1:4
    location1=location(i,:);
    location1((location1==max(location1)))=[];
    newlocation=[newlocation,location1];
    
    prediction1=prediction(i,:);
    prediction1((prediction1==max(prediction1)))=[];
    newprediction=[newprediction,prediction1];
end
% location=reshape(newlocation,[used-1,4]).';
prediction=reshape(newprediction,[used-1,4]).';

%compute baseline, ourmethod, our method with revision
baselinelocation=mean(baseline,2);
averagelocation=mean(location,2);
bestlocation=mean(prediction,2);
%%

% figure(4)
% for i=1:4
%     subplot(2,2,i)
%     y=vibrationfunc(xt,sensorPos(i,2),beams(i,:));
%     y=y/max(y);
%     plot(xt,denseline(i,:),xt,y,[baselinelocation(i),baselinelocation(i)],[0,1],[sensorPos(i,2),sensorPos(i,2)],[0,1]);
%     if i==1
%         legend(["observed","ideal model","baseline","truth"]);
%     end
%     title(["sensor",i]);
%     xlabel("y-dimension/meter")
%     ylabel("normalized signal energy")
% end
%%
%final histgram
figure(1)
value =(averagelocation-sensorPos(:,2)).';
name = {'sensor1','sensor2','sensor3','sensor4'};
bar(value);
title("deviation from the truth")
set(gca, 'XTickLabel', name);
ylabel('sum deviation of 4 sensors')
truth=sensorPos(:,2);
figure(2)
value = [sum(abs(baselinelocation-truth))/4, sum(abs(averagelocation-truth))/4, sum(abs(bestlocation-truth))/4];
name = {'baseline','our method', 'revised our method'};
bar(value);
title("deviation from the truth")
set(gca, 'XTickLabel', name);
ylabel('sum deviation of 4 sensors')
figure(3)
value = [sum(var(baseline.'))/4, sum(var(location.'))/4, sum(var(prediction.'))/4];
name = {'baseline','our method', 'revised our method'};
bar(value);
title("result variance")
set(gca, 'XTickLabel', name);
ylabel('variance of 4 sensors')
%%
function distance2=comparison(beams,max1,distance1,max2)
L=beams(2)-beams(1);
maxvalue=max1/((L^2-distance1^2)^(3/2)*distance1)*((L^2-(L/2)^2)^(3/2)*(L/2));
desireratio=max2/maxvalue;
x=linspace(0,L/2,30);
test=zeros(1,30);
for i=1:length(x)
    test(i)=((L^2-x(i)^2)^(3/2))*x(i);
end
test=test/max(test);
difference=1000;
for i=1:length(test)
    diff=abs(desireratio-test(i));
    if diff<difference
        distance2=x(i);
        difference=diff;
    end
end
end