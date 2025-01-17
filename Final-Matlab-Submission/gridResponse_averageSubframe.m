function hD=gridResponse_averageSubframe(hp, Nrb, Nrb_sc, Ndl_symb)
    % Average over the two same Freq subcarriers, and then interpolate between
    % them - get all estimates and then repeat over all columns (symbols).
    % The interpolation assumes NCellID = 0.
    % Time average two pilots over the slots, then interpolate (F)
    % between the 4 averaged values, repeat for all symbols in subframe
    h1_a1 = mean([hp(:, 1), hp(:, 3)],2);
    h1_a2 = mean([hp(:, 2), hp(:, 4)],2);
    h1_a_mat = [h1_a1 h1_a2].';
    h1_a = h1_a_mat(:);
    h1_all = complex(zeros(length(h1_a)*3,1));
    for i = 1:length(h1_a)-1
        delta = (h1_a(i+1)-h1_a(i))/3;
        h1_all((i-1)*3+1) = h1_a(i);
        h1_all((i-1)*3+2) = h1_a(i)+delta;
        h1_all((i-1)*3+3) = h1_a(i)+2*delta;
    end
    % fill the last three - use the last delta
    h1_all(end-2) = h1_a(end);
    h1_all(end-1) = h1_a(end)+delta;
    h1_all(end) = h1_a(end)+2*delta;
    % Compute the channel response over the whole grid by repeating
    hD = h1_all(1:Nrb*Nrb_sc, ones(1, Ndl_symb*2));
end