function p= prmsPDSCH(chanBW, contReg, modType)
    % Returns parameter structures for LTE PDSCH simulation.
    % Assumes a FDD, normal cyclic prefix, full-bandwidth, single-user
    % SISO or SIMO downlink transmission.
    %% PDSCH parameters
    switch chanBW
        case 1 % 1.4 MHz
        BW = 1.4e6; N = 128; cpLen0 = 10; cpLenR = 9;
        Nrb = 6; chanSRate = 1.92e6;
        case 2 % 3 MHz
        BW = 3e6; N = 256; cpLen0 = 20; cpLenR = 18;
        Nrb = 15; chanSRate = 3.84e6;
        case 3 % 5 MHz
        BW = 5e6; N = 512; cpLen0 = 40; cpLenR = 36;
        Nrb = 25; chanSRate = 7.68e6;
        case 4 % 10 MHz
        BW = 10e6; N = 1024; cpLen0 = 80; cpLenR = 72;
        Nrb = 50; chanSRate = 15.36e6;
        case 5 % 15 MHz
        BW = 15e6; N = 1536; cpLen0 = 120; cpLenR = 108;
        Nrb = 75; chanSRate = 23.04e6;
        case 6 % 20 MHz
        BW = 20e6; N = 2048; cpLen0 = 160; cpLenR = 144;
        Nrb = 100; chanSRate = 30.72e6;
    end
    p.BW = BW; % Channel bandwidth
    p.N = N; % NFFT
    p.cpLen0 = cpLen0; % Cyclic prefix length for 1st symbol
    p.cpLenR = cpLenR; % Cyclic prefix length for remaining
    p.Nrb = Nrb; % Number of resource blocks
    p.chanSRate = chanSRate; % Channel sampling rate
    p.contReg = contReg;
    p.numTx = 1; 
    p.numRx = 1; 
    p.numLayers = 1;
    p.numCodeWords = 1;
    % For Normal cyclic prefix, FDD mode
    p.deltaF = 15e3; % subcarrier spacing
    p.Nrb_sc = 12; % no. of subcarriers per resource block
    p.Ndl_symb = 7; % no. of OFDM symbols in a slot
    Qm = 2 * modType; %no of bits per symbol
    p.Qm = Qm;
end