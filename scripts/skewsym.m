% Forms the skew-symmetric matrix of the incoming vector x.
function xskew = skewsym(x)
    xskew = [0,-x(3), x(2); x(3), 0,-x(1); -x(2), x(1), 0];
end