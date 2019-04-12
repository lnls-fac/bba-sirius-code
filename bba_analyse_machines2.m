caminho_arquivos = '../bba-sirius-data/';
folder = 'plusK';

%configuracoes do arquivo a ser carregado
recursao = 1;
range = 10;
random_error = false;
interp_num = 1000000;

pot = 1e6; % seta a escola dos dados (um)
corrigir = true; % configura se usará as expressões teóricas de correção
corrigir_ang = false;

t0 = datenum(datetime('now'));
string = [caminho_arquivos folder '/' 'Media' '_' num2str(recursao) 'r' '_' num2str(range) '_' num2str(random_error) '_' num2str(interp_num) '_' num2str(corrigir) '_' num2str(corrigir_ang) '_' 'data.mat'];
load(string);

%inicializa as variáveis necessárias
sigmaX = {};
sigmaY = {};
for i=1:3
    sigmaX{i} = [];
    sigmaY{i} = [];
end

%length(machine)
for m=1:length(machine)
    t0 = datenum(datetime('now'));
    %carrega o anel correspondente
    if(m==0)
        ring = the_ring;
    else
        ring = machine{m};
    end

    %inicializa as variáveis necessárias
    desvQuadruX = {};
    desvQuadruY = {};
    desvBPMX = {};
    desvBPMY = {};
    correcao1x = {};
    correcao2x = {};
    correcao1y = {};
    correcao2y = {};
    correcao3x_X = {};
    correcao3y_X = {};
    correcao3x_Y = {};
    correcao3y_Y = {};

    for i=1:3
        desvQuadruX{i} = [];
        desvQuadruY{i} = [];
        desvBPMX{i} = [];
        desvBPMY{i} = [];
        correcao1x{i} = [];
        correcao2x{i} = [];
        correcao1y{i} = [];
        correcao2y{i} = [];
        correcao3x_X{i} = [];
        correcao3y_X{i} = [];
        correcao3x_Y{i} = [];
        correcao3y_Y{i} = [];
    end
    
    for i=1:length(alist_bpm)
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
        %posCenterQuadru = [pot*ring{quadru}.T2(1); pot*ring{quadru}.T2(2); pot*ring{quadru}.T2(3); pot*ring{quadru}.T2(4); 0; 0];
        posCenterQuadru = [pot*ring{quadru}.T2(1); 0; pot*ring{quadru}.T2(3); 0; 0; 0];

        posQuadruMin = data.BBAanalyseX.posQuadruMin*pot;
        posBPMMin = data.BBAanalyseX.posBPMMin*pot;
        desvQuadruX{index} = [desvQuadruX{index}, posQuadruMin - posCenterQuadru];
        desvBPMX{index} = [desvBPMX{index}, posBPMMin - posCenterQuadru];
        posQuadruMin = data.BBAanalyseY.posQuadruMin*pot;
        posBPMMin = data.BBAanalyseY.posBPMMin*pot;
        desvQuadruY{index} = [desvQuadruY{index}, posQuadruMin - posCenterQuadru];
        desvBPMY{index} = [desvBPMY{index}, posBPMMin - posCenterQuadru];

        %Calcula as expressões teóricas de correção
        if(corrigir == true)
            L = the_ring{quadru}.Length;
            if(bpm > quadru)
                D = findsposOff(the_ring,bpm) - findsposOff(the_ring,quadru) - L;
            else
                D = findsposOff(the_ring,quadru) - findsposOff(the_ring,bpm);
            end
            if(corrigir_ang == true)
                x0lX = data.BBAanalyseX.posQuadruMin(2);
                y0lX = data.BBAanalyseX.posQuadruMin(4);
                x0lY = data.BBAanalyseY.posQuadruMin(2);
                y0lY = data.BBAanalyseY.posQuadruMin(4);
            else
                x0lX = 0; %Não corrige erro do angulo
                y0lX = 0; %Não corrige erro do angulo
                x0lY = 0; %Não corrige erro do angulo
                y0lY = 0; %Não corrige erro do angulo
            end
            Gx = ring{quadru}.PolynomA(1);
            Gy = ring{quadru}.PolynomB(1);
            K = ring{quadru}.PolynomB(2);
            x0 = (-1/24)*(-Gy)*L*L*(1 + K*(L*L/80))/(1 + K*(L*L/24));
            y0 = (-1/24)*Gx*L*L*(1 - K*(L*L/80))/(1 - K*(L*L/24));
            if(K > 0)
                x0 = (Gy/K)*(1 - (L*sqrt(K)/2)/(sin(L*sqrt(K)/2)));
                y0 = (Gx/K)*(1 - (L*sqrt(K))/(exp(L*sqrt(K)/2)-exp(-L*sqrt(K)/2)));
            end
            if(K < 0)
                x0 = (Gy/K)*(1 - (L*sqrt(-K))/(exp(L*sqrt(-K)/2)-exp(-L*sqrt(-K)/2)));
                y0 = (Gx/K)*(1 - (L*sqrt(-K)/2)/(sin(L*sqrt(-K)/2)));
            end
            correcao1x{index} = [correcao1x{index}, pot*x0];
            correcao1y{index} = [correcao1y{index}, pot*y0];
            correcao2x{index} = [correcao2x{index}, pot*((1/8)*(-Gy)*L*L + (1/8)*x0*(-K)*L*L + (Gy*L*L)*(K*L*L)/(12*32)) + pot*(D/2)*((-Gy)*L + x0*(-K)*L + ((-Gy)*L*L)*((-K)*L)/24)];
            correcao2y{index} = [correcao2y{index}, pot*((1/8)*(Gx)*L*L + (1/8)*y0*(K)*L*L + (Gx*L*L)*(K*L*L)/(12*32)) + pot*(D/2)*((Gx)*L + y0*(K)*L + ((Gx)*L*L)*((K)*L)/24)];
            correcao3x_X{index} = [correcao3x_X{index}, pot*sign(bpm-quadru)*(x0lX*L/2)*(1 + (-K)*L*L/24) + pot*sign(bpm-quadru)*x0lX*D*(1 + (-K)*L*L/8)];
            correcao3y_X{index} = [correcao3y_X{index}, pot*sign(bpm-quadru)*(y0lX*L/2)*(1 + (K)*L*L/24) + pot*sign(bpm-quadru)*y0lX*D*(1 + (K)*L*L/8)];
            correcao3x_Y{index} = [correcao3x_Y{index}, pot*sign(bpm-quadru)*(x0lY*L/2)*(1 + (-K)*L*L/24) + pot*sign(bpm-quadru)*x0lY*D*(1 + (-K)*L*L/8)];
            correcao3y_Y{index} = [correcao3y_Y{index}, pot*sign(bpm-quadru)*(y0lY*L/2)*(1 + (K)*L*L/24) + pot*sign(bpm-quadru)*y0lY*D*(1 + (K)*L*L/8)];
        else
            correcao1x{index} = [correcao1x{index}, 0];
            correcao1y{index} = [correcao1y{index}, 0];
            correcao2x{index} = [correcao2x{index}, 0];
            correcao2y{index} = [correcao2y{index}, 0];
            correcao3x_X{index} = [correcao3x_X{index}, 0];
            correcao3y_X{index} = [correcao3y_X{index}, 0];
            correcao3x_Y{index} = [correcao3x_Y{index}, 0];
            correcao3y_Y{index} = [correcao3y_Y{index}, 0];
        end
    end
    tf = datenum(datetime('now'));
    fprintf('Tempo de Execução (s): %.2f\n', (tf-t0)*100000);
    
    if(m==1)
        for i=1:3
            tam = length(correcao1xm{i});
            for j=1:tam
                valX = desvBPMX{i}(1,j) - correcao1x{i}(j) - correcao2x{i}(j) - correcao3x_X{i}(j);
                valY = desvBPMY{i}(3,j) - correcao1y{i}(j) - correcao2y{i}(j) - correcao3y_Y{i}(j);
                valXm = desvBPMXm{i}(1,j) - correcao1xm{i}(j) - correcao2xm{i}(j) - correcao3x_Xm{i}(j);
                valYm = desvBPMYm{i}(3,j) - correcao1ym{i}(j) - correcao2ym{i}(j) - correcao3y_Ym{i}(j);
                varX = (valX - valXm)*(valX - valXm);
                varY = (valY - valXm)*(valY - valXm);
                sigmaX{i} = [sigmaX{i}, varX];
                sigmaY{i} = [sigmaY{i}, varY];
            end
        end
    else
        for i=1:3
            tam = length(correcao1xm{i});
            for j=1:tam
                valX = desvBPMX{i}(1,j) - correcao1x{i}(j) - correcao2x{i}(j) - correcao3x_X{i}(j);
                valY = desvBPMY{i}(3,j) - correcao1y{i}(j) - correcao2y{i}(j) - correcao3y_Y{i}(j);
                valXm = desvBPMXm{i}(1,j) - correcao1xm{i}(j) - correcao2xm{i}(j) - correcao3x_Xm{i}(j);
                valYm = desvBPMYm{i}(3,j) - correcao1ym{i}(j) - correcao2ym{i}(j) - correcao3y_Ym{i}(j);
                varX = (valX - valXm)*(valX - valXm);
                varY = (valY - valXm)*(valY - valXm);
                sigmaX{i}(j) = sigmaX{i}(j) + varX;
                sigmaY{i}(j) = sigmaY{i}(j) + varY;
            end
        end
    end
        
end

max = 20;
for i=1:3
    sigmaX{i} = sigmaX{i}/max;
    sigmaY{i} = sigmaY{i}/max;
end
for i=1:3
    tam = length(correcao1xm{i});
    for j=1:tam
        sigmaX{i}(j) = sqrt(sigmaX{i}(j));
        sigmaY{i}(j) = sqrt(sigmaY{i}(j));
    end
end

string = [caminho_arquivos folder '/' 'Sigma' '_' num2str(recursao) 'r' '_' num2str(range) '_' num2str(random_error) '_' num2str(interp_num) '_' num2str(corrigir) '_' num2str(corrigir_ang) '_' 'data.mat'];
save(string, 'sigmaX', 'sigmaY');