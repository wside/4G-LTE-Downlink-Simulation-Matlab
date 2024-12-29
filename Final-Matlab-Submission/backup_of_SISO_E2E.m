function BER = SISO_E2Efun(snr,size,chanBW,chanMdl,Mode)
    %% Setup
    %assume nCellID = 0 everythwere
    %nS =0 (frame 1) or nS =10 (frame 5) mean diffrent mapping of control symbols
    
    global Iparams
    global NuserTable
    load ('Iparams.mat')
    load ('NuserTable.mat')

    %%
   % chanBW =1; %case 1 means 1.4MHZ
    contReg = 1;
   % Mode=1; 
    NsymMax = ((6144*3)+12)/(2*Mode);
    prmLTE= prmsPDSCH(chanBW, contReg, Mode); %define eNodeB
    numTx =1;
   % size = 100000;
    inputBits = randi([0 1], size,1); 
    Control_len_inputbits = length(inputBits);
    nIter = 6; %Max Number of Iteratons of the TurboDecoder %increase for better BER. Max 6.

    %initialize
    FRMcount = 1;
    outputBits = [];
    FRM = 0;
    bitsProcessed=0; 
    nS = 0; %initialze

    outputBits = [];

    while FRMcount <= length(inputBits);
        %% Transmitter
        %% 
        %---------DLSCH Processing and Code Block Segmentation------------
        CBSegFlag = 0; %reset the flag
        endFlag = 0; %reset the flag
        Nuser = NuserLookup(chanBW,contReg,nS);
        sizes = Iparams(:,1);

        endcheck = (length(inputBits) - FRMcount)+1;
        endcheckSyms = ((endcheck*3)+12)/(2*Mode); 

        t0 = [] ;%make an empty t0 vector to be filled
        t0Block = []; 
        if endcheckSyms < Nuser
            endFlag = 1;
            k = floor(endcheckSyms/NsymMax);
        else
            k = floor(Nuser/NsymMax);
        end
        if k > 0  
            CBSegFlag = 1; %will create 1 or more codeblocks of maxiumum size i.e. will enter the for loop below
            FRM = 6144;
            Indices = IntrlvrIndices(FRM);
        end
        for i = 1:k  
            inputBitsBlock(:,i) = inputBits(FRMcount:((FRMcount-1)+FRM));
            t0Block(:,i) = TurboEncoder(inputBitsBlock(:,i),Indices); 
            FRMcount = FRM+FRMcount;
        end
        t0 = t0Block(:); %Code Block Concatenation
        if endFlag == 1;
            SymsLeft = endcheckSyms - NsymMax*k ;
            idealFRM = ((SymsLeft * 2*Mode)-12)/3;
            [ind,~] = find ((abs(sizes-idealFRM)) == min(abs(sizes-idealFRM)));
            FRM = min(sizes(ind));
                if (FRM < idealFRM) & (ind~=188);
                    FRM = sizes((find(FRM==sizes))+1); %to be safe
                end
            Indices = IntrlvrIndices(FRM);
            inputBitsAppend = [inputBits; zeros( (((FRMcount-1)+FRM)-length(inputBits)), 1  )];
            inputBitsBlockExtra = inputBitsAppend(FRMcount:((FRMcount-1)+FRM));
            t0BlockExtra = TurboEncoder(inputBitsBlockExtra,Indices); %Turbo
            t0 = [t0; t0BlockExtra]; %Final Concatenation
        end

        if endFlag ~= 1;
            SymsLeft = Nuser - NsymMax*k;
            idealFRM = ((SymsLeft * 2*Mode)-12)/3;
            [ind,~] = find ((abs(sizes-idealFRM)) == min(abs(sizes-idealFRM)));
            FRM = min(sizes(ind));
            if FRM > idealFRM %to be safe
                FRM = sizes((find(FRM==sizes))-1);
            end
            Indices = IntrlvrIndices(FRM);
            inputBitsBlockExtra = inputBits(FRMcount:((FRMcount-1)+FRM));
            t0BlockExtra = TurboEncoder(inputBitsBlockExtra,Indices); %Turbo
            t0 = [t0; t0BlockExtra]; %Final Concatenation
        end

        %% 
        %--------------------PDSCH Processing-----------------------------
        t1 = Scrambler(t0,nS); %Scramble
        t2 = Modulator(t1,Mode); %Modulate (QPSK, 16QAM, or 64QAM)
        Control_UserDataLen = length(t2);
        %%
        txCsrMatrix = CSRgenerator(nS, numTx); %generate CSR (aka pilot) symbols
        [txGrid, txCsr] = REmapper_1Tx(t2, txCsrMatrix, nS, prmLTE, Control_UserDataLen, 4); %map info to txGrid
        txSignal = OFDMTx(txGrid, prmLTE); %OFDM

        %% Channel
        %%
        %Fading Channel
        %chanMdl options: 'flat-high-mobility','frequency-selective-high-mobility', 'moderate-ISI','severe-ISI', or 'none'  
        c0 = Fading_or_ISIChan(txSignal, prmLTE,chanMdl); %see function

        %add AWGN
       % snr = 100;
        noiseVar = 10.^(-snr/10);
        c1 = awgn(c0,snr);

        %% Receiver
        %%
    %---------------------inverse PDSCH Processing---------------------------
        rxGrid = OFDMRx(c1, prmLTE);
        [rxDataSignal, rxCsr, idx_data_adjustRx,idx_data, pdcch, pss, sss, bch] = REdemapper_1Tx(rxGrid, nS, prmLTE, Control_UserDataLen); %Recover grid and signal

        hD = ChanEstimate_1Tx(prmLTE, rxCsr, txCsr);

        nVar =1;
        EqMode=1;
        [EqSignal, Eq] = Equalizer(rxDataSignal, idx_data_adjustRx, hD, nVar, EqMode); %rxSignal should be

        %%
        r0 = DemodulatorSoft(EqSignal,Mode,noiseVar); %Demodulate   %soft so outputBits = 0.5*(1-sign(outputBits));
        r1 = DescramblerSoft(r0,nS); %Descramble     %used length(t2) to compensate for no rate matching. Ideally frame would be completely full and would not need anyway.

    %%     
    %-----------------inverse DLSCH Processing--------------------------
            TuserLen =(Control_UserDataLen*2*Mode);
            TURBO = ((FRM*3)+12);
            outputBitsBlockExtra = TurboDecoder(-r1(TuserLen-TURBO+1:TuserLen), Indices, nIter);
            FRMcountsave = FRM+FRMcount;
            outputBitsBlock = [];
            if CBSegFlag == 1;
                FRMtemp = 6144;
                Indices = IntrlvrIndices(FRMtemp);
                TURBOTemp = ((FRMtemp*3)+12);
                initial = TuserLen-TURBO;
                for i = k:-1:1
                    turboCountTemp = ((initial)-(i*TURBOTemp))+1;
                    outputBitsBlock(:,i) = TurboDecoder(-r1(turboCountTemp:(turboCountTemp-1)+TURBOTemp), Indices, nIter);
                end    
            end
            outputBitsBlock = fliplr(outputBitsBlock);
            outputBits = [outputBits;outputBitsBlock(:)];
            outputBits = [outputBits;outputBitsBlockExtra];
            if endFlag == 1
                outputBits = outputBits(1:Control_len_inputbits);
            end

            FRMcount = FRMcountsave;
            nS = nS + 2; nS = mod(nS, 20);
    end %end of big while loop

    %% BER analysis
    NumErr = sum(inputBits~=outputBits) ;
    BER = NumErr/length(inputBits);

end %end of function