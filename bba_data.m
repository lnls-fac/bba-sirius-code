caminho_arquivos = '../bba-sirius-data/';
folder = 'sext';
%1) 'plusK' é o BBA normal com o Kscan junto e ajustando o DeltaK
%2) 'plusKt' é o BBA normal com o Kscan junto mas sem ajustar o DeltaK
%3) selecionar a pasta 'sext' automaticamente muda o algoritmo para
% usar a força de sextupolos onde for possível e ajustando o DeltaK
%3) 'sextt' é o sextupolo sem ajustar o DeltaK
%3) 'sextder' é o sextupolo mas partido de força zero no sextupolo para dar
%delta

range = 12; % quantidade de valores nas corretoras
random_error = true; % define se colocaremos erros aleatórios nos BPM's ou não
interp_num = 1000000; % numero de pontos calculados na imperpolação

%totalBPM = length(list_bpm);
totalBPM = length(list_bpm);

for m=0:1 %for m=0:length(machine)
    for recursao=0:1
        for i=1:totalBPM
            t0 = datenum(datetime('now'));
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
            kicksMax = [selectMaxKick(twi,quadru,corrs(1),'x')/10 selectMaxKick(twi,quadru,corrs(2),'y')/10];
            %DeltaK depende se é no termo de quadrupolo ou de sextupolo
            %DeltaK também depende de qual a função de mérito do BBA
            if strcmp(folder,'sext') || strcmp(folder,'sextt') || strcmp(folder,'sextder') 
                DeltaKaux = [selectDeltaK_sext(the_ring,family_data,twi,quadru,'x',is_sextupole) selectDeltaK_sext(the_ring,family_data,twi,quadru,'y',is_sextupole)];
            else
                DeltaKaux = [selectDeltaK(the_ring,family_data,twi,quadru,'x',is_skew) selectDeltaK(the_ring,family_data,twi,quadru,'y',is_skew)];
            end
            %OBS: Tudo isso pode ser calculado só uma vez e criar uma
            %tabela posteriormente, sendo necessário apenas ler a tabela e
            %não ficar repetindo as contas
            DeltaK = [DeltaKaux(1)*DeltaKaux(2)/(DeltaKaux(1) + DeltaKaux(2)) DeltaKaux(1)*DeltaKaux(2)/(DeltaKaux(1) + DeltaKaux(2))];
            %OBS: para a função de mérito que soma x^2 e y^2, DeltaK é a
            %média harmônica dos dois DeltaK calculados anteriormente

            %Verifica se o DeltaK escolhido não ultrapassa os limites da
            % especificação
            if strcmp(folder,'sext') || strcmp(folder,'sextt') || strcmp(folder,'sextder') 
                DeltaKlimX = getDeltaKlimit_sext(DeltaK(1), is_skew, is_sextupole, ring, quadru);
                DeltaKlimY = getDeltaKlimit_sext(DeltaK(2), is_skew, is_sextupole, ring, quadru);
                DeltaKlim = [DeltaKlimX DeltaKlimY];
            else
                DeltaKlimX = getDeltaKlimit(DeltaK(1), is_skew, ring, quadru);
                DeltaKlimY = getDeltaKlimit(DeltaK(2), is_skew, ring, quadru);
                DeltaKlim = [DeltaKlimX DeltaKlimY];
            end
            if strcmp(folder,'plusKt') || strcmp(folder,'sextt')
                DeltaKlim = DeltaK; %desfaz a conta do DeltaK limite
            end

            if(recursao == 0)
                if strcmp(folder,'sext') || strcmp(folder,'sextt') 
                	BBAresultX = BBAscan_sext(ring,family_data,quadru,bpm,corrs(1),'x',is_skew,kicksMax(1),range,DeltaKlim(1),random_error,is_sextupole);
                    BBAresultXtune = BBAresultX;
                    BBAresultY = BBAscan_sext(ring,family_data,quadru,bpm,corrs(2),'y',is_skew,kicksMax(2),range,DeltaKlim(2),random_error,is_sextupole);
                    BBAresultYtune = BBAresultY;
                elseif strcmp(folder,'sextder')
                    BBAresultX = BBAscan_sextder(ring,family_data,quadru,bpm,corrs(1),'x',is_skew,kicksMax(1),range,DeltaKlim(1),random_error,is_sextupole);
                    BBAresultXtune = BBAresultX;
                    BBAresultY = BBAscan_sextder(ring,family_data,quadru,bpm,corrs(2),'y',is_skew,kicksMax(2),range,DeltaKlim(2),random_error,is_sextupole);
                    BBAresultYtune = BBAresultY;
                else
                    BBAresultX = BBAscan(ring,family_data,quadru,bpm,corrs(1),'x',is_skew,kicksMax(1),range,DeltaKlim(1),random_error);
                    BBAresultXtune = BBAresultX;
                    BBAresultY = BBAscan(ring,family_data,quadru,bpm,corrs(2),'y',is_skew,kicksMax(2),range,DeltaKlim(2),random_error);
                    BBAresultYtune = BBAresultY;
                end
            else
                string = [caminho_arquivos folder '/' 'M' num2str(m) '_' num2str(recursao-1) 'r' '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' num2str(interp_num) '_' 'data.mat'];
                load(string);
                ring = data.ring;
                kicks = data.BBAresultX.kicks;
                meritfunction = data.BBAresultX.meritfunction;
                vkicks = min(kicks):(max(kicks)-min(kicks))/interp_num:max(kicks);
                interp = interp1(kicks,meritfunction,vkicks,'spline');
                [M,I] = min(interp);
                kickMin = vkicks(I);
                tune1 = data.BBAresultXtune.deltaTune1;
                tune2 = data.BBAresultXtune.deltaTune2;
                desvTune = tune1.*tune1 + tune2.*tune2;
                interpTune = interp1(kicks,desvTune,vkicks,'spline');
                [Mt,It] = min(interpTune);
                kickMinTune = vkicks(It);
                ring = lnls_set_kickangle(ring, lnls_get_kickangle(ring,corrs(1),'x') + kickMin, corrs(1), 'x');
                ringTune = lnls_set_kickangle(ring, lnls_get_kickangle(ring,corrs(1),'x') + kickMinTune, corrs(1), 'x');
                if strcmp(folder,'sext') || strcmp(folder,'sextt')
                    BBAresultY = BBAscan_sext(ring,family_data,quadru,bpm,corrs(2),'y',is_skew,kicksMax(2),range,DeltaKlim(2),random_error,is_sextupole);
                    BBAresultYtune = BBAscan_sext(ringTune,family_data,quadru,bpm,corrs(2),'y',is_skew,kicksMax(2),range,DeltaKlim(2),random_error,is_sextupole);
                elseif strcmp(folder,'sextder')
                    BBAresultY = BBAscan_sextder(ring,family_data,quadru,bpm,corrs(2),'y',is_skew,kicksMax(2),range,DeltaKlim(2),random_error,is_sextupole);
                    BBAresultYtune = BBAscan_sextder(ringTune,family_data,quadru,bpm,corrs(2),'y',is_skew,kicksMax(2),range,DeltaKlim(2),random_error,is_sextupole);
                else
                    BBAresultY = BBAscan(ring,family_data,quadru,bpm,corrs(2),'y',is_skew,kicksMax(2),range,DeltaKlim(2),random_error);
                    BBAresultYtune = BBAscan(ringTune,family_data,quadru,bpm,corrs(2),'y',is_skew,kicksMax(2),range,DeltaKlim(2),random_error);
                end
                kicks = BBAresultY.kicks;
                meritfunction = BBAresultY.meritfunction;
                vkicks = min(kicks):(max(kicks)-min(kicks))/interp_num:max(kicks);
                interp = interp1(kicks,meritfunction,vkicks,'spline');
                [M,I] = min(interp);
                kickMin = vkicks(I);
                tune1 = data.BBAresultYtune.deltaTune1;
                tune2 = data.BBAresultYtune.deltaTune2;
                desvTune = tune1.*tune1 + tune2.*tune2;
                interpTune = interp1(kicks,desvTune,vkicks,'spline');
                [Mt,It] = min(interpTune);
                kickMinTune = vkicks(It);
                ring = lnls_set_kickangle(ring, lnls_get_kickangle(ring,corrs(2),'y') + kickMin, corrs(2), 'y');
                ringTune = lnls_set_kickangle(ring, lnls_get_kickangle(ring,corrs(2),'y') + kickMinTune, corrs(2), 'y');
                if strcmp(folder,'sext') || strcmp(folder,'sextt')
                    BBAresultX = BBAscan_sext(ring,family_data,quadru,bpm,corrs(1),'x',is_skew,kicksMax(1),range,DeltaKlim(1),random_error,is_sextupole);
                    BBAresultXtune = BBAscan_sext(ringTune,family_data,quadru,bpm,corrs(1),'x',is_skew,kicksMax(1),range,DeltaKlim(1),random_error,is_sextupole);
                elseif strcmp(folder,'sextder')
                    BBAresultX = BBAscan_sextder(ring,family_data,quadru,bpm,corrs(1),'x',is_skew,kicksMax(1),range,DeltaKlim(1),random_error,is_sextupole);
                    BBAresultXtune = BBAscan_sextder(ringTune,family_data,quadru,bpm,corrs(1),'x',is_skew,kicksMax(1),range,DeltaKlim(1),random_error,is_sextupole);
                else
                    BBAresultX = BBAscan(ring,family_data,quadru,bpm,corrs(1),'x',is_skew,kicksMax(1),range,DeltaKlim(1),random_error);
                    BBAresultXtune = BBAscan(ringTune,family_data,quadru,bpm,corrs(1),'x',is_skew,kicksMax(1),range,DeltaKlim(1),random_error);
                end
            end
            
            if strcmp(folder,'plusK') || strcmp(folder,'plusKt')
                if(recursao == 0)
                    ringAux = ring;
                else
                    kicks = BBAresultX.kicks;
                    meritfunction = BBAresultX.meritfunction;
                    vkicks = min(kicks):(max(kicks)-min(kicks))/interp_num:max(kicks);
                    interp = interp1(kicks,meritfunction,vkicks,'spline');
                    [M,I] = min(interp);
                    kickMin = vkicks(I);
                    ringAux = lnls_set_kickangle(ring, lnls_get_kickangle(ring,corrs(1),'x') + kickMin, corrs(1), 'x');
                end
                Kresult = Kscan(ringAux,family_data,quadru,bpm,is_skew,range,DeltaKlim(1),random_error);
            else
                Kresult = [];
            end

            data = [];
            %dados de "rótulo" do bpm e quadrupolo
            data.bpm = bpm;
            data.quadru = quadru;
            data.is_skew = is_skew;
            data.is_sextupole = is_sextupole;
            %dados que podem sem tabelados (são calculados idealmente)
            data.corrs = corrs;
            data.kicksMax = kicksMax;
            data.DeltaK = DeltaK;
            data.DeltaKlim = DeltaKlim;
            %grava dos parâmetros dos dados simulados
            data.recursao = recursao;
            data.range = range;
            data.random_error = random_error;
            data.interp_num = interp_num;
            data.ring = ring;
            %dados o BBAresult
            data.BBAresultX = BBAresultX;
            data.BBAresultY = BBAresultY;
            data.BBAresultXtune = BBAresultXtune;
            data.BBAresultYtune = BBAresultYtune;
            %dados do Kresult
            data.Kresult = Kresult;
            
            string = [caminho_arquivos folder '/' 'M' num2str(m) '_' num2str(recursao) 'r' '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' num2str(interp_num) '_' 'data.mat'];
            save(string,'data');
            tf = datenum(datetime('now'));
            
            fprintf('Índice do BPM: %d\n', bpm);
            fprintf('Índice do Quadrupolo mais perto: %d\n', quadru);
            %fprintf('Índice da Corretora Horizontal: %d\n', corrs(1));
            %fprintf('Índice da Corretora Vertical: %d\n', corrs(2));
            fprintf('É Skew: %d\n', is_skew);
            fprintf('É Sextupolo: %d\n', is_sextupole);
            %fprintf('Kicks: %d %d\n', kicksMax(1), kicksMax(2));
            %fprintf('DeltaK: %d %d\n', DeltaK(1), DeltaK(2));
            fprintf('CENTRO DO QUADRUPOLO: (%d , %d)\n', ring{quadru}.T2(1), ring{quadru}.T2(3));
            fprintf('Tempo de Execução (s): %.2f\n', (tf-t0)*100000);
            fprintf('--------------------\n');
        end
    end

end
