test = [0 0 0 0 
        0 0 0 1
        0 0 1 0
        0 0 1 1
        0 1 0 0
        0 1 0 1
        0 1 1 0
        0 1 1 1
        1 0 0 0
        1 0 0 1
        1 0 1 0
        1 0 1 1
        1 1 0 0
        1 1 0 1
        1 1 1 0
        1 1 1 1];
    test = reshape(test', (16*4),1);
    
modulated = Modulator(test,2);
easy = modulated.*sqrt(10);