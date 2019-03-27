caminho_arquivos = '/home/alexandre/BBAmatlabMestrado/';
folder = 'sext';

range = 10; % quantidade de valores nas corretoras
random_error = false; % define se colocaremos erros aleatórios nos BPM's ou não

for m=0:1 %for m=0:length(machine)
    for recursao=0:1
        for i=1:length(list_bpm) %for i=1:length(list_bpm)
            
            %escolhe o anel e liga a cavidade de RF e a emissão de radiação
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
            
            %encontra as melhores corretoras para o BBA, o kick máximo
            %delas e o DeltaK ideal para o quadrupolo
            corrs = [findBestCorr(family_data,twi,quadru,'x') findBestCorr(family_data,twi,quadru,'y')];
            kicksMax = [selectMaxKick(twi,quadru,corrs(1),'x') selectMaxKick(twi,quadru,corrs(2),'y')];
            %DeltaK depende se é no termo de quadrupolo ou de sextupolo
            %DeltaK também depende de qual a função de mérito do BBA
            DeltaKaux = [selectDeltaK_sext(the_ring,family_data,twi,quadru,'x',is_sextupole) selectDeltaK_sext(the_ring,family_data,twi,quadru,'y',is_sextupole)];
            %OBS: Tudo isso pode ser calculado só uma vez e criar uma
            %tabela posteriormente, sendo necessário apenas ler a tabela e
            %não ficar repetindo as contas
            
            DeltaK = [DeltaKaux(1)*DeltaKaux(2)/(DeltaKaux(1) + DeltaKaux(2)) DeltaKaux(1)*DeltaKaux(2)/(DeltaKaux(1) + DeltaKaux(2))];
            %OBS: para a função de mérito que soma x^2 e y^2, DeltaK é a
            %média harmônica dos dois DeltaK calculados anteriormente

            if(recursao == 0)
                BBAresultX = BBAscan_sext(ring,family_data,quadru,bpm,corrs(1),'x',is_skew,kicksMax(1),range,DeltaK(1),random_error,is_sextupole);
                BBAresultY = BBAscan_sext(ring,family_data,quadru,bpm,corrs(2),'y',is_skew,kicksMax(2),range,DeltaK(2),random_error,is_sextupole);
            else
                string = [caminho_arquivos 'data/' folder '/' 'M' num2str(m) '_' num2str(recursao-1) 'r' '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' 'data.mat'];
                load(string);
                ring = data.ring;
                kick = data.kickMin(1);
                ring = lnls_set_kickangle(ring, lnls_get_kickangle(ring,corrs(1),'x') + kick, corrs(1), 'x');
                BBAresultY = BBAscan_sext(ring,family_data,quadru,bpm,corrs(2),'y',is_skew,kicksMax(2),range,DeltaK(2),random_error,is_sextupole);
                ring = lnls_set_kickangle(ring, lnls_get_kickangle(ring,corrs(2),'y') + BBAresultY.kickMin, corrs(2), 'y');
                BBAresultX = BBAscan_sext(ring,family_data,quadru,bpm,corrs(1),'x',is_skew,kicksMax(1),range,DeltaK(1),random_error,is_sextupole);
            end
            
            ringAux = lnls_set_kickangle(ring, lnls_get_kickangle(ring,corrs(1),'x') + BBAresultX.kickMin, corrs(1), 'x');
            Kresult = Kscan(ringAux,family_data,quadru,bpm,is_skew,range,4*DeltaK(1),random_error);
            
            %fprintf('Índice do BPM: %d\n', bpm);
            fprintf('Índice do Quadrupolo mais perto: %d\n', quadru);
            %fprintf('Índice da Corretora Horizontal: %d\n', corrs(1));
            %fprintf('Índice da Corretora Vertical: %d\n', corrs(2));
            fprintf('É Skew: %d\n', is_skew);
            fprintf('É Sextupolo: %d\n', is_sextupole);
            fprintf('Kicks: %d %d\n', kicksMax(1), kicksMax(2));
            fprintf('DeltaK: %d %d\n', DeltaK(1), DeltaK(2));
            fprintf('CENTRO DO QUADRUPOLO:\n');
            fprintf('Valor Real: (%d , %d)\n', ring{quadru}.T2(1), ring{quadru}.T2(3));
            fprintf('Leitura no Quadrupolo: (%d , %d)\n', BBAresultX.centerQuadruMin, BBAresultY.centerQuadruMin);
            fprintf('Leitura do BPM: (%d , %d)\n', BBAresultX.centerBPMMin, BBAresultY.centerBPMMin);
            fprintf('--------------------\n');

            data = [];
            data.bpm = bpm;
            data.quadru = quadru;
            data.corrs = corrs;
            data.recursao = recursao;
            %anel final após a recursao
            data.ring = ring;
            %dados o BBAresult
            data.kickMin = [BBAresultX.kickMin BBAresultY.kickMin];
            data.functionMin = [BBAresultX.functionMin BBAresultY.functionMin];
            data.centerQuadru = [BBAresultX.centerQuadruMin BBAresultY.centerQuadruMin];
            data.centerBPM = [BBAresultX.centerBPMMin BBAresultY.centerBPMMin];
            data.angQuadru = [BBAresultX.angQuadru BBAresultY.angQuadru];
            data.posQuadruFinal = [BBAresultX.posQuadruFinal BBAresultY.posQuadruFinal];
            data.angQuadruFinal = [BBAresultX.angQuadruFinal BBAresultY.angQuadruFinal];
            data.posQuadruInicio = [BBAresultX.posQuadruInicio BBAresultY.posQuadruInicio];
            data.angQuadruInicio = [BBAresultX.angQuadruInicio BBAresultY.angQuadruInicio];
            data.desvEnerg = [BBAresultX.desvEnerg BBAresultY.desvEnerg];
            data.centerQuadruPosPerp = [BBAresultX.centerQuadruPosPerp BBAresultY.centerQuadruPosPerp];
            %dados do Kresult
            data.Kresult = Kresult;
            
            string = [caminho_arquivos 'data/' folder '/' 'M' num2str(m) '_' num2str(recursao) 'r' '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' 'data.mat'];
            save(string,'data');

            kicks(1,:) = BBAresultX.kicks;
            kicks(2,:) = BBAresultY.kicks;
            meritfunction(1,:) = BBAresultX.meritfunction;
            meritfunction(2,:) = BBAresultY.meritfunction;
            
            string = [caminho_arquivos 'graphics/' folder '/' 'M' num2str(m) '_' num2str(recursao) 'r' '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' 'kicks.mat'];
            save(string,'kicks');
            string = [caminho_arquivos 'graphics/' folder '/' 'M' num2str(m) '_' num2str(recursao) 'r' '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' 'meritfunction.mat'];
            save(string,'meritfunction');
        end

    end

end
