function DeltaK = selectDeltaK(ring,family_data,twi,ind,dir,is_skew)
    pot = 1e6;
    
    %seleção das variáveis dinâmicas
    if(dir == 'x')
        beta = twi.betax;
        phase = twi.mux;
        tune = (phase(length(phase))-phase(1))/(2*pi);
    end
    if(dir == 'y')
        beta = twi.betay;
        phase = twi.muy;
        tune = (phase(length(phase))-phase(1))/(2*pi);
    end
    
    %seleção da força que será usada (se é sextupolo em vez de quadrupolo
    %será diferente essa parte
    if(is_skew)
        K = ring{ind}.PolynomA(2);
    else
        K = ring{ind}.PolynomB(2);
    end
    %Cálculo do Kick limite para a força escolhida
    L = ring{ind}.Length;
    ang_kick_nominal = K*L*1000/pot;
    %OBS: dipolo: G*ds , quadrupolo: K*x*ds ou K*y*ds, 
    %sextupolo: M*x*x*ds ou M*y*y*ds ou M*x*y*ds
    %Usamos como topo de x e y o desvio máximo definido nas corretoras
    %Usamos como topo de ds integrado o comprimento do quadrupolo
    ang_kick = L*1000/pot; %Variável faltando o termo de força que vamos determinar para DeltaK
    
    %Cálculo da variância das variáveis dinâmicas da direção escolhida
    ATIndex = family_data.BPM.ATIndex;
    var = 0;
    for i = 1:length(ATIndex)
        n = ATIndex(i);
        var = var + sqrt(beta(n))*sqrt(beta(n))*cos(abs(phase(ind) - phase(n)) - pi*tune)*cos(abs(phase(ind) - phase(n)) - pi*tune);
    end
    var = var/length(ATIndex);
    cte = abs(sqrt(beta(ind))*sqrt(var)/(2*sin(pi*tune)));
    
    DeltaK = (50/pot)/(ang_kick*cte); % Definimos DeltaK para termos um desvio médio de
    %50um em cada BPM do anel
end

