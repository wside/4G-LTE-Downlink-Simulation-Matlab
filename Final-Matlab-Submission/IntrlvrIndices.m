function indices = IntrlvrIndices(blkLen)

    %load ('Iparams.mat') %loaded in SISO_E2E.m or SISO_E2Efun.m
    global Iparams
    
    if ismember(blkLen,Iparams(:,1)) == 0;
        error('FRM entered does not exist in lookup table.')
    end
    
    [iRow,~] = find(blkLen == Iparams(:,1));
    f1 = Iparams(iRow,2);
    f2 = Iparams(iRow,3);

    Idx = (0:blkLen-1).';
    indices = mod(f1*Idx + f2*Idx.^2, blkLen) + 1;
    
end