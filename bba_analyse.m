caminho_arquivos = '../bba-sirius-data/';
folder = 'sext2';

range = 11; % quantidade de valores nas corretoras
random_error = false; % define se colocaremos erros aleatórios nos BPM's ou não
interp_num = 1000000; % quantidade de pontos da interpolação

%totalBPM = length(list_bpm);
totalBPM = length(list_bpm);


for m=1:1 %for m=0:length(machine)
    for recursao=2:3
        %escolhe o anel e liga a cavidade de RF e a emissão de radiação
        if(m==0)
            ring = the_ring;
        else
            ring = machine{m};
        end
        for i=1:totalBPM %for i=1:totalBPM
            t0 = datenum(datetime('now'));
            
            bpm = list_bpm(i); %pega um bpm da lista de BPMs para fazer BBA
            quadru = list_quadru(i); %pega o quadrupolo mais próximo deste BPM na lista
            
            %verifica se é skew e se tem sextupolo
            is_skew = isSkew(family_data,quadru);
            is_sextupole = isSextupole(family_data,quadru);
            
            string = [caminho_arquivos folder '/' 'M' num2str(m) '_' num2str(recursao) 'r' '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' num2str(interp_num) '_' 'data.mat'];
            load(string);

            %-----Análise do BBA na direção X-----
            
            BBAresult = data.BBAresultX;
            BBAresultTune = data.BBAresultXtune;
            
            kicks = BBAresult.kicks;
            meritfunction = BBAresult.meritfunction;
            posQuadru = BBAresult.posQuadru;
            posBPM = BBAresult.posBPM;
            posQuadruFinal = BBAresult.posQuadruFinal;
            
            tune1 = BBAresultTune.deltaTune1;
            tune2 = BBAresultTune.deltaTune2;
            desvTune = tune1.*tune1 + tune2.*tune2;
            posQuadruTune = BBAresultTune.posQuadru;
            posBPMTune = BBAresultTune.posBPM;
            posQuadruFinalTune = BBAresultTune.posQuadruFinal;
            
            %Obtém os valores que minimizam a função de mérito
            %Utilizando Interpolação Spline
            %OBS: Regressão linear assumindo uma parábola não funcionou muito bem
            vkicks = min(kicks):(max(kicks)-min(kicks))/interp_num:max(kicks);
            interp = interp1(kicks,meritfunction,vkicks,'spline');
            [M,I] = min(interp);
            kickMin = vkicks(I);
            functionMin = M;
            
            interpTune = interp1(kicks,desvTune,vkicks,'spline');
            [Mt,It] = min(interpTune);
            kickMinTune = vkicks(It);
            functionMinTune = Mt;
            
            %regressão nos kicks (parece que funciona também)
            if((strcmp(folder,'sext') || strcmp(folder,'sext2')) && is_sextupole == true)
            	%p = polyfit(kicks, meritfunction, 4);
                p = fitQuartic(kicks, meritfunction, false);
            else
            	p = polyfit(kicks, meritfunction, 2);
            end
            f = polyval(p,transpose(vkicks));
            if((strcmp(folder,'sext') || strcmp(folder,'sext2')) && is_sextupole == true)
            	r = roots(polyder(p));
            	r2 = r(imag(r) == 0&real(r)<max(kicks)&real(r)>min(kicks));
            	kickMin2 = mean(r2);
            else
            	kickMin2 = -p(2)/(2*p(1));
            end
            functionMin2 = polyval(p,kickMin2);
            %{
            figure; plot(kicks, meritfunction, 'ko');
            hold on;
            plot(vkicks, f);
            plot(vkicks, interp);
            plot(kickMin2, functionMin2, '*')
            plot(kickMin, functionMin, '*')
            hold off;
            %}
            posQuadruMin2 = [];
            for j=1:6
                if (j == 1)
                    var = posQuadru(j,:);
                    if((strcmp(folder,'sext') || strcmp(folder,'sext2')) && is_sextupole == true)
                        %p = polyfit(transpose(var), meritfunction, 4);
                        p = fitQuartic(transpose(var), meritfunction, false);
                    else
                        p = polyfit(transpose(var), meritfunction, 2);
                    end
                    vVar = min(var):(max(var)-min(var))/interp_num:max(var);
                    f = polyval(p,transpose(vVar));
                    interp2 = interp1(var,meritfunction,vVar,'spline');
                    if((strcmp(folder,'sext') || strcmp(folder,'sext2')) && is_sextupole == true)
                        r = roots(polyder(p));
                        r2 = r(imag(r) == 0&real(r)<max(var)&real(r)>min(var));
                        value = mean(r2);
                        posQuadruMin2 = [posQuadruMin2; value];
                    else
                        value = -p(2)/(2*p(1));
                        posQuadruMin2 = [posQuadruMin2; value];
                    end
                    %{
                    Ma = polyval(p,value);
                    [Mb,Ib] = min(interp2);
                    figure; plot(var - ring{quadru}.T2(1), meritfunction, 'ko');
                    hold on;
                    plot(vVar - ring{quadru}.T2(1), f);
                    plot(vVar- ring{quadru}.T2(1), interp2);
                    plot(value - ring{quadru}.T2(1), Ma, '*')
                    plot(vVar(Ib)- ring{quadru}.T2(1), Mb, '*')
                    hold off;
                    %}
                else
                    posQuadruMin2 = [posQuadruMin2; 0];
                end
            end

            posBPMMin2 = [];
            for j=1:6
                if (j == 1)
                    var = posBPM(j,:);
                    if((strcmp(folder,'sext') || strcmp(folder,'sext2')) && is_sextupole == true)
                        %p = polyfit(transpose(var), meritfunction, 4);
                        p = fitQuartic(transpose(var), meritfunction, false);
                    else
                        p = polyfit(transpose(var), meritfunction, 2);
                    end
                    vVar = min(var):(max(var)-min(var))/interp_num:max(var);
                    f = polyval(p,transpose(vVar));
                    interp2 = interp1(var,meritfunction,vVar,'spline');
                    if((strcmp(folder,'sext') || strcmp(folder,'sext2')) && is_sextupole == true)
                        r = roots(polyder(p));
                        r2 = r(imag(r) == 0&real(r)<max(var)&real(r)>min(var));
                        value = mean(r2);
                        posBPMMin2 = [posBPMMin2; value];
                    else
                        value = -p(2)/(2*p(1));
                        posBPMMin2 = [posBPMMin2; value];
                    end
                    %{
                    Ma = polyval(p,value);
                    [Mb,Ib] = min(interp2);
                    figure; plot(var - ring{quadru}.T2(1), meritfunction, 'ko');
                    hold on;
                    plot(vVar - ring{quadru}.T2(1), f);
                    plot(vVar- ring{quadru}.T2(1), interp2);
                    plot(value - ring{quadru}.T2(1), Ma, '*')
                    plot(vVar(Ib)- ring{quadru}.T2(1), Mb, '*')
                    hold off;
                    %}
                    
                else
                    posBPMMin2 = [posBPMMin2; 0];
                end
            end
                
            posQuadruMin = [];
            posQuadruMinTune = [];
            for j=1:6
                var = posQuadru(j,:);
                interp = interp1(kicks,var,vkicks,'spline');
                posQuadruMin = [posQuadruMin; interp(I)];
                var = posQuadruTune(j,:);
                interp = interp1(kicks,var,vkicks,'spline');
                posQuadruMinTune = [posQuadruMinTune; interp(It)];
            end
            
            posBPMMin = [];
            posBPMMinTune = [];
            for j=1:6
                var = posBPM(j,:);
                interp = interp1(kicks,var,vkicks,'spline');
                posBPMMin = [posBPMMin; interp(I)];
                var = posBPMTune(j,:);
                interp = interp1(kicks,var,vkicks,'spline');
                posBPMMinTune = [posBPMMinTune; interp(It)];
            end
            
            posQuadruFinalMin = [];
            posQuadruFinalMinTune = [];
            for j=1:6
                var = posQuadruFinal(j,:);
                interp = interp1(kicks,var,vkicks,'spline');
                posQuadruFinalMin = [posQuadruFinalMin; interp(I)];
                var = posQuadruFinalTune(j,:);
                interp = interp1(kicks,var,vkicks,'spline');
                posQuadruFinalMinTune = [posQuadruFinalMinTune; interp(It)];
            end
            
            BBAanalyse = [];
            BBAanalyse.interp_num = interp_num;
            BBAanalyse.kickMin = kickMin;
            BBAanalyse.functionMin = functionMin;
            BBAanalyse.kickMin2 = kickMin2;
            BBAanalyse.functionMin2 = functionMin2;
            BBAanalyse.posQuadruMin = posQuadruMin;
            BBAanalyse.posBPMMin = posBPMMin;
            BBAanalyse.posQuadruMin2 = posQuadruMin2;
            BBAanalyse.posBPMMin2 = posBPMMin2;
            BBAanalyse.posQuadruFinalMin = posQuadruFinalMin;
            
            BBAanalyse.kickMinTune = kickMinTune;
            BBAanalyse.functionMinTune = functionMinTune;
            BBAanalyse.posQuadruMinTune = posQuadruMinTune;
            BBAanalyse.posBPMMinTune = posBPMMinTune;
            BBAanalyse.posQuadruFinalMinTune = posQuadruFinalMinTune;
            
            BBAanalyseX = BBAanalyse;
            
            %-----Análise do BBA na direção Y-----
            
            BBAresult = data.BBAresultY;
            BBAresultTune = data.BBAresultYtune;
            
            kicks = BBAresult.kicks;
            meritfunction = BBAresult.meritfunction;
            posQuadru = BBAresult.posQuadru;
            posBPM = BBAresult.posBPM;
            posQuadruFinal = BBAresult.posQuadruFinal;
            
            tune1 = BBAresultTune.deltaTune1;
            tune2 = BBAresultTune.deltaTune2;
            desvTune = tune1.*tune1 + tune2.*tune2;
            posQuadruTune = BBAresultTune.posQuadru;
            posBPMTune = BBAresultTune.posBPM;
            posQuadruFinalTune = BBAresultTune.posQuadruFinal;
            
            %Obtém os valores que minimizam a função de mérito
            %Utilizando Interpolação Spline
            %OBS: Regressão linear assumindo uma parábola não funcionou muito bem
            vkicks = min(kicks):(max(kicks)-min(kicks))/interp_num:max(kicks);
            interp = interp1(kicks,meritfunction,vkicks,'spline');
            [M,I] = min(interp);
            kickMin = vkicks(I);
            functionMin = M;
            
            interpTune = interp1(kicks,desvTune,vkicks,'spline');
            [Mt,It] = min(interpTune);
            kickMinTune = vkicks(It);
            functionMinTune = Mt;
            
            %regressão nos kicks (parece que funciona também)
            if((strcmp(folder,'sext') || strcmp(folder,'sext2')) && is_sextupole == true)
            	%p = polyfit(kicks, meritfunction, 4);
                p = fitQuartic(kicks, meritfunction, false);
            else
            	p = polyfit(kicks, meritfunction, 2);
            end
            f = polyval(p,transpose(vkicks));
            if((strcmp(folder,'sext') || strcmp(folder,'sext2')) && is_sextupole == true)
            	r = roots(polyder(p));
            	r2 = r(imag(r) == 0&real(r)<max(kicks)&real(r)>min(kicks));
            	kickMin2 = mean(r2);
            else
            	kickMin2 = -p(2)/(2*p(1));
            end
            functionMin2 = polyval(p,kickMin2);
            %{
            figure; plot(kicks, meritfunction, 'ko');
            hold on;
            plot(vkicks, f);
            plot(vkicks, interp);
            plot(kickMin2, functionMin2, '*')
            plot(kickMin, functionMin, '*')
            hold off;
            %}
            
            posQuadruMin2 = [];
            for j=1:6
                if (j == 3)
                    var = posQuadru(j,:);
                    if((strcmp(folder,'sext') || strcmp(folder,'sext2')) && is_sextupole == true)
                        %p = polyfit(transpose(var), meritfunction, 4);
                        p = fitQuartic(transpose(var), meritfunction, false);
                    else
                        p = polyfit(transpose(var), meritfunction, 2);
                    end
                    vVar = min(var):(max(var)-min(var))/interp_num:max(var);
                    f = polyval(p,transpose(vVar));
                    interp2 = interp1(var,meritfunction,vVar,'spline');
                    if((strcmp(folder,'sext') || strcmp(folder,'sext2')) && is_sextupole == true)
                        r = roots(polyder(p));
                        r2 = r(imag(r) == 0&real(r)<max(var)&real(r)>min(var));
                        value = mean(r2);
                        posQuadruMin2 = [posQuadruMin2; value];
                    else
                        value = -p(2)/(2*p(1));
                        posQuadruMin2 = [posQuadruMin2; value];
                    end
                    %{
                    Ma = polyval(p,value);
                    [Mb,Ib] = min(interp2);
                    figure; plot(var - ring{quadru}.T2(3), meritfunction, 'ko');
                    hold on;
                    plot(vVar - ring{quadru}.T2(3), f);
                    plot(vVar- ring{quadru}.T2(3), interp2);
                    plot(value - ring{quadru}.T2(3), Ma, '*')
                    plot(vVar(Ib)- ring{quadru}.T2(3), Mb, '*')
                    hold off;
                    %}
                else
                    posQuadruMin2 = [posQuadruMin2; 0];
                end
            end
            
            posBPMMin2 = [];
            for j=1:6
                if (j == 3)
                    var = posBPM(j,:);
                    if((strcmp(folder,'sext') || strcmp(folder,'sext2')) && is_sextupole == true)
                        %p = polyfit(transpose(var), meritfunction, 4);
                        p = fitQuartic(transpose(var), meritfunction, false);
                    else
                        p = polyfit(transpose(var), meritfunction, 2);
                    end
                    vVar = min(var):(max(var)-min(var))/interp_num:max(var);
                    f = polyval(p,transpose(vVar));
                    interp2 = interp1(var,meritfunction,vVar,'spline');
                    if((strcmp(folder,'sext') || strcmp(folder,'sext2')) && is_sextupole == true)
                        r = roots(polyder(p));
                        r2 = r(imag(r) == 0&real(r)<max(var)&real(r)>min(var));
                        value = mean(r2);
                        posBPMMin2 = [posBPMMin2; value];
                    else
                        value = -p(2)/(2*p(1));
                        posBPMMin2 = [posBPMMin2; value];
                    end
                    %{
                    Ma = polyval(p,value);
                    [Mb,Ib] = min(interp2);
                    figure; plot(var - ring{quadru}.T2(3), meritfunction, 'ko');
                    hold on;
                    plot(vVar - ring{quadru}.T2(3), f);
                    plot(vVar- ring{quadru}.T2(3), interp2);
                    plot(value - ring{quadru}.T2(3), Ma, '*')
                    plot(vVar(Ib)- ring{quadru}.T2(3), Mb, '*')
                    hold off;
                    %}
                else
                    posBPMMin2 = [posBPMMin2; 0];
                end
            end
            
            posQuadruMin = [];
            posQuadruMinTune = [];
            for j=1:6
                var = posQuadru(j,:);
                interp = interp1(kicks,var,vkicks,'spline');
                posQuadruMin = [posQuadruMin; interp(I)];
                var = posQuadruTune(j,:);
                interp = interp1(kicks,var,vkicks,'spline');
                posQuadruMinTune = [posQuadruMinTune; interp(It)];
            end
            
            posBPMMin = [];
            posBPMMinTune = [];
            for j=1:6
                var = posBPM(j,:);
                interp = interp1(kicks,var,vkicks,'spline');
                posBPMMin = [posBPMMin; interp(I)];
                var = posBPMTune(j,:);
                interp = interp1(kicks,var,vkicks,'spline');
                posBPMMinTune = [posBPMMinTune; interp(It)];
            end
            
            posQuadruFinalMin = [];
            posQuadruFinalMinTune = [];
            for j=1:6
                var = posQuadruFinal(j,:);
                interp = interp1(kicks,var,vkicks,'spline');
                posQuadruFinalMin = [posQuadruFinalMin; interp(I)];
                var = posQuadruFinalTune(j,:);
                interp = interp1(kicks,var,vkicks,'spline');
                posQuadruFinalMinTune = [posQuadruFinalMinTune; interp(It)];
            end
            
            BBAanalyse = [];
            BBAanalyse.interp_num = interp_num;
            BBAanalyse.kickMin = kickMin;
            BBAanalyse.functionMin = functionMin;
            BBAanalyse.kickMin2 = kickMin2;
            BBAanalyse.functionMin2 = functionMin2;
            BBAanalyse.posQuadruMin = posQuadruMin;
            BBAanalyse.posBPMMin = posBPMMin;
            BBAanalyse.posQuadruMin2 = posQuadruMin2;
            BBAanalyse.posBPMMin2 = posBPMMin2;
            BBAanalyse.posQuadruFinalMin = posQuadruFinalMin;
            
            BBAanalyse.kickMinTune = kickMinTune;
            BBAanalyse.functionMinTune = functionMinTune;
            BBAanalyse.posQuadruMinTune = posQuadruMinTune;
            BBAanalyse.posBPMMinTune = posBPMMinTune;
            BBAanalyse.posQuadruFinalMinTune = posQuadruFinalMinTune;
            
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
            fprintf('ERRO BBA2: (%d , %d)\n', abs(BBAanalyseX.posBPMMin2(1) - ring{quadru}.T2(1)), abs(BBAanalyseX.posBPMMin2(3) - ring{quadru}.T2(3)));
            fprintf('ERRO DistCentro2: (%d , %d)\n', abs(BBAanalyseX.posQuadruMin2(1) - ring{quadru}.T2(1)), abs(BBAanalyseX.posQuadruMin2(3) - ring{quadru}.T2(3)));
            fprintf('Tempo de Execução (s): %.2f\n', (tf-t0)*100000);
            fprintf('--------------------\n');
        end
        
        pot = 1e6; % seta a escola dos dados (um)

        kicksX = {};
        kicksY = {};
        meritfunctionX = {};
        meritfunctionY = {};

        functionMinX = {};
        functionMinY = {};

        desvQuadruX = {};
        desvQuadruY = {};
        desvBPMX = {};
        desvBPMY = {};

        desvQuadruX2 = {};
        desvQuadruY2 = {};
        desvBPMX2 = {};
        desvBPMY2 = {};
        
        desvQuadruXtune = {};
        desvQuadruYtune = {};
        desvBPMXtune = {};
        desvBPMYtune = {};

        correcao1x = {};
        correcao2x = {};
        correcao1y = {};
        correcao2y = {};
        correcao3x_X = {};
        correcao3y_X = {};
        correcao3x_Y = {};
        correcao3y_Y = {};
        
        %------Kscan------
        Ks = {};
        meritfunctionKx = {};
        meritfunctionKy = {};
        iQuadrux = {};
        iQuadruy = {};
        cQuadrux = {};
        cQuadruy = {};
        dervX = {};
        dervY = {};

        for i=1:3
            kicksX{i} = [];
            kicksY{i} = [];
            meritfunctionX{i} = [];
            meritfunctionY{i} = [];

            functionMinX{i} = [];
            functionMinY{i} = [];

            desvQuadruX{i} = [];
            desvQuadruY{i} = [];
            desvBPMX{i} = [];
            desvBPMY{i} = [];

            desvQuadruX2{i} = [];
            desvQuadruY2{i} = [];
            desvBPMX2{i} = [];
            desvBPMY2{i} = [];
            
            desvQuadruXtune{i} = [];
            desvQuadruYtune{i} = [];
            desvBPMXtune{i} = [];
            desvBPMYtune{i} = [];

            correcao1x{i} = [];
            correcao2x{i} = [];
            correcao1y{i} = [];
            correcao2y{i} = [];
            correcao3x_X{i} = [];
            correcao3y_X{i} = [];
            correcao3x_Y{i} = [];
            correcao3y_Y{i} = [];
            
            %------Kscan------
            Ks{i} = [];
            meritfunctionKx{i} = [];
            meritfunctionKy{i} = [];
            iQuadrux{i} = [];
            iQuadruy{i} = [];
            cQuadrux{i} = [];
            cQuadruy{i} = [];
            dervX{i} = [];
            dervY{i} = [];
        end
        
        t0 = datenum(datetime('now'));
        for i=1:totalBPM
            bpm = alist_bpm(i);
            quadru = alist_quadru(i);
            is_skew = isSkew(family_data,quadru);
            is_sextupole = isSextupole(family_data,quadru);

            %Abre os arquivos das simulações neste bpm
            string = [caminho_arquivos folder '/' 'M' num2str(m) '_' num2str(recursao) 'r' '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' num2str(interp_num) '_' 'data.mat'];
            load(string);

            %Escolhe o indice correto para cada quadrupolo
            index = 1;
            if(is_skew == true)
                index = index + 1;
                if(is_sextupole == true)
                    index = index + 1;
                end
            end

            BBAresult = data.BBAresultX;
            BBAresult.kicks = BBAresult.kicks*pot;
            BBAresult.meritfunction = BBAresult.meritfunction*pot*pot;
            kicksX{index} = [kicksX{index}, BBAresult.kicks];
            meritfunctionX{index} = [meritfunctionX{index}, BBAresult.meritfunction];

            BBAresult = data.BBAresultY;
            BBAresult.kicks = BBAresult.kicks*pot;
            BBAresult.meritfunction = BBAresult.meritfunction*pot*pot;
            kicksY{index} = [kicksY{index}, BBAresult.kicks];
            meritfunctionY{index} = [meritfunctionY{index}, BBAresult.meritfunction];

            functionMin = data.BBAanalyseX.functionMin*pot*pot;
            functionMinX{index} = [functionMinX{index}; functionMin];
            functionMin = data.BBAanalyseY.functionMin*pot*pot;
            functionMinY{index} = [functionMinY{index}; functionMin];

            posCenterQuadru = [pot*ring{quadru}.T2(1); 0; pot*ring{quadru}.T2(3); 0; 0; 0];

            posQuadruMin = data.BBAanalyseX.posQuadruMin*pot;
            posBPMMin = data.BBAanalyseX.posBPMMin*pot;
            desvQuadruX{index} = [desvQuadruX{index}, posQuadruMin - posCenterQuadru];
            desvBPMX{index} = [desvBPMX{index}, posBPMMin - posCenterQuadru];
            posQuadruMin = data.BBAanalyseY.posQuadruMin*pot;
            posBPMMin = data.BBAanalyseY.posBPMMin*pot;
            desvQuadruY{index} = [desvQuadruY{index}, posQuadruMin - posCenterQuadru];
            desvBPMY{index} = [desvBPMY{index}, posBPMMin - posCenterQuadru];

            posQuadruMin2 = data.BBAanalyseX.posQuadruMin2*pot;
            posBPMMin2 = data.BBAanalyseX.posBPMMin2*pot;
            desvQuadruX2{index} = [desvQuadruX2{index}, posQuadruMin2 - posCenterQuadru];
            desvBPMX2{index} = [desvBPMX2{index}, posBPMMin2 - posCenterQuadru];
            posQuadruMin2 = data.BBAanalyseY.posQuadruMin2*pot;
            posBPMMin2 = data.BBAanalyseY.posBPMMin2*pot;
            desvQuadruY2{index} = [desvQuadruY2{index}, posQuadruMin2 - posCenterQuadru];
            desvBPMY2{index} = [desvBPMY2{index}, posBPMMin2 - posCenterQuadru];
            
            posQuadruMinTune = data.BBAanalyseX.posQuadruMinTune*pot;
            posBPMMinTune = data.BBAanalyseX.posBPMMinTune*pot;
            desvQuadruXtune{index} = [desvQuadruXtune{index}, posQuadruMinTune - posCenterQuadru];
            desvBPMXtune{index} = [desvBPMXtune{index}, posBPMMinTune - posCenterQuadru];
            posQuadruMinTune = data.BBAanalyseY.posQuadruMin*pot;
            posBPMMinTune = data.BBAanalyseY.posBPMMin*pot;
            desvQuadruYtune{index} = [desvQuadruYtune{index}, posQuadruMinTune - posCenterQuadru];
            desvBPMYtune{index} = [desvBPMYtune{index}, posBPMMinTune - posCenterQuadru];

            L = the_ring{quadru}.Length;
            if(bpm > quadru)
                D = findsposOff(the_ring,bpm) - findsposOff(the_ring,quadru) - L;
            else
                D = findsposOff(the_ring,quadru) - findsposOff(the_ring,bpm);
            end
            x0lX = data.BBAanalyseX.posQuadruMin(2);
            y0lX = data.BBAanalyseX.posQuadruMin(4);
            x0lY = data.BBAanalyseY.posQuadruMin(2);
            y0lY = data.BBAanalyseY.posQuadruMin(4);
            if(is_sextupole == true)
                fprintf('%d %d %d %d\n', x0lX, y0lX, x0lY, y0lY);
            end
            Gx = ring{quadru}.PolynomA(1);
            Gy = ring{quadru}.PolynomB(1);
            K = ring{quadru}.PolynomB(2);
            Kp = ring{quadru}.PolynomA(2);
            S = ring{quadru}.PolynomB(3);
            x0 = Gy*L*L/24 + (Gy*K-Gx*Kp)*L*L*L*L/5760;
            y0 = -Gx*L*L/24 + (Gy*Kp+Gx*K)*L*L*L*L/5760;
            x1 = -(1/8)*L*L*Gy + (1/384)*L*L*L*L*(Gx*Kp-Gy*K);
            y1 = (1/8)*L*L*Gx - (1/384)*L*L*L*L*(Gy*Kp+Gx*K);
            x2X = (1/2)*L*x0lX - (1/48)*L*L*L*(y0lX*Kp+x0lX*K);
            y2X = (1/2)*L*y0lX - (1/48)*L*L*L*(x0lX*Kp-y0lX*K);
            x2Y = (1/2)*L*x0lY - (1/48)*L*L*L*(y0lY*Kp+x0lY*K);
            y2Y = (1/2)*L*y0lY - (1/48)*L*L*L*(x0lY*Kp-y0lY*K);
            x3 = -D*(Gy*L)/2;
            y3 = D*(Gx*L)/2;
            x4X = D*x0lX - (1/8)*D*L*L*(y0lX*Kp+x0lX*K);
            y4X = D*y0lX - (1/8)*D*L*L*(x0lX*Kp-y0lX*K);
            x4Y = D*x0lY - (1/8)*D*L*L*(y0lY*Kp+x0lY*K);
            y4Y = D*y0lY - (1/8)*D*L*L*(x0lY*Kp-y0lY*K);
            if strcmp(folder,'plusK') || strcmp(folder,'plusK2') || strcmp(folder,'plusKt')
                correcao1x{index} = [correcao1x{index}, pot*x0];
                correcao1y{index} = [correcao1y{index}, pot*y0];
                correcao2x{index} = [correcao2x{index}, pot*x1 + pot*x3];
                correcao2y{index} = [correcao2y{index}, pot*y1 + pot*y3];
                correcao3x_X{index} = [correcao3x_X{index}, pot*sign(bpm-quadru)*(x2X + x4X)];
                correcao3y_X{index} = [correcao3y_X{index}, pot*sign(bpm-quadru)*(y2X + y4X)];
                correcao3x_Y{index} = [correcao3x_Y{index}, pot*sign(bpm-quadru)*(x2Y + x4Y)];
                correcao3y_Y{index} = [correcao3y_Y{index}, pot*sign(bpm-quadru)*(y2Y + y4Y)];
            end
            if ((strcmp(folder,'sext') || strcmp(folder,'sext2')) || strcmp(folder,'sextt') || strcmp(folder,'sextder')) && is_sextupole == false
                correcao1x{index} = [correcao1x{index}, pot*x0];
                correcao1y{index} = [correcao1y{index}, pot*y0];
                correcao2x{index} = [correcao2x{index}, pot*x1 + pot*x3];
                correcao2y{index} = [correcao2y{index}, pot*y1 + pot*y3];
                correcao3x_X{index} = [correcao3x_X{index}, pot*sign(bpm-quadru)*(x2X + x4X)];
                correcao3y_X{index} = [correcao3y_X{index}, pot*sign(bpm-quadru)*(y2X + y4X)];
                correcao3x_Y{index} = [correcao3x_Y{index}, pot*sign(bpm-quadru)*(x2Y + x4Y)];
                correcao3y_Y{index} = [correcao3y_Y{index}, pot*sign(bpm-quadru)*(y2Y + y4Y)];
            end
            if ((strcmp(folder,'sext') || strcmp(folder,'sext2')) || strcmp(folder,'sextt') || strcmp(folder,'sextder')) && is_sextupole == true
                correcao1x{index} = [correcao1x{index}, pot*x0];
                correcao1y{index} = [correcao1y{index}, pot*y0];
                correcao2x{index} = [correcao2x{index}, pot*x1 + pot*x3];
                correcao2y{index} = [correcao2y{index}, pot*y1 + pot*y3];
                correcao3x_X{index} = [correcao3x_X{index}, pot*sign(bpm-quadru)*(x2X + x4X)];
                correcao3y_X{index} = [correcao3y_X{index}, pot*sign(bpm-quadru)*(y2X + y4X)];
                correcao3x_Y{index} = [correcao3x_Y{index}, pot*sign(bpm-quadru)*(x2Y + x4Y)];
                correcao3y_Y{index} = [correcao3y_Y{index}, pot*sign(bpm-quadru)*(y2Y + y4Y)];
            end
            
            if strcmp(folder,'plusK') || strcmp(folder,'plusK2') || strcmp(folder,'plusKt')
                Kresult = data.Kresult;
                derivadaX = Kresult.derivadaX*pot;
                derivadaY = Kresult.derivadaY*pot;
                centerQuadrux = Kresult.centerQuadrux*pot;
                centerQuadruy = Kresult.centerQuadruy*pot;
                inclQuadrux = Kresult.inclQuadrux*pot;
                inclQuadruy = Kresult.inclQuadruy*pot;

                Ks{index} = [Ks{index}, Kresult.Ks];
                meritfunctionKx{index} = [meritfunctionKx{index}, Kresult.meritfunctionKx*pot];
                meritfunctionKy{index} = [meritfunctionKy{index}, Kresult.meritfunctionKy*pot];

                cQuadrux{index} = [cQuadrux{index}; centerQuadrux - pot*ring{quadru}.T2(1)];
                cQuadruy{index} = [cQuadruy{index}; centerQuadruy - pot*ring{quadru}.T2(3)];
                iQuadrux{index} = [iQuadrux{index}; inclQuadrux];
                iQuadruy{index} = [iQuadruy{index}; inclQuadruy];
                dervX{index} = [dervX{index}; derivadaX];
                dervY{index} = [dervY{index}; derivadaY];
            end
        end
        
        tf = datenum(datetime('now'));
        fprintf('Tempo de Execução (s): %.2f\n', (tf-t0)*100000);
        
        string = [caminho_arquivos folder '/' 'Graficos' '_' 'M' num2str(m) '_' num2str(recursao) 'r' '_' num2str(range) '_' num2str(random_error) '_' num2str(interp_num) '_' 'data.mat'];
        save(string, 'kicksX','kicksY','meritfunctionX','meritfunctionY','functionMinX','functionMinY','desvQuadruX','desvQuadruY','desvBPMX','desvBPMY','correcao1x','correcao1y','correcao2x','correcao2y','correcao3x_X','correcao3y_X','correcao3x_Y','correcao3y_Y','desvQuadruXtune','desvQuadruYtune','desvBPMXtune','desvBPMYtune','desvQuadruX2','desvQuadruY2','desvBPMX2','desvBPMY2');
    end

end
