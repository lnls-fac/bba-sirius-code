%Cria um anel com DeltaK no elemento de indice ind
function ringDelta = setRingDelta(ring,ind,DeltaK,is_skew)
    ringDelta = ring;
    if(is_skew == false)
        ringDelta{ind}.PolynomB(2) = ringDelta{ind}.PolynomB(2) + DeltaK;
    end
    if(is_skew == true)
        ringDelta{ind}.PolynomA(2) = ringDelta{ind}.PolynomA(2) + DeltaK;
    end
end

