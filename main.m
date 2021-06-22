clc;
clear;
Fs=44100;
ts=1/Fs;

%1개의 채널로 추출
[a,Fs]=audioread('song1.mp3');
[b,Fs2]=audioread('song2.mp3');
[c,Fs3]=audioread('song3.mp3');

%0~10초만 남기고 제거 - a1,b1,c1은 음악 파일의 데이터를 10초까지 저장
t=0:ts:10;
a1=zeros(1,size(t,2)); % 크기 지정
b1=zeros(1,size(t,2));
c1=zeros(1,size(t,2));
for i=1:size(t,2)  %행렬 transpose 
    a1(1,i)=a(i,1);
    b1(1,i)=b(i,1);
    c1(1,i)=c(i,1);
end

% interpolation 실행
ts_interp=ts/8; %점과 점 사이에 7개의 데이터(점)를 추가해야하므로 8 간격으로 나눔
t2=0:ts_interp:10;

a2=interp1(t,a1,t2);
b2=interp1(t,b1,t2);
c2=interp1(t,c1,t2);

figure  
plot(t,a1,'o'); hold on;  %예시로 a2 그래프를 출력
axis([3 3.0002 -1 1]);
plot(t2,a2,':.');


%송신단
fc1=10*10^3;
fc2=30*10^3;
fc3=50*10^3;

Xc1=a2.*cos(2*pi*fc1*t2);
Xc2=b2.*cos(2*pi*fc2*t2);
Xc3=c2.*cos(2*pi*fc3*t2);
Xc=Xc1+Xc2+Xc3;

%수신단
r=Xc; % 수신한 신호

%각각 다른 주파수로 cos을 곱하여 세 종류 신호로 나눈다. 
r1=r*cos(2*pi*fc1*t2);
r2=r*cos(2*pi*fc2*t2);
r3=r*cos(2*pi*fc3*t2);


%LPF 필터 
RC=0.0005;
rc1=zeros(1,size(r1,2));
for i=2:size(r1,2)
    rc1(i)=(RC-ts_interp)/RC*rc1(i-1)+ts_interp/RC*r1(i-1);
end

rc2=zeros(1,size(r2,2));
for i=2:size(r2,2)
    rc2(i)=(RC-ts_interp)/RC*rc2(i-1)+ts_interp/RC*r2(i-1);
end

rc3=zeros(1,size(r3,2));
for i=2:size(r3,2)
    rc3(i)=(RC-ts_interp)/RC*rc3(i-1)+ts_interp/RC*r3(i-1);
end

%DC 성분제거
rc1=rc1-mean(rc1); %mean함수를 이용하여 DC 성분 제거
rc2=rc2-mean(rc2);
rc3=rc3-mean(rc3);

%Sampling - interpolation에 의해 간격 개수가 늘어났으므로 원래대로 되돌린다.
S1=zeros(1,size(t,2));
S2=zeros(1,size(t,2));
S3=zeros(1,size(t,2));

for i=1:size(t,2)
    S1(i)=rc1(1+8*(i-1));
    S2(i)=rc2(1+8*(i-1));
    S3(i)=rc3(1+8*(i-1));
end

%Normalization : 샘플링 후 신호 진폭 범위를 (-1,1)로 만든다
S1=S1/max(abs(S1));
S2=S2/max(abs(S2));
S3=S3/max(abs(S3));

%파일 저장
audiowrite('song1.wav',S1,Fs);
audiowrite('song2.wav',S2,Fs);
audiowrite('song3.wav',S3,Fs);







