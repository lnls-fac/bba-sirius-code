%Encontra a melhor corretora para fazer o BBA em cada direcao
function kickMax = selectMaxKick(twi,ind,corr,dir)
    pot = 1e6; 
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
    cte = abs(sqrt(beta(ind))*sqrt(beta(corr))*cos(abs(phase(ind) - phase(corr)) - pi*tune)/(2*sin(pi*tune)));
    kickMax = 1000/cte; %em urad (esperando desvio maximo de 1000um)
    kickMax = kickMax/pot;
end
%O kick é dado em radianos (no Sands, é o valor de G*ds)

%O kick Máximo das corretoras é calculado assumindo que queremos 
%uma distorção radial da ordem de 1000um, que seria suficiente para
%passarmos no centro do quadrupolo

