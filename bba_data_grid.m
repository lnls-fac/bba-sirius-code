caminho_arquivos = '../bba-sirius-data/';
folder = 'grid';

range = 10; % quantidade de valores nas corretoras
random_error = false; % define se colocaremos erros aleatórios nos BPM's ou não

for m=1:1 %for m=0:length(machine)
    for recursao=0:0
        for i=1:1 %for i=1:length(list_bpm)
            
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
            DeltaKaux = [selectDeltaK(the_ring,family_data,twi,quadru,'x',is_skew) selectDeltaK(the_ring,family_data,twi,quadru,'y',is_skew)];
            %OBS: Tudo isso pode ser calculado só uma vez e criar uma
            %tabela posteriormente, sendo necessário apenas ler a tabela e
            %não ficar repetindo as contas
            
            DeltaK = [DeltaKaux(1)*DeltaKaux(2)/(DeltaKaux(1) + DeltaKaux(2)) DeltaKaux(1)*DeltaKaux(2)/(DeltaKaux(1) + DeltaKaux(2))];
            %OBS: para a função de mérito que soma x^2 e y^2, DeltaK é a
            %média harmônica dos dois DeltaK calculados anteriormente

            BBAresult = BBAscanGrid(ring,family_data,quadru,bpm,corrs(1),corrs(2),is_skew,kicksMax(1),kicksMax(2),range,DeltaK(1),random_error);
            
            %plot3(BBAresult(:,1),BBAresult(:,2),BBAresult(:,3),'.');
            points = BBAresult.points;
            kickx = zeros(2*range+1,2*range+1);
            kicky = zeros(2*range+1,2*range+1);
            func = zeros(2*range+1,2*range+1);
            for j = 1:2*range+1
                for k = 1:2*range+1
                    kickx(k,j) = points((j-1)*(2*range + 1) + k,1);
                    kicky(k,j) = points((j-1)*(2*range + 1) + k,2);
                    func(k,j) = points((j-1)*(2*range + 1) + k,3);
                end
            end
            
            posQuadru = BBAresult.posQuadru;
            xQuadru = zeros(2*range+1,2*range+1);
            yQuadru = zeros(2*range+1,2*range+1);
            for j = 1:2*range+1
                for k = 1:2*range+1
                    xQuadru(k,j) = posQuadru(1,(j-1)*(2*range + 1) + k);
                    yQuadru(k,j) = posQuadru(3,(j-1)*(2*range + 1) + k);
                end
            end
            
            posBPM = BBAresult.posBPM;
            xBPM = zeros(2*range+1,2*range+1);
            yBPM = zeros(2*range+1,2*range+1);
            for j = 1:2*range+1
                for k = 1:2*range+1
                    xBPM(k,j) = posBPM(1,(j-1)*(2*range + 1) + k);
                    yBPM(k,j) = posBPM(3,(j-1)*(2*range + 1) + k);
                end
            end

            data = [];
            data.bpm = bpm;
            data.quadru = quadru;
            data.corrs = corrs;
            data.kicksMax = kicksMax;
            data.DeltaK = DeltaK;
            data.points = BBAresult.points;
            data.kickx = kickx;
            data.kicky = kicky;
            data.func = func;
            data.posQuadru = BBAresult.posQuadru;
            data.posBPM = BBAresult.posBPM;
            data.xQuadru = xQuadru;
            data.yQuadru = yQuadru;
            data.xBPM = xBPM;
            data.yBPM = yBPM;
            
            string = [caminho_arquivos folder '/' 'M' num2str(m) '_' num2str(recursao) 'r' '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' 'data.mat'];
            save(string,'data');
        end

    end

end