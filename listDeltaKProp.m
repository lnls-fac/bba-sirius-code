%Investiga se existem quadrupolos e Skews com força maior que
%o especificado na wiki-sirius
m = 2;

for i=1:length(list_bpm) %for i=1:length(list_bpm)
    if(m==0)
        ring = the_ring;
    else
        ring = machine{m};
    end
    ring = setcavity('on',ring);
    ring = setradiation('on',ring);
            
    bpm = list_bpm(i); %pega um bpm da lista de BPMs para fazer BBA
    quadru = list_quadru(i); %pega o quadrupolo mais próximo deste BPM na lista
            
            %verifica se é skew e se tem sextupolo
    is_skew = isSkew(family_data,quadru);
    is_sextupole = isSextupole(family_data,quadru);
            
    DeltaKaux = [selectDeltaK(the_ring,family_data,twi,quadru,'x',is_skew) selectDeltaK(the_ring,family_data,twi,quadru,'y',is_skew)];
    DeltaK = [DeltaKaux(1)*DeltaKaux(2)/(DeltaKaux(1) + DeltaKaux(2)) DeltaKaux(1)*DeltaKaux(2)/(DeltaKaux(1) + DeltaKaux(2))];
            
    if(is_skew)
        K = abs(ring{quadru}.PolynomA(2));
        Kmax = 0.0667;
    else
        K = abs(ring{quadru}.PolynomB(2));
        Kmax = 4;
    end
    
    if((K+DeltaK(1))*100/Kmax >= 100)
        fprintf('Índice do BPM: %d\n', bpm);
        fprintf('Índice do Quadrupolo mais perto: %d\n', quadru);
        fprintf('É Skew: %d\n', is_skew);
        fprintf('É Sextupolo: %d\n', is_sextupole);
        fprintf('DeltaK: %d %d\n', DeltaK(1), DeltaK(2));
        fprintf('DeltaK Prop: %.2f %.2f\n', DeltaK(1)*100/K, DeltaK(2)*100/K);
        fprintf('DeltaK Prop Max: %.2f %.2f\n', DeltaK(1)*100/Kmax, DeltaK(2)*100/Kmax);
        fprintf('K lim Prop Max: %.2f %.2f\n', (K+DeltaK(1))*100/Kmax, (K+DeltaK(2))*100/Kmax);
        fprintf('--------------------\n');
    end
end
