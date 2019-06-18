%Cria um anel com DeltaK no elemento de indice ind
function ringDelta = setRingDelta_sextder(ring,ind,DeltaK,is_skew,is_sextupole)
    ringDelta = ring;
    if(is_sextupole == true)
        %ringDelta{ind}.PolynomB(3) = ringDelta{ind}.PolynomB(3) + DeltaK;
        ringDelta{ind}.PolynomB(3) = DeltaK;
    else
        if(is_skew == false)
            ringDelta{ind}.PolynomB(2) = ringDelta{ind}.PolynomB(2) + DeltaK;
        end
        if(is_skew == true)
            ringDelta{ind}.PolynomA(2) = ringDelta{ind}.PolynomA(2) + DeltaK;
        end
end

