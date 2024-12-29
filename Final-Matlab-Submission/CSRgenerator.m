function y = CSRgenerator(nS, numTx)
    persistent hSeqGen;
    persistent hInt2Bit;
    % Assumed parameters
    NcellID = 0; % One of possible 504 values
    Ncp = 1; % for normal CP, or 0 for Extended CP
    NmaxDL_RB = 100; % largest downlink bandwidth configuration, in resource blocks
    y = complex(zeros(NmaxDL_RB*2, 2, 2, numTx));
    l = [0; 4]; %OFDM symbol idx in a slot for common first antenna port
    % Buffer for sequence per OFDM symbol
    seq = zeros(size(y,1)*2, 1); % *2 for complex outputs
    if isempty(hSeqGen)
        hSeqGen = comm.GoldSequence('FirstPolynomial',[1 zeros(1, 27) 1 0 0 1],...
        'FirstInitialConditions', [zeros(1, 30) 1], ...
        'SecondPolynomial', [1 zeros(1, 27) 1 1 1 1],...
        'SecondInitialConditionsSource', 'Input port',...
        'Shift', 1600,...
        'SamplesPerFrame', length(seq));
        hInt2Bit = comm.IntegerToBit('BitsPerInteger', 31);
    end
    % Generate the common first antenna port sequences
    for i = 1:2 % slot wise
        for lIdx = 1:2 % symbol wise
            c_init = (2^10)*(7*((nS+i-1)+1)+l(lIdx)+1)*(2*NcellID+1) + 2*NcellID + Ncp;
            % Convert to binary vector
            iniStates = step(hInt2Bit, c_init);
            % Scrambling sequence - as per Section 7.2, 36.211
            seq = step(hSeqGen, iniStates);
            % Store the common first antenna port sequences
            y(:, lIdx, i, 1) = (1/sqrt(2))*complex(1-2.*seq(1:2:end), 1-2.*seq(2:2:end));
        end
    end
end