%Encontra o indice do Quadrupolo no anel mais proximo do elemento ind
function quadru = findNearlyQuadrupole(ring,family_data,ind)
    ind_spos = findsposOff(ring,ind);
    allQuadru = union(family_data.QN.ATIndex,family_data.QS.ATIndex);
    quadru_spos = findsposOff(ring,allQuadru);
    dist = [];
    for i = 1:length(quadru_spos)
        dist = [dist; abs(quadru_spos(i) - ind_spos)];
    end
    [M,I] = min(dist);
    quadru = allQuadru(I);
end 

