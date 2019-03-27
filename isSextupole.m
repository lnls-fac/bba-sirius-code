%Encontra o indice do Quadrupolo no anel mais proximo do elemento ind
function is_sextupole = isSextupole(family_data,ind)
    is_sextupole = false;
    I = 0;
    allSN = family_data.SN.ATIndex;
    I = find(allSN == ind);
    if(I ~= 0)
        is_sextupole = true;
    end
end 

