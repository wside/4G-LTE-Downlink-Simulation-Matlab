function Nuser = NuserLookup(chanBW,contReg,nS)

    %load ('NuserTable.mat') %loaded in SISO_E2E.m or SISO_E2Efun.m
    global NuserTable
    
    if nS == 0
        Nuser = NuserTable(chanBW,1,contReg);
    elseif nS == 10
        Nuser = NuserTable(chanBW,2,contReg);
    else 
        Nuser = NuserTable(chanBW,3,contReg);
    end

end