function out = Fading_or_ISIChan(in, prmLTE, chanMdl)
    switch chanMdl
        case 'flat-high-mobility'
        rayChan = comm.RayleighChannel(...
            'SampleRate', prmLTE.chanSRate, ...
            'PathDelays',0, ...
            'AveragePathGains',0, ...
            'NormalizePathGains',true, ...
            'MaximumDopplerShift',70, ...
            'RandomStream','mt19937ar with seed', ...
            'Seed',22);
            out= rayChan(in);
            
        case 'frequency-selective-high-mobility'
            rayChan = comm.RayleighChannel(...
            'SampleRate', prmLTE.chanSRate, ...
            'PathDelays',[0 10 20 30 100]*(1/prmLTE.chanSRate), ...
            'AveragePathGains',[0 -3 -6 -8 -17.2], ...
            'NormalizePathGains',true, ...
            'MaximumDopplerShift',70, ...
            'RandomStream','mt19937ar with seed', ...
            'Seed',22);
            out= rayChan(in);
            
        case 'moderate-ISI'
            chCoeffs = [1; .2; .4];
            out = filter(chCoeffs,1,in);
        case 'severe-ISI'
            chCoeffs = [0.227 0.460 0.688 0.460 0.227];
            out = filter(chCoeffs,1,in);
        case 'none'
            out = in; %do nothing
    end
end