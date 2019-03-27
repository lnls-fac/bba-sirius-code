%Encontra a melhor corretora para fazer o BBA em cada direcao
function corr = findWorseCorr(family_data,twi,ind,dir)
    if(dir == 'x')
        beta = twi.betax;
        phase = twi.mux;
        tune = (phase(length(phase))-phase(1))/(2*pi);
        ATIndex = family_data.CH.ATIndex;
    end
    if(dir == 'y')
        beta = twi.betay;
        phase = twi.muy;
        tune = (phase(length(phase))-phase(1))/(2*pi);
        ATIndex = family_data.CV.ATIndex;
    end
    desv = [];
    for i = 1:length(ATIndex)
        n = ATIndex(i);
        desv = [desv; abs(sqrt(beta(n))*cos(abs(phase(ind) - phase(n)) - pi*tune))];
    end
    %figure; bar(family_data.CH.ATIndex, desv);
    [M,I] = min(desv);
    corr = ATIndex(I);
end

