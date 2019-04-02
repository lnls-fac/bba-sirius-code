%Faz o BBA e retorna o valor do Kick para a menor distorçao de orbita
function BBAresult = BBAscan_sext(ring,family_data,ind,bpm,corr,dir,is_skew,kickMax,range,DeltaK,random_error,is_sextupole)
    %Inicializa as variáveis
    step_kick = kickMax/range;
    ringDelta = setRingDelta_sext(ring,ind,DeltaK,is_skew,is_sextupole);
    kicks = [];
    meritfunction = [];
    posQuadru = [];
    posQuadruFinal = [];
    posBPM = [];
    errorRandomMax = 100/(10^9); %100nm é o erro aleatório esperado dos BPM's
    
    %faz a varredura na corretora e realiza o BBA
    for n = -range:range
        ringTemp = lnls_set_kickangle(ring, lnls_get_kickangle(ring,corr,dir) + n*step_kick, corr, dir);
        ringDeltaTemp = lnls_set_kickangle(ringDelta, lnls_get_kickangle(ringDelta,corr,dir) + n*step_kick, corr, dir);
        kicks = [kicks; n*step_kick];
        orbitTemp = findorbit6(ringTemp,1:length(ringTemp));
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
            dx = (orbitDeltaTemp(1,i) - orbitTemp(1,family_data.BPM.ATIndex(i))) + errorRandomMax*r1;
            dy = (orbitDeltaTemp(3,i) - orbitTemp(3,family_data.BPM.ATIndex(i))) + errorRandomMax*r2;
            f = f + dx*dx + dy*dy;
        end
        f = f/length(family_data.BPM.ATIndex);
        meritfunction = [meritfunction; f];
        %Obtém variáveis internas da simulação para analisar o BBA
        %E a medida do BPM próximo ao Quadrupolo
        pos = findCenter(ringTemp,orbitTemp,ind);
        posQuadru = [posQuadru, pos];
        pos = findCenter(ringTemp,orbitTemp,bpm);
        posBPM = [posBPM, pos];
        pos = findFinal(ringTemp,orbitTemp,ind);
        posQuadruFinal = [posQuadruFinal, pos];
    end
    
    %figure; plot(kicks,sqrt(meritfunction));
    
    BBAresult = [];
    BBAresult.kicks = kicks;
    BBAresult.meritfunction = meritfunction;
    BBAresult.posQuadru = posQuadru;
    BBAresult.posBPM = posBPM;
    BBAresult.posQuadruFinal = posQuadruFinal;
    BBAresult.BBAdir = dir;
end

