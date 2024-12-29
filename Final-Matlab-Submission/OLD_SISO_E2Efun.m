function BER = SISO_E2Efun(snr,size,chanBW,chanMdl,Mode)
    %% Setup
    %assume nCellID = 0 everythwere
     %nS =0 (frame 1) or nS =10 (frame 5) mean diffrent mapping of control symbols
    global Iparams
    global NuserTable
    load ('Iparams.mat')
    load ('NuserTable.mat')
    %chanBW =1; %case 1 means 1.4MHZ
    contReg = 1;
    %Mode=1; %QPSK 
    prmLTE= prmsPDSCH(chanBW, contReg, Mode); %define eNodeB
    numTx =1;
    %size = 5000;
    inputBits = randi([0 1], size,1); 

    %initialize
    FRMcount = 1;
    outputBits = [];
    FRM = 0;
    bitsProcessed=0; 
    nS = 0; %initialze
    endFlag = 0;
    while FRMcount <= length(inputBits);

        Nuser = NuserLookup(chanBW,contReg,nS);
        idealFRM = ((Nuser * 2*Mode)-12)/3;
        sizes = Iparams(:,1);
        [ind,~] = find ((abs(sizes-idealFRM)) == min(abs(sizes-idealFRM)));
        FRM = min(sizes(ind));
        %redundnat but to be safe
        endcheck = (length(inputBits) - FRMcount)+1;
        if endcheck < FRM ;
            [ind,~] = find ((abs(sizes-endcheck)) == min(abs(sizes-endcheck)));
            FRM = max(sizes(ind));
            if FRM < endcheck
                FRM = sizes(ind+1); %+2 to be safe
            end
            inputBitsAppend = [inputBits; zeros( (((FRMcount-1)+FRM)-length(inputBits)), 1  )];
            inputBitsBlock = inputBitsAppend(FRMcount:((FRMcount-1)+FRM));
            endFlag = 1;
        elseif FRM > idealFRM
            FRM = sizes(ind-1);
            inputBitsBlock = inputBits(FRMcount:((FRMcount-1)+FRM));
        else
            inputBitsBlock = inputBits(FRMcount:((FRMcount-1)+FRM));
        end 
        %% Transmitter
        %DLSCH Processing--------------------------
        Indices = IntrlvrIndices(FRM); %look up f1,f2 in table in function
        t0 = TurboEncoder(inputBitsBlock,Indices); %Turbo

        %PDSCH Processing---------------------------
        t1 = Scrambler(t0,nS); %Scramble
        t2 = Modulator(t1,Mode); %Modulate (QPSK, 16QAM, or 64QAM)
        Control_UserDataLen = length(t2);
        %%

        txCsrMatrix = CSRgenerator(nS, numTx); %generate CSR (aka pilot) symbols
        [txGrid, txCsr] = REmapper_1Tx(t2, txCsrMatrix, nS, prmLTE, Control_UserDataLen, 4); %map info to txGrid
        txSignal = OFDMTx(txGrid, prmLTE); %OFDM

        %% Channel
        %Fading Channel
        %chanMdl options: 'flat-high-mobility','frequency-selective-high-mobility', 'moderate-ISI','severe-ISI', or 'none'  
        %chanMdl = 'frequency-selective-high-mobility';
        c0 = Fading_or_ISIChan(txSignal, prmLTE,chanMdl); %see function

        %add AWGN
        %snr = 3;
        noiseVar = 10.^(-snr/10);
        c1 = awgn(c0,snr);

        %% Receiver
        %inverse PDSCH Processing---------------------------
        rxSignal= c1; %Not necesary, just to show steps
        rxGrid = OFDMRx(rxSignal, prmLTE);
        [rxDataSyms, rxCsr, idx_data_adjustRx,idx_data, pdcch, pss, sss, bch] = REdemapper_1Tx(rxGrid, nS, prmLTE, Control_UserDataLen); %Recover grid and signal

        hD = ChanEstimate_1Tx(prmLTE, rxCsr, txCsr);

        nVar =1;
        EqMode=1;
        [EqSyms, Eq] = Equalizer(rxDataSyms, idx_data_adjustRx, hD, nVar, EqMode); %rxSignal should be

        %%
        r0 = DemodulatorSoft(EqSyms,Mode,noiseVar); %Demodulate   %soft so outputBits = 0.5*(1-sign(outputBits));
        r1 = DescramblerSoft(r0,nS); %Descramble     %used length(t2) to compensate for no rate matching. Ideally frame would be completely full and would not need anyway.
        %inverse DLSCH Processing--------------------------
        nIter = 6; %increase for better BER. Max 6.
        outputBitsBlock = TurboDecoder(-r1, Indices, nIter); %Turbo Decode and recover inputBits

        outputBits = [outputBits;outputBitsBlock]; 
        if endFlag == 1
            outputBits = outputBits(1:length(inputBits));
        end
        FRMcount = FRM+FRMcount;
        nS = nS + 2; nS = mod(nS, 20);
    end
    %% BER analysis
    NumErr = sum(inputBits~=outputBits); 
    BER = NumErr/length(inputBits);
end