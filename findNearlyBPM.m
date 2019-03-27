%Encontra o indice do BPM no anel mais proximo do elemento ind
function bpm = findNearlyBPM(ring,family_data,ind)
    ind_spos = findspos(ring,ind);
    bpm_spos = findspos(ring,family_data.BPM.ATIndex);
    dist = [];
    for i = 1:length(bpm_spos)
        dist = [dist; abs(bpm_spos(i) - ind_spos)];
    end
    [M,I] = min(dist);
    bpm = family_data.BPM.ATIndex(I);
end 

