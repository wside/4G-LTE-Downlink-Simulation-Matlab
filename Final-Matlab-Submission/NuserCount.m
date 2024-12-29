function Nuser = NuserCount(prmLTE,nS)

    Nrb = prmLTE.Nrb;
    Nrb_sc = prmLTE.Nrb_sc;
    N_dciOption = prmLTE.contReg;
    N_sc = Nrb*Nrb_sc ;
    Ntotal = (prmLTE.Ndl_symb*2)*N_sc;

    N_csr =  Nrb*8;
    N_pdcch = (N_sc-(N_csr/4)) + ((N_dciOption-1)*N_sc);
    N_pss = 72;
    N_sss = 72;
    N_bch = (72-12)+(3*72);
    
    if nS == 0  %i.e. slot 0 i.e. subframe 0
        Nuser = Ntotal - (N_csr+N_pdcch+N_pss +N_sss+N_bch);
    elseif nS == 10  %i.e. slot 10 i.e. subframe 5
        Nuser = Ntotal - (N_csr+N_pdcch+N_pss+ N_sss);
    else %the other subframes i.e. {1,2,3,4,6,7,8,9}
        Nuser = Ntotal - (N_csr+N_pdcch);
    end
    
end