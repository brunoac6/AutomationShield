%Artigo CBA 2022

%Autores:
%Bruno de Araujo Coutinho
%Frederico Barcelos
%Arthur N. Montanari
%Everthon de Souza Oliveira

clc
clear all
close all
format long e

%Sinal de referência r
Amp=1; %Amplitude da referência
Te=20; %Período fundamental da referência

%Modelo da planta em s
num_s=0.5;
den_s=[1 1];
G_s=tf(num_s,den_s);

%Discretização da planta
T=0.01; %Período de amostragem
[num_z,den_z] = c2dm(num_s,den_s,T,'zoh');
G_z=tf(num_z,den_z,T);
bz=num_z(2); %Coeficiente do numerador
az=den_z(2); %Coeficiente do denominador

%Modelo de referência em s
numW_s=2;
denW_s=[1 2];
W_s=tf(numW_s,denW_s);
am=denW_s(2);

%Discretização do modelo de referência
[numW_z,denW_z] = c2dm(numW_s,denW_s,T,'zoh');
W_z=tf(numW_z,denW_z,T);
bmz=numW_z(2); %Coeficiente do numerador
amz=denW_z(2); %Coeficiente do denominador

%Reserva de espaço para os vetores de interesse
ntotal=1e5; %Número total de pontos no gráficos
r=zeros(1,ntotal);
ym=zeros(1,ntotal);
y=zeros(1,ntotal);
u=zeros(1,ntotal);
e1=zeros(1,ntotal);
tempo=zeros(1,ntotal);
theta1=zeros(1,ntotal); %Ganho do controlador
theta2=zeros(1,ntotal); %Ganho do controlador
zetar=zeros(1,ntotal); %r filtrado por am/(s+am)
zetay=zeros(1,ntotal); %y filtrado por am/(s+am)

%Taxa de adaptação do mecanismo de adaptação de ganhos
g=5;

%Projeto do MRC
theta1_est = bmz/bz;
theta2_est = (amz - az)/bz;
%theta1_est = 3.980099667498336;
%theta2_est = 1.980099667498357;

%Filtro digital para obtenção do zetar e do zetay
%zetar(s)=F(s)*y(s)
%zetay(s)=F(s)*y(s)
%F(s)=am/(s+am)
num2=am;
den2=[1 am];
G2=tf(num2,den2);

%Discretizando
[num2_z,den2_z]=c2dm(num2,den2,T,'zoh');
beta=num2_z(2);
alfa=den2_z(2);
%Obtem-se
%zetar(z)=F(z)*y(z)
%zetay(z)=F(z)*y(z)
%F(z)=beta/(z+alfa)

%Laço de repetição para executação do controlador MRAC
for k=2:ntotal
    r(k)=Amp*square(2*pi*k*T/Te);
    ym(k)=-amz*ym(k-1)+bmz*r(k-1);
    % --y(k)=-az*y(k-1)+bz*u(k-1);
    y(k) = HeatShield.sensorRead();
    theta1(k) = theta1(k-1) - T*g*zetar(k-1)*e1(k-1);
    theta2(k) = theta2(k-1) + T*g*zetay(k-1)*e1(k-1);
    u(k)=theta1(k)*r(k) - theta2(k)*y(k);
    Uc(k) = constrain(u(k), 0, 100);%
    HeatShield.cartrigeActuator(Uc(k)); %
    e1(k)=y(k)-ym(k);
    %Saídas dos filtros auxiliares para o mecanisno de adaptação
    zetar(k)=-alfa*zetar(k-1)+beta*r(k-1);
    zetay(k)=-alfa*zetay(k-1)+beta*y(k-1);
    tempo(k)=(k-2)*T;
end