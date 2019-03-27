%Encontra o indice do Quadrupolo no anel mais proximo do elemento ind
function is_s = isSkew(family_data,ind)
    is_s = false;
    I = 0;
    allQS = family_data.QS.ATIndex;
    I = find(allQS == ind);
    if(I ~= 0)
        is_s = true;
    end
end 

