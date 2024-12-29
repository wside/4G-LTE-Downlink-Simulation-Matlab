function BER = ALT_SISO_E2Efun(snr,size,chanBW,chanMdl,Mode)
    %% Setup

    %assume nCellID = 0 everythwere
     %nS =0 (frame 1) or nS =10 (frame 5) mean diffrent mapping of control symbols

    global Iparams
    global NuserTable
    load ('Iparams.mat')
    load ('NuserTable.mat')

    %%
    %chanBW =1; %case 1 means 1.4MHZ
    contReg = 1;
   % Mode=1; 
    NsymMax = ((6144*3)+12)/(2*Mode);
    prmLTE= prmsPDSCH(chanBW, contReg, Mode); %define eNodeB
    numTx =1;
   % size = 50000;
    inputBits = randi([0 1], size,1); 

    %initialize
    FRMcount = 1;
    outputBits = [];
    FRM = 0;
    bitsProcessed=0; 
    nS = 0; %initialze



    while FRMcount <= length(inputBits);
        endFlag = 0;
        CBSegFlag = 0;
        Nuser = NuserLookup(chanBW,contReg,nS);
        sizes = Iparams(:,1);

        endcheck = (length(inputBits) - FRMcount)+1;
        endcheckSyms = ((endcheck*3)+12)/(2*Mode); 

        t2 = [] ;%make an empty t0 vector to be filled
        t2Block = [];
        
        if endcheckSyms < Nuser
            endFlag = 1;
            k = floor(endcheckSyms/NsymMax);
        else
            k = floor(Nuser/NsymMax);
        end
        if k > 0  
            CBSegFlag = 1;
            FRM = 6144;
            Indices = IntrlvrIndices(FRM);
        end
        for i = 1:k  
            inputBitsBlock(:,i) = inputBits(FRMcount:((FRMcount-1)+FRM));
            t0Block(:,i) = TurboEncoder(inputBitsBlock(:,i),Indices); 
            t1Block(:,i)= Scrambler( t0Block(:,i),nS);
            t2Block(:,i) = Modulator( t1Block(:,i),Mode);
            %t2 = [t2; t2Block(:,i)]; %Concatenation
            FRMcount = FRM+FRMcount;
        end
        t2 = t2Block(:); %Concatenation
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
            t1BlockExtra = Scrambler(t0BlockExtra,nS); %Scramble
            t2BlockExtra = Modulator(t1BlockExtra,Mode); %Modulate (QPSK, 16QAM, or 64QAM)
            t2 = [t2; t2BlockExtra]; %Finl Concatenation
            %FRMcount = FRM+FRMcount;
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
            t0BlockExtra = TurboEncoder(inputBitsBlockExtra ,Indices); %Turbo
            t1BlockExtra = Scrambler(t0BlockExtra,nS); %Scramble
            t2BlockExtra = Modulator(t1BlockExtra,Mode); %Modulate (QPSK, 16QAM, or 64QAM)
            t2 = [t2; t2BlockExtra]; %Finl Concatenation
            %FRMcount = FRM+FRMcount;
        end




      %{ 
            if endcheck < FRM ;
            [ind,~] = find ((abs(sizes-endcheck)) == min(abs(sizes-endcheck)));
            FRM = max(sizes(ind));
            elseif FRM < endcheck
                FRM = sizes(ind+1); %to be safe
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
              %}
        %% Transmitter
        %DLSCH Processing--------------------------
    %    Indices = IntrlvrIndices(FRM); %look up f1,f2 in table in function
     %   t0 = TurboEncoder(inputBitsBlock,Indices); %Turbo
    %codeword stuff here
        %PDSCH Processing---------------------------


       % t1 = Scrambler(t0,nS); %Scramble
        %t2 = Modulator(t1,Mode); %Modulate (QPSK, 16QAM, or 64QAM)
        Control_UserDataLen = length(t2);
        %%

        txCsrMatrix = CSRgenerator(nS, numTx); %generate CSR (aka pilot) symbols
        [txGrid, txCsr] = REmapper_1Tx(t2, txCsrMatrix, nS, prmLTE, Control_UserDataLen, 4); %map info to txGrid
        txSignal = OFDMTx(txGrid, prmLTE); %OFDM

        %% Channel
        %Fading Channel
        %chanMdl options: 'flat-high-mobility','frequency-selective-high-mobility', 'moderate-ISI','severe-ISI', or 'none'  
       % chanMdl = 'frequency-selective-high-mobility';
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
        nIter = 6; %increase for better BER. Max 6.

      % if CBSegFlag ~= 1;
       % r0 = DemodulatorSoft(EqSyms,Mode,noiseVar); %Demodulate   %soft so outputBits = 0.5*(1-sign(outputBits));
        %r1 = DescramblerSoft(r0,nS); %Descramble     %used length(t2) to compensate for no rate matching. Ideally frame would be completely full and would not need anyway.
    %    inverse DLSCH Processing--------------------------
         %   outputBitsBlock = TurboDecoder(-r1, Indices, nIter); %Turbo Decode and recover inputBits
          %  outputBits = [outputBits;outputBitsBlock]; 
           % if endFlag == 1
        %        outputBits = outputBits(1:length(inputBits));
            %end
            %FRMcount = FRM+FRMcount;

      %  elseif CBSegFlag == 1; 
           % inputBitsBlock(:,i) = inputBits(FRMcount:((FRMcount-1)+FRM));
          % t0Block(:,i) = TurboEncoder(inputBitsBlock(:,i),Indices); 
           % t1Block(:,i)= Scrambler( t0Block(:,i),nS);
           % t2Block(:,i) = Modulator( t1Block(:,i),Mode);
           % t2 = [t2; t2Block(:,i)] %Concatenation
            SYM = ((FRM*3)+12)/(2*Mode);


            r0BlockExtra = DemodulatorSoft(EqSyms(Control_UserDataLen-SYM+1:Control_UserDataLen),Mode,noiseVar);
            r1BlockExtra = DescramblerSoft(r0BlockExtra,nS); %Descramble
            outputBitsBlockExtra = TurboDecoder(-r1BlockExtra, Indices, nIter);
            FRMcountsave = FRM+FRMcount;
            outputBitsBlock = [];
            if CBSegFlag == 1;
                FRMtemp = 6144;
                Indices = IntrlvrIndices(FRMtemp);
                SymTemp = ((FRMtemp*3)+12)/(2*Mode);
                initial = Control_UserDataLen-SYM;
                for i = k:-1:1
                symCountTemp = ((initial)-(i*SymTemp))+1;
                r0Block(:,i) = DemodulatorSoft( EqSyms(symCountTemp:(symCountTemp-1)+SymTemp),Mode,noiseVar);
                r1Block(:,i)= DescramblerSoft( r0Block(:,i),nS);
                outputBitsBlock(:,i) = TurboDecoder(-r1Block(:,i), Indices, nIter);
                %outputBits = [outputBits;outputBitsBlock(:,i)];
                end    
            end
            outputBitsBlock = fliplr(outputBitsBlock);
            outputBits = [outputBits;outputBitsBlock(:)];
            outputBits = [outputBits;outputBitsBlockExtra];
            if endFlag == 1
                outputBits = outputBits(1:length(inputBits));
            end
            FRMcount = FRMcountsave;
            nS = nS + 2; nS = mod(nS, 20);
       %end
    end
    %% BER analysis
    NumErr = sum(inputBits~=outputBits) ;
    BER = NumErr/length(inputBits);

end