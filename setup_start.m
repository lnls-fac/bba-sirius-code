clear;
version = 'SI.V24.01';
version_min = 'si.v24.01';
online_flag = true;

caminho_fac_files1 = '/home/alexandre/BBAmatlabMestrado/fac_files/data/sirius/beam_dynamics/';
caminho_fac_files2 = '/official/s05.01/multi.cod.tune.coup.symm/cod_matlab/';

load([caminho_fac_files1 version_min caminho_fac_files2 'CONFIG_machines_cod_corrected_tune_coup_symm_multi.mat']);
load([caminho_fac_files1 version_min caminho_fac_files2 'CONFIG_the_ring.mat']);

%Carrega e configura o anel
if online_flag
    sirius(version);
end

caminho_varsRing = '/home/alexandre/BBAmatlabMestrado/varsRing/';

if exist('version','var')
    load([caminho_varsRing version '_family_data.mat']);
    load([caminho_varsRing version '_alist_bpm.mat']);
    load([caminho_varsRing version '_alist_quadru.mat']);
    load([caminho_varsRing version '_twi.mat']);
    list_bpm = alist_bpm;
    list_quadru = alist_quadru;
end