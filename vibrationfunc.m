%{
Physical model
Input: x: y-dimension location array; sensor: sensor location; beam: beams'
location
Output: 1-d energy simulated curve/trend, which can be used to match
observation.
%}
function y=vibrationfunc(x,sensor,beam)
y=zeros(1,length(x));
for i=1:length(x)
    if x(i)<=beam(1)||x(i)>=beam(2)
       y(i)=0; 
    elseif x(i)>=sensor
       y(i)=((beam(2)-x(i))*(sensor-beam(1))*((beam(2)-beam(1))^2-(beam(2)-x(i))^2-(sensor-beam(1))^2))^1;
    elseif x(i)<sensor
       y(i)=((x(i)-beam(1))*(beam(2)-sensor)*((beam(2)-beam(1))^2-(x(i)-beam(1))^2-(beam(2)-sensor)^2))^1;
    end
%     elseif x(i)>=sensor
%        y(i)=((beam(2)-x(i))*(x(i)-beam(1))*((beam(2)-beam(1))^2-(beam(2)-x(i))^2-(x(i)-beam(1))^2))^2/((x(i)-sensor)^2+3);
%     elseif x(i)<sensor
%        y(i)=((x(i)-beam(1))*(beam(2)-x(i))*((beam(2)-beam(1))^2-(x(i)-beam(1))^2-(beam(2)-x(i))^2))^2/((x(i)-sensor)^2+3);
%     end
%     elseif x(i)>=sensor
%        y(i)=((beam(2)-x(i))*(x(i)-beam(1))*((beam(2)-beam(1))^2-(beam(2)-x(i))^2-(x(i)-beam(1))^2))^2+80*(beam(2)-beam(1))^4/((x(i)-sensor)^2+1);
%     elseif x(i)<sensor
%        y(i)=((x(i)-beam(1))*(beam(2)-x(i))*((beam(2)-beam(1))^2-(x(i)-beam(1))^2-(beam(2)-x(i))^2))^2+80*(beam(2)-beam(1))^4/((x(i)-sensor)^2+1);
%     end
end
y=y/200;
end