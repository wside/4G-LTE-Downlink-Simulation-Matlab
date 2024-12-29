function hD = ChanEstimate_1Tx(prmLTE, Rx, Ref)

    Nrb = prmLTE.Nrb; % Number of resource blocks
    Nrb_sc = prmLTE.Nrb_sc; % 12 for normal mode
    Ndl_symb = prmLTE.Ndl_symb; % 7 for normal mode
    % Assume same number of Tx and Rx antennas = 1
    % Initialize output buffer
    hD = complex(zeros(Nrb*Nrb_sc, Ndl_symb*2));
    % Estimate channel based on CSR - per antenna port
    csrRx = reshape(Rx, numel(Rx)/4, 4); % Align received pilots with reference pilots

    %Reshape received pilots
    Ref =reshape(Ref, numel(Rx)/4,4);
    hp = csrRx./Ref; % Just divide received pilot by reference pilot
    % to obtain channel response at pilot locations
    % Now use averaging to compute channel response for the whole grid

    hD=gridResponse_averageSubframe(hp, Nrb, Nrb_sc, Ndl_symb);

end