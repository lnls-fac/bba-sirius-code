%Encontra a posição no centro de um elemento
function DeltaKlimit = getDeltaKlimit(DeltaK, is_skew, ring, quadru)
    if(is_skew)
        K = abs(ring{quadru}.PolynomA(2));
        Kmax = 0.0667;
    else
        K = abs(ring{quadru}.PolynomB(2));
        Kmax = 4;
    end
    
    if((K+DeltaK)/Kmax >= 1)
        DeltaKlimit = (Kmax - K);
    else
        DeltaKlimit = DeltaK;
end
