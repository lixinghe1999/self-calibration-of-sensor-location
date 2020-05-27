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
points=[];
temp=vision(:,2);
while 1
[m1,argmin]=min(temp);
temp(max(1,argmin-80):min(argmin+80,length(temp)))=0;

% [m2,argmax]=max(temp);
% temp(max(1,argmax-80):min(argmax+80,length(temp)))=0;
points=[points,argmin];
if m1>=-10
    break
end
end
points=sort(points);
points=[points,length(temp)];
part=length(points)-1;
points2=floor(points*length(vib)/length(vision));

%uniformly divide the data into 11 parts, and only use the first five.
part=11;
used=11;

distance=zeros(size(vib,2),used);
location=zeros(size(vib,2),used);
baseline=zeros(size(vib,2),used);
prediction=zeros(size(vib,2),used);
average=zeros(size(vib,2),used);
beamsrecord=zeros(4,2,used);
meanbeams=zeros(4,2,used);
vib(isnan(vib))=0;
vibacc=[];
visionacc=[];
tacc=[];
for i=1:used
%uniformly divide
vibnow=vib(floor((i-1)*length(vib)/part)+1:floor(i*length(vib)/part),:);
visionnow=vision(floor((i-1)*length(vision)/part)+1:floor(i*length(vision)/part),:);
tnow=t(floor((i-1)*length(t)/part)+1:floor(i*length(t)/part));
vibacc=[vibacc;vibnow];
visionacc=[visionacc;visionnow];
tacc=[tacc;tnow];
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
%average is actually max value
%denseline=abs(imag(hilbert(denseline)));
denseline(1,:)=denseline(1,:)/max(denseline(1,:));
denseline(2,:)=denseline(2,:)/max(denseline(2,:));
denseline(3,:)=denseline(3,:)/max(denseline(3,:));
denseline(4,:)=denseline(4,:)/max(denseline(4,:));
% if i==1
%     accmax=maxdensematrix;
%     accdense=denseline;
% else
%     accmax=accmax+maxdensematrix;
%     accdense=accdense+denseline;
% end
% [accmax,accdense]=compute(visionacc,tacc,vibacc);
% accdenseline=zeros(4,size(densematrix(:,:,1),1));
% accdenseline(1,:)=sum(accdense(:,:,1),2);
% accdenseline(2,:)=sum(accdense(:,:,2),2);
% accdenseline(3,:)=sum(accdense(:,:,3),2);
% accdenseline(4,:)=sum(accdense(:,:,4),2);
% beams=findbeam(accmax,accdenseline,xt);

beams=findbeam(maxdensematrix,denseline,xt);
beamsrecord(:,:,i)=beams;
% meanbeams(:,:,i)=mean(beamsrecord(:,:,1:i),3);
% beams=meanbeams(:,:,i);
% beams(1,:)=mean(beams(1:2,:),1);
% beams(2,:)=beams(1,:);
% beams(3,:)=mean(beams(3:4,:),1);
% beams(4,:)=beams(3,:);
% beams=[0,6.3;0,6.3;6.3,14;6.3,14];
location(:,i)=findlocation(denseline,xt,beams);
%record baseline and distance to sensor
baseline(:,i)=xt(argmax);
% distance(:,i)=3-abs(location(:,i)-mean(beams,2));

%Revision
% for j=1:4
%     weights=zeros(1,4);
%     estimation=zeros(4,1);
%     for k=1:4
%         if k==j           
%             weights(k)=average(k,i);
%             estimation(k)=location(k,i);
%         elseif sum(abs(beams(k,:)-beams(j,:)))<6
%             weights(k)=average(k,i);
%             head=ceil(beams(j,1)/(14/200))+1;
%             tail=ceil(beams(j,2)/(14/200))+1;
%             if sum(denseline(j,head:head+43))>sum(denseline(j,tail-43:tail))
%                estimation(k)=beams(j,1)+comparison(beams(k,:),average(k,i),distance(k,i),average(j,i));
% %                  estimation(k)=beams(j,1)+distance(k,i)/(maxpoint(beams(k,:),distance(k,i))/maxpoint(beams(k,:),distance(j,i)));
%             else
%                estimation(k)=beams(j,2)-comparison(beams(k,:),average(k,i),distance(k,i),average(j,i));
% %                  estimation(k)=beams(j,2)-distance(k,i)/(maxpoint(beams(k,:),distance(k,i))/maxpoint(beams(k,:),distance(j,i)));
%             end
%         end
%     end
%      prediction(j,i)=weights*estimation/sum(weights);
% end
end
%delete outlier

% prediction=prediction(:,1:used);
% newprediction=[];
% for i=1:4
%     prediction1=prediction(i,:);
%     prediction1((prediction1>=max(prediction1)))=[];
%     prediction1((prediction1==min(prediction1)))=[];
%     newprediction=[newprediction,prediction1];
% end
% prediction=reshape(newprediction,[used-1,4]).';

%compute baseline, ourmethod, our method with revision
baselinelocation=mean(baseline,2);
averagelocation=mean(location,2);
% bestlocation=mean(prediction,2);
%%
figure(5)
beamtruth=[0.3,6.4,12.5];
value = [sum(abs(beamsrecord(1,1,:)-beamtruth(1)))/11, sum(abs(beamsrecord(1,2,:)-beamtruth(2)))/11,sum(abs(beamsrecord(3,2,:)-beamtruth(3)))/11];
name = {'beam1','beam2','beam3'};
bar(value);
title("deviation for sensor location estimation")
set(gca, 'XTickLabel', name);
ylabel('deviation/meter')
%%
figure(4)
for i=1:4
    subplot(2,2,i)
    y=vibrationfunc(xt,sensorPos(i,2),beams(i,:));
    y=y/max(y);
    plot(xt,denseline(i,:));hold on
    plot(xt,y);
 
    title(["sensor",i]);
    xlabel("footstep through hallway/meter")
    ylabel("normalized energy")
end

%%
%final histgram
figure(1)
value =sum(abs(location-sensorPos(:,2)),2)./11;
name = {'sensor1','sensor2','sensor3','sensor4'};
% bar(value);
sensorloc=[1,2,3,4];
err=var(abs(location-sensorPos(:,2)).');
errorbar(value,err);
set(gca,'xtick',sensorloc);
set(gca, 'XTickLabel', name);
title("deviation and variance from the truth")
ylabel('average deviation and variance of 4 sensors')
xlim([0,5])
truth=sensorPos(:,2);
figure(2)
value = [sum(abs(baselinelocation-truth))/4, sum(abs(averagelocation-truth))/4];
name = {'baseline','our method'};
bar(value);
title("deviation from the truth")
set(gca, 'XTickLabel', name);
ylabel('sum deviation of 4 sensors')
figure(3)
value = [sum(var(baseline.'))/4, sum(var(location.'))/4];
name = {'baseline','our method'};
bar(value);
title("result variance")
set(gca, 'XTickLabel', name);
ylabel('variance of 4 sensors')
%%
% function distance2=comparison(beams,max1,distance1,max2)
% L=beams(2)-beams(1);
% maxvalue=max1/((L^2-distance1^2)^(3/2)*distance1)*((L^2-(L/2)^2)^(3/2)*(L/2));
% desireratio=max2/maxvalue;
% x=linspace(0,L/2,30);
% test=zeros(1,30);
% for i=1:length(x)
%     test(i)=((L^2-x(i)^2)^(3/2))*x(i);
% end
% test=test/max(test);
% difference=1000;
% for i=1:length(test)
%     diff=abs(desireratio-test(i));
%     if diff<difference
%         distance2=x(i);
%         difference=diff;
%     end
% end
% end