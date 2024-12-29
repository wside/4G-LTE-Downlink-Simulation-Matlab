%% Compare Modulation Schemes
%% 
clc; clear all;
%%
initStart = tic

%chanMdl options: 'none', 'flat-high-mobility','frequency-selective-high-mobility', 'moderate-ISI', or 'severe-ISI'  
chanMdl = 'flat-high-mobility';
snrVect = [0:16];
numTrials= 10;
size = 10000;

for chanBW =1; %chanBW= {1,2,3,4,5,6} = {1.4 MHz ,3 MHz, 5 MHz, 10 MHz, 15 MHz,20Mhz}
    sTime = tic;
    
    Mode=1; 
    avgBER_QPSK = BERsim_E2E(snrVect,numTrials,size,chanBW,chanMdl,Mode);

    Mode = 2;
    avgBER_16QAM = BERsim_E2E(snrVect,numTrials,size,chanBW,chanMdl,Mode);

    Mode = 3;
    avgBER_64QAM = BERsim_E2E(snrVect,numTrials,size,chanBW,chanMdl,Mode);
    
    TimeElapsedVect(chanBW) = toc(sTime);
end

Totaltime = toc(initStart)
%%
figure
semilogy(snrVect,avgBER_QPSK)
title(['BER over ', chanMdl ,' Fading Channel with AWGN'])
hold on
semilogy(snrVect,avgBER_16QAM)
hold on
semilogy(snrVect,avgBER_64QAM)
legend('QPSK', '16QAM', '64QAM')
xlabel('SNR')
ylabel('BER')


%% 
%Compare above section to Theory

%load ('BERsim_AWGN.mat');  %comment out if want to compare to new values
%snrVect = [0:16]; %comment out if just want to see theoretical values

M = 4;       
N = log2(M);
EbNo = snrVect - 10*log10(N);
berTheoryQPSK= berawgn(EbNo,'psk',M,'nondiff');

M = 16;       
N = log2(M);
EbNo = snrVect - 10*log10(N);
berTheory16QAM = berawgn(EbNo,'qam',M,'nondiff');

M = 64;       
N = log2(M);
EbNo = snrVect - 10*log10(N);
berTheory64QAM = berawgn(EbNo,'qam',M,'nondiff');

figure
semilogy(snrVect,avgBER_QPSK ,'LineWidth', 1.5, 'Color','b')
title(['Theory vs. LTESimulated BER over ', chanMdl ,' Fading Channel with AWGN'])
hold on
semilogy(snrVect,avgBER_16QAM ,'LineWidth', 1.5, 'Color','r')
semilogy(snrVect,avgBER_64QAM ,'LineWidth', 1.5, 'Color','g')

semilogy(snrVect,berTheoryQPSK, 'Color','b', 'LineStyle', '--')
semilogy(snrVect,berTheory16QAM, 'Color','r', 'LineStyle', '--')
semilogy(snrVect,berTheory64QAM, 'Color','g','LineStyle', '--')

legend('simQPSK', 'sim16QAM', 'sim64QAM','theoryQPSK', 'theory16QAM', 'theory64QAM','Location','sw')
xlabel('SNR')
ylabel('BER')

%% Compare Different Types of Fading Channels for a Single ModType
clc; clear all;
tic
snrVect = [0:16];
numTrials= 20; %decrease for faster simulation
size = 15000;
chanBW =1; %chanBW= {1,2,3,4,5,6} = {1.4 MHz ,3 MHz, 5 MHz, 10 MHz, 15 MHz}
Mode=1;

chanMdl = 'flat-high-mobility';
QPSK1 = BERsim_E2E(snrVect,numTrials,size,chanBW,chanMdl,Mode);
chanMdl = 'frequency-selective-high-mobility'; 
QPSK2 = BERsim_E2E(snrVect,numTrials,size,chanBW,chanMdl,Mode);
chanMdl = 'moderate-ISI';
QPSK3 = BERsim_E2E(snrVect,numTrials,size,chanBW,chanMdl,Mode);
chanMdl = 'severe-ISI';
QPSK4 = BERsim_E2E(snrVect,numTrials,size,chanBW,chanMdl,Mode);
chanMdl = 'none'; %no fading, just AWGN
QPSK5 = BERsim_E2E(snrVect,numTrials,size,chanBW,chanMdl,Mode);
toc
%%
%load ('differentchanBER.mat');  %comment out if want to compare to new values
figure
semilogy(snrVect,QPSK1)
title('BER for QPSK or M-QAM over Different Types of Channels')
hold on
semilogy(snrVect,QPSK2)
semilogy(snrVect,QPSK3)
semilogy(snrVect,QPSK4)
semilogy(snrVect,QPSK5)
legend('flat-high-mobility','frequency-selective-high-mobility', 'moderate-ISI', 'severe-ISI', 'none') 
xlabel('SNR')
ylabel('BER')

