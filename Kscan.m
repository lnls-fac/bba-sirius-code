%Faz o BBA e retorna o valor do Kick para a menor distorçao de orbita
function Kresult = Kscan(ring,family_data,ind,bpm,is_skew,range,DeltaK,random_error)
    %Inicializa as variáveis
    step_K = DeltaK/range;
    Ks = [];
    meritfunctionKx = [];
    meritfunctionKy = [];
    centerQuadrux = [];
    centerQuadruy = [];
    centerBPMx = [];
    centerBPMy = [];
    inclQuadrux = [];
    inclQuadruy = [];
    inclBPMx = [];
    inclBPMy = [];
    errorRandomMax = 100/(10^9); %100nm é o erro aleatório esperado dos BPM's
    orbitMain = findorbit6(ring,1:length(ring));
    
    %faz a varredura na corretora e realiza o BBA
    for n = -range:range
        ringTemp = setRingDelta(ring,ind,n*step_K,is_skew);
        Ks = [Ks; n*step_K];
        orbitTemp = findorbit6(ringTemp,1:length(ring));
        if(random_error)
            r1 = 2*(rand()- (1/2));
            r2 = 2*(rand()- (1/2));
        else
            r1 = 0;
            r2 = 0;
        end
        dx = (orbitTemp(1,bpm) - orbitMain(1,bpm)) + errorRandomMax*r1;
        dy = (orbitTemp(3,bpm) - orbitMain(3,bpm)) + errorRandomMax*r2;
        meritfunctionKx = [meritfunctionKx, dx];
        meritfunctionKy = [meritfunctionKy, dy];
        
        %Obtém variáveis internas da simulação para analisar o Kscan
        %E a medida do BPM próximo ao Quadrupolo
        pos = findCenter(ringTemp,orbitTemp,ind);
        centerQuadrux = [centerQuadrux, pos(1)];
        inclQuadrux = [inclQuadrux, pos(2)];
        pos = findCenter(ringTemp,orbitTemp,bpm);
        centerBPMx = [centerBPMx, pos(1)];
        inclBPMx = [inclBPMx, pos(2)];
        pos = findCenter(ringTemp,orbitTemp,ind);
        centerQuadruy = [centerQuadruy, pos(3)];
        inclQuadruy = [inclQuadruy, pos(4)];
        pos = findCenter(ringTemp,orbitTemp,bpm);
        centerBPMy = [centerBPMy, pos(3)];
        inclBPMy = [inclBPMy, pos(4)];
    end
   
    %figure; plot(Ks,meritfunctionK);
    
    %Encontra a derivada quando K=0
    vKs = min(Ks):(max(Ks)-min(Ks))/1000000:max(Ks);
    interpx = interp1(Ks,meritfunctionKx,vKs,'spline');
    interpy = interp1(Ks,meritfunctionKy,vKs,'spline');
    index = (size(vKs,2)-1)/2;
    derivadaX = (interpx(index+2) - interpx(index))/(vKs(index+2) - vKs(index));
    derivadaY = (interpy(index+2) - interpy(index))/(vKs(index+2) - vKs(index));
    
    %Organiza os dados para enviar como retorno da função
    Kresult = [];
    Kresult.Ks = Ks;
    Kresult.meritfunctionKx = meritfunctionKx;
    Kresult.meritfunctionKy = meritfunctionKy;
    Kresult.derivadaX = derivadaX;
    Kresult.derivadaY = derivadaY;
    Kresult.centerQuadrux = centerQuadrux;
    Kresult.centerQuadruy = centerQuadruy;
    Kresult.inclQuadrux = inclQuadrux;
    Kresult.inclQuadruy = inclQuadruy;
    Kresult.centerBPMx = centerBPMx;
    Kresult.centerBPMy = centerBPMy;
    Kresult.inclBPMx = inclBPMx;
    Kresult.inclBPMy = inclBPMy;
    
end

