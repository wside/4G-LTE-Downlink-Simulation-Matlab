function avgBER = BERsim_E2E(snrVect,numTrials,size,chanBW,chanMdl,Mode)
    
    global Iparams
    global NuserTable
    load ('Iparams.mat')
    load ('NuserTable.mat')

    for i = 1:numTrials
        for snr = 0:(length(snrVect)-1);
            BER(i,snr+1) = SISO_E2Efun(snr,size,chanBW,chanMdl,Mode);
        end
    end

    avgBER = mean(BER,1);
    
end
%figure
%semilogy(snrVect,avgBER,'r')