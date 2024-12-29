clc; clear all;
Mode=1; %QPSK  %arbitrary for this function

contReg = 1;
for chanBW =1:6;
    prmLTE= prmsPDSCH(chanBW, contReg, Mode); %define eNodeB
    nS=0
    NuserTable(chanBW,1,contReg) = NuserCount(prmLTE,nS);
    nS=10
    NuserTable(chanBW,2,contReg) = NuserCount(prmLTE,nS);
    nS=4
    NuserTable(chanBW,3,contReg) = NuserCount(prmLTE,nS);
end

contReg = 2;
for chanBW =1:6;
    prmLTE= prmsPDSCH(chanBW, contReg, Mode); %define eNodeB
    nS=0
    NuserTable(chanBW,1,contReg) = NuserCount(prmLTE,nS);
    nS=10
    NuserTable(chanBW,2,contReg) = NuserCount(prmLTE,nS);
    nS=4
    NuserTable(chanBW,3,contReg) = NuserCount(prmLTE,nS);
end

contReg = 3;
for chanBW =1:6;
    prmLTE= prmsPDSCH(chanBW, contReg, Mode); %define eNodeB
    nS=0
    NuserTable(chanBW,1,contReg) = NuserCount(prmLTE,nS);
    nS=10
    NuserTable(chanBW,2,contReg) = NuserCount(prmLTE,nS);
    nS=4
    NuserTable(chanBW,3,contReg) = NuserCount(prmLTE,nS);
end