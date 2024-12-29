function output = ExpungeFrom(original, scrub)
    
    common = intersect(original,scrub);
    output = setxor(original,common,'stable');
    
end