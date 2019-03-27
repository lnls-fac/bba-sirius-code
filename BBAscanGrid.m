%Faz o BBA e retorna o valor do Kick para a menor distorçao de orbita
function BBAresult = BBAscanGrid(ring,family_data,ind,bpm,corrx,corry,is_skew,kickMaxX,kickMaxY,range,DeltaK,random_error)
    %Inicializa as variáveis
    step_kickX = kickMaxX/range;
    step_kickY = kickMaxY/range;
    ringDelta = setRingDelta(ring,ind,DeltaK,is_skew);
    points = [];
    posQuadru = [];
    posBPM = [];
    errorRandomMax = 100/(10^9); %100nm é o erro aleatório esperado dos BPM's
    
    %faz a varredura na corretora e realiza o BBA
    for n = -range:range
        for m = -range:range
            ringTemp = lnls_set_kickangle(ring, lnls_get_kickangle(ring,corrx,'x') + n*step_kickX, corrx, 'x');
            ringTemp = lnls_set_kickangle(ringTemp, lnls_get_kickangle(ringTemp,corry,'y') + m*step_kickY, corry, 'y');
            ringDeltaTemp = lnls_set_kickangle(ringDelta, lnls_get_kickangle(ringDelta,corrx,'x') + n*step_kickX, corrx, 'x');
            ringDeltaTemp = lnls_set_kickangle(ringDeltaTemp, lnls_get_kickangle(ringDeltaTemp,corry,'y') + m*step_kickY, corry, 'y');
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
            points = [points; [n*step_kickX, m*step_kickY, f]];
            %Obtém variáveis internas da simulação para analisar o BBA
            %E a medida do BPM próximo ao Quadrupolo
            orbitTemp = findorbit6(ringTemp,1:length(ringTemp));
            pos = findCenter(ringTemp,orbitTemp,ind);
            posQuadru = [posQuadru, pos];
            pos = findCenter(ringTemp,orbitTemp,bpm);
            posBPM = [posBPM, pos];
        end
    end
    
    %figure; plot3(points(:,1),points(:,2),points(:,3),'.');
    
    %Organiza os dados para enviar como retorno da função BBAscan
    BBAresult = [];
    BBAresult.points = points;
    BBAresult.posQuadru = posQuadru;
    BBAresult.posBPM = posBPM;
end

