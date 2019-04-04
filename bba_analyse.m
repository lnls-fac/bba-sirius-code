caminho_arquivos = '../bba-sirius-data/';
folder = 'plusK';

range = 10; % quantidade de valores nas corretoras
random_error = false; % define se colocaremos erros aleatórios nos BPM's ou não
interp_num = 1000000; % quantidade de pontos da interpolação

for m=1:1 %for m=0:length(machine)
    for recursao=0:1
        for i=1:length(list_bpm)
            t0 = datenum(datetime('now'));
            %escolhe o anel e liga a cavidade de RF e a emissão de radiação
            if(m==0)
                ring = the_ring;
            else
                ring = machine{m};
            end
            
            bpm = list_bpm(i); %pega um bpm da lista de BPMs para fazer BBA
            quadru = list_quadru(i); %pega o quadrupolo mais próximo deste BPM na lista
            
            %verifica se é skew e se tem sextupolo
            is_skew = isSkew(family_data,quadru);
            is_sextupole = isSextupole(family_data,quadru);
            
            string = [caminho_arquivos folder '/' 'M' num2str(m) '_' num2str(recursao) 'r' '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' num2str(interp_num) '_' 'data.mat'];
            load(string);

            %-----Análise do BBA na direção X-----
            
            BBAresult = data.BBAresultX;
            
            kicks = BBAresult.kicks;
            meritfunction = BBAresult.meritfunction;
            posQuadru = BBAresult.posQuadru;
            posBPM = BBAresult.posBPM;
            posQuadruFinal = BBAresult.posQuadruFinal;
            
            %Obtém os valores que minimizam a função de mérito
            %Utilizando Interpolação Spline
            %OBS: Regressão linear assumindo uma parábola não funcionou muito bem
            vkicks = min(kicks):(max(kicks)-min(kicks))/interp_num:max(kicks);
            interp = interp1(kicks,meritfunction,vkicks,'spline');
            [M,I] = min(interp);
            kickMin = vkicks(I);
            functionMin = M;
            
            posQuadruMin = [];
            for i=1:6
                var = posQuadru(i,:);
                vVar = min(var):(max(var)-min(var))/interp_num:max(var);
                interp = interp1(var,meritfunction,vVar,'spline');
                [M,I] = min(interp);
                posQuadruMin = [posQuadruMin; vVar(I)];
            end
            
            posBPMMin = [];
            for i=1:6
                var = posBPM(i,:);
                vVar = min(var):(max(var)-min(var))/interp_num:max(var);
                interp = interp1(var,meritfunction,vVar,'spline');
                [M,I] = min(interp);
                posBPMMin = [posBPMMin; vVar(I)];
            end
            
            posQuadruFinalMin = [];
            for i=1:6
                var = posQuadruFinal(i,:);
                vVar = min(var):(max(var)-min(var))/interp_num:max(var);
                interp = interp1(var,meritfunction,vVar,'spline');
                [M,I] = min(interp);
                posQuadruFinalMin = [posQuadruFinalMin; vVar(I)];
            end
            
            BBAanalyse = [];
            BBAanalyse.interp_num = interp_num;
            BBAanalyse.kickMin = kickMin;
            BBAanalyse.functionMin = functionMin;
            BBAanalyse.posQuadruMin = posQuadruMin;
            BBAanalyse.posBPMMin = posBPMMin;
            BBAanalyse.posQuadruFinalMin = posQuadruFinalMin;
            
            BBAanalyseX = BBAanalyse;
            
            %-----Análise do BBA na direção Y-----
            
            BBAresult = data.BBAresultY;
            
            kicks = BBAresult.kicks;
            meritfunction = BBAresult.meritfunction;
            posQuadru = BBAresult.posQuadru;
            posBPM = BBAresult.posBPM;
            posQuadruFinal = BBAresult.posQuadruFinal;
            
            %Obtém os valores que minimizam a função de mérito
            %Utilizando Interpolação Spline
            %OBS: Regressão linear assumindo uma parábola não funcionou muito bem
            vkicks = min(kicks):(max(kicks)-min(kicks))/interp_num:max(kicks);
            interp = interp1(kicks,meritfunction,vkicks,'spline');
            [M,I] = min(interp);
            kickMin = vkicks(I);
            functionMin = M;
            
            posQuadruMin = [];
            for i=1:6
                var = posQuadru(i,:);
                vVar = min(var):(max(var)-min(var))/interp_num:max(var);
                interp = interp1(var,meritfunction,vVar,'spline');
                [M,I] = min(interp);
                posQuadruMin = [posQuadruMin; vVar(I)];
            end
            
            posBPMMin = [];
            for i=1:6
                var = posBPM(i,:);
                vVar = min(var):(max(var)-min(var))/interp_num:max(var);
                interp = interp1(var,meritfunction,vVar,'spline');
                [M,I] = min(interp);
                posBPMMin = [posBPMMin; vVar(I)];
            end
            
            posQuadruFinalMin = [];
            for i=1:6
                var = posQuadruFinal(i,:);
                vVar = min(var):(max(var)-min(var))/interp_num:max(var);
                interp = interp1(var,meritfunction,vVar,'spline');
                [M,I] = min(interp);
                posQuadruFinalMin = [posQuadruFinalMin; vVar(I)];
            end
            
            BBAanalyse = [];
            BBAanalyse.interp_num = interp_num;
            BBAanalyse.kickMin = kickMin;
            BBAanalyse.functionMin = functionMin;
            BBAanalyse.posQuadruMin = posQuadruMin;
            BBAanalyse.posBPMMin = posBPMMin;
            BBAanalyse.posQuadruFinalMin = posQuadruFinalMin;
            
            BBAanalyseY = BBAanalyse;
            
            %----Salvando Dados da Análise---
            
            data.BBAanalyseX = BBAanalyseX;
            data.BBAanalyseY = BBAanalyseY;
            
            string = [caminho_arquivos folder '/' 'M' num2str(m) '_' num2str(recursao) 'r' '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' num2str(interp_num) '_' 'data.mat'];
            save(string,'data');
            tf = datenum(datetime('now'));
            
            fprintf('Índice do BPM: %d\n', bpm);
            fprintf('Índice do Quadrupolo mais perto: %d\n', quadru);
            fprintf('É Skew: %d\n', is_skew);
            fprintf('É Sextupolo: %d\n', is_sextupole);
            fprintf('ERRO BBA: (%d , %d)\n', abs(BBAanalyseX.posBPMMin(1) - ring{quadru}.T2(1)), abs(BBAanalyseX.posBPMMin(3) - ring{quadru}.T2(3)));
            fprintf('Tempo de Execução (s): %.2f\n', (tf-t0)*100000);
            fprintf('--------------------\n');
        end
    end

end
