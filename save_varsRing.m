caminho_varsRing = '/home/alexandre/BBAmatlabMestrado/varsRing/';

%OBS: Agora não dá pra fazer BBA usando os BPMs:
% 2728,4675,1436,4023,5324,143,5978,2084,3376,791
%Que corresponderiam aos Quadrupolos:
% 2720,4667,1428,4015,5316,135,5970,2076,3368,783
remove_bpm = [143; 791; 1436; 2084; 2728; 3376; 4023; 4675; 5324; 5978];

if exist('the_ring','var')
    if exist('version','var')
        family_data = sirius_si_family_data(the_ring);
        twi = calctwiss(the_ring);
        list_bpm = family_data.BPM.ATIndex;
        list_bpm_aux = setdiff(list_bpm,remove_bpm);
        list_bpm = list_bpm_aux;
        list_quadru = findNearlyQuadrupole(the_ring,family_data,list_bpm);
        alist_bpm = list_bpm;
        alist_quadru = list_quadru;
        save([caminho_varsRing version '_family_data.mat'],'family_data');
        save([caminho_varsRing version '_alist_bpm.mat'],'alist_bpm');
        save([caminho_varsRing version '_alist_quadru.mat'],'alist_quadru');
        save([caminho_varsRing version '_twi.mat'],'twi');
    end
end