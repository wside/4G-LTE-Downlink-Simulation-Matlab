
clc; clear all;
load('eqalizetest.mat')
temp = rxGrid(:);
temp(idx_data_adjustRx) = Eq;
eqGrid = reshape(temp,72,14);

%edited from matlab built in function 'hDownlinkEstimationEqualizationResults.m' 
%plot txGrid
figure;
dims = size(txGrid);
surf(20*log10(abs(txGrid)));
title('Transmitted resource grid');
ylabel('Subcarrier');
xlabel('Symbol');
zlabel('absolute value (dB)');
axis([1 dims(2) 1 dims(1) -40 10]);

% Plot received grid error on logarithmic scale
figure;
dims = size(rxGrid);
surf(20*log10(abs(rxGrid)));
title('Received resource grid');
ylabel('Subcarrier');
xlabel('Symbol');
zlabel('absolute value (dB)');
axis([1 dims(2) 1 dims(1) -40 10]);

% Plot equalized grid error on logarithmic scale
figure
surf(20*log10(abs(eqGrid)));
title('Equalized resource grid');
ylabel('Subcarrier');
xlabel('Symbol');
zlabel('absolute value (dB)');
axis([1 dims(2) 1 dims(1) -40 10]);
