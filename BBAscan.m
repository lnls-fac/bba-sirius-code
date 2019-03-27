%Faz o BBA e retorna o valor do Kick para a menor distorçao de orbita
function BBAresult = BBAscan(ring,family_data,ind,bpm,corr,dir,is_skew,kickMax,range,DeltaK,random_error)
    %Inicializa as variáveis
    step_kick = kickMax/range;
    ringDelta = setRingDelta(ring,ind,DeltaK,is_skew);
    kicks = [];
    meritfunction = [];
    centerQuadru = [];
    centerBPM = [];
    errorRandomMax = 100/(10^9); %100nm é o erro aleatório esperado dos BPM's
    
    %faz a varredura na corretora e realiza o BBA
    for n = -range:range
        ringTemp = lnls_set_kickangle(ring, lnls_get_kickangle(ring,corr,dir) + n*step_kick, corr, dir);
        ringDeltaTemp = lnls_set_kickangle(ringDelta, lnls_get_kickangle(ringDelta,corr,dir) + n*step_kick, corr, dir);
        kicks = [kicks; n*step_kick];
        orbitTemp = findorbit6(ringTemp,family_data.BPM.ATIndex);
        orbitDeltaTemp = findorbit6(ringDeltaTemp,family_data.BPM.ATIndex);
        f = 0;
        for i = 1:length(family_data.BPM.ATIndex)
            %coloca erro aleatório nas medidas dos BPM's
            if(random_error)
                r1 = 2*(rand()- (1/2));
                r2 = 2*(rand()- (1/2));
            else
                r1 = 0;
                r2 = 0;
            end
            dx = (orbitDeltaTemp(1,i) - orbitTemp(1,i)) + errorRandomMax*r1;
            dy = (orbitDeltaTemp(3,i) - orbitTemp(3,i)) + errorRandomMax*r2;
            f = f + dx*dx + dy*dy;
        end
        f = f/length(family_data.BPM.ATIndex);
        meritfunction = [meritfunction, f];
        %Obtém variáveis internas da simulação para analisar o BBA
        %E a medida do BPM próximo ao Quadrupolo
        orbitTemp = findorbit6(ringTemp,1:length(ringTemp));
        if(dir == 'x')
            pos = findCenter(ringTemp,orbitTemp,ind);
            centerQuadru = [centerQuadru, pos(1)];
            pos = findCenter(ringTemp,orbitTemp,bpm);
            centerBPM = [centerBPM, pos(1)];
        end
        if(dir == 'y')
            pos = findCenter(ringTemp,orbitTemp,ind);
            centerQuadru = [centerQuadru, pos(3)];
            pos = findCenter(ringTemp,orbitTemp,bpm);
            centerBPM = [centerBPM, pos(3)];
        end
    end
    
    %figure; plot(kicks,sqrt(meritfunction));
    
    %Obtém os valores que minimizam a função de mérito
    %Utilizando Interpolação Spline
    %OBS: Regressão linear assumindo uma parábola não funcionou muito bem
    vkicks = min(kicks):(max(kicks)-min(kicks))/1000000:max(kicks);
    interp = interp1(kicks,meritfunction,vkicks,'spline');
    [M,I] = min(interp);
    kickMin = vkicks(I);
    functionMin = M;
    
    vQuadru = min(centerQuadru):(max(centerQuadru)-min(centerQuadru))/1000000:max(centerQuadru);
    interp = interp1(centerQuadru,meritfunction,vQuadru,'spline');
    [M,I] = min(interp);
    centerQuadruMin = vQuadru(I);
    
    vBPM = min(centerBPM):(max(centerBPM)-min(centerBPM))/1000000:max(centerBPM);
    interp = interp1(centerBPM,meritfunction,vBPM,'spline');
    [M,I] = min(interp);
    centerBPMMin = vBPM(I);
    
    %Obtém a trajetória com o kick que minimiza a função de mérito
    %E obtém mais variáveis internas para analisar o BBA
    ringTemp = lnls_set_kickangle(ring, lnls_get_kickangle(ring,corr,dir) + kickMin, corr, dir);
    orbitTemp = findorbit6(ringTemp,1:length(ringTemp));
    if(dir == 'x')
        pos = findCenter(ringTemp,orbitTemp,ind);
        angQuadru = pos(2);
        posAux = pos(3); 
    end
    if(dir == 'y')
        pos = findCenter(ringTemp,orbitTemp,ind);
        angQuadru = pos(4);
        posAux = pos(1);
    end
    desvEnerg = orbitTemp(5,ind);
    
    %Organiza os dados para enviar como retorno da função BBAscan
    BBAresult = [];
    BBAresult.kickMin = kickMin;
    BBAresult.functionMin = functionMin;
    BBAresult.centerBPMMin = centerBPMMin;
    BBAresult.centerQuadruMin = centerQuadruMin;
    BBAresult.centerQuadruPosPerp = posAux;
    BBAresult.angQuadru = angQuadru;
    if(dir == 'x')
        pos = findFinal(ringTemp,orbitTemp,ind);
        BBAresult.posQuadruFinal = pos(1);
        BBAresult.angQuadruFinal = pos(2);
        BBAresult.posQuadruInicio = orbitTemp(1,ind);
        BBAresult.angQuadruInicio = orbitTemp(2,ind);
    end
    if(dir == 'y')
        pos = findFinal(ringTemp,orbitTemp,ind);
        BBAresult.posQuadruFinal = pos(3);
        BBAresult.angQuadruFinal = pos(4);
        BBAresult.posQuadruInicio = orbitTemp(3,ind);
        BBAresult.angQuadruInicio = orbitTemp(4,ind);
    end
    BBAresult.desvEnerg = desvEnerg;
    BBAresult.kicks = kicks;
    BBAresult.meritfunction = meritfunction;
end

