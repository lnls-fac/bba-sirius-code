caminho_arquivos = '../bba-sirius-data/';
folder = 'plusK';

range = 10; % quantidade de valores nas corretoras
random_error = false; % define se colocaremos erros aleatórios nos BPM's ou não
interp_num = 1000000; % quantidade de pontos da interpolação

for m=0:0 %for m=0:length(machine)
    for recursao=0:1
        %escolhe o anel e liga a cavidade de RF e a emissão de radiação
        if(m==0)
            ring = the_ring;
        else
            ring = machine{m};
        end
        for i=1:length(list_bpm)
            t0 = datenum(datetime('now'));
            
            bpm = list_bpm(i); %pega um bpm da lista de BPMs para fazer BBA
            quadru = list_quadru(i); %pega o quadrupolo mais próximo deste BPM na lista
            
            %verifica se é skew e se tem sextupolo
            is_skew = isSkew(family_data,quadru);
            is_sextupole = isSextupole(family_data,quadru);
            
            string = [caminho_arquivos folder '/' 'M' num2str(m) '_' num2str(recursao) 'r' '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' num2str(interp_num) '_' 'data.mat'];
            load(string);
            
            meritfunctionKx = [];
            meritfunctionKy = [];
            for j=1:length(data.Kresult.meritfunctionKx)
                meritfunctionKx = [meritfunctionKx; data.Kresult.meritfunctionKx(j)];
                meritfunctionKy = [meritfunctionKy; data.Kresult.meritfunctionKy(j)];
            end
            data.Kresult.meritfunctionKx = meritfunctionKx;
            data.Kresult.meritfunctionKy = meritfunctionKy;
            
            string = [caminho_arquivos folder '/' 'M' num2str(m) '_' num2str(recursao) 'r' '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' num2str(interp_num) '_' 'data.mat'];
            save(string,'data');
            
            tf = datenum(datetime('now'));
            fprintf('Tempo de Execução (s): %.2f\n', (tf-t0)*100000);
        end
    end
end