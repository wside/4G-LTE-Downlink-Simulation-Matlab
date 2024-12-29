function [out, Eq] = Equalizer(in, idx_data, hD, nVar, EqMode)
    hD = hD(:);
    hD = hD(idx_data);
    switch EqMode
        case 1,
        Eq = ( conj(hD))./((conj(hD).*hD)); % Zero forcing
        case 2,
        Eq = ( conj(hD))./((conj(hD).*hD)+nVar); % MMSE
        otherwise,
        error('Two equalization modes vaible: Zero forcing or MMSE');
    end
    out=in.*Eq;
end