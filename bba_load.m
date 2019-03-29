caminho_arquivos = '../bba-sirius-data/';
folder = 'plusK';

%configuracoes do arquivo a ser carregado
range = 10;
random_error = false;
m = 1;
recursao = 1;

corrigir = true; %configura se usará as expressões teóricas de correção

%carrega o anel correspondente
if(m==0)
	ring = the_ring;
else
	ring = machine{m};
end

%seta o formato dos pontos e cores nos gráficos
l = ['bo'; 'rs'; 'k*'];

%inicializa as variáveis necessárias
list_bpm = {};
list_quadru = {};
functionMin = {};

list_aux = {};
list_desv = {};

desvbpm = {};
ang = {};

desvInt = {};
angInt = {};

desvReto = {};
angReto = {};

correcao1x = {};
correcao2x = {};
correcao1y = {};
correcao2y = {};
correcao3x = {};
correcao3y = {};

text_bpm = {};
text_quadru = {};

for i=1:3
    list_bpm{i} = [];
    list_quadru{i} = [];
    functionMin{i} = [];
    
    list_desv{i} = [];
    list_aux{i} = [];
    
    desvbpm{i} = [];
    ang{i} = [];
    
    desvInt{i} = [];
    angInt{i} = [];
    
    desvReto{i} = [];
    angReto{i} = [];
    
    correcao1x{i} = [];
    correcao2x{i} = [];
    correcao1y{i} = [];
    correcao2y{i} = [];
    correcao3x{i} = [];
    correcao3y{i} = [];
    
    text_bpm{i} = [];
    text_quadru{i} = [];
end

%cria os espaços para os gráficos da primeira figura
figure('NumberTitle', 'off', 'Name', ['Máquina ' num2str(m) '_' num2str(recursao) 'r - Desvios']);
ax1 = subplot(2,2,1);
ax2 = subplot(2,2,2);
ax3 = subplot(2,2,3);
ax4 = subplot(2,2,4);
hold(ax1,'on');
hold(ax2,'on');
hold(ax3,'on');
hold(ax4,'on');
xlabel(ax1,'Kick da Corretora Horizontal (urad)');
ylabel(ax1,'Desvio H-blue/ V-red/black (um)');
xlabel(ax2,'Kick da Corretora Vertical (urad)');
ylabel(ax2,'Desvio H-blue/ V-red/black (um)');
xlabel(ax3,'Posicao do Quadru (m)');
ylabel(ax3,'Desvio BBA Horizontal (um)');
xlabel(ax4,'Posicao do Quadru (m)');
ylabel(ax4,'Desvio BBA Vertical (um)');

%for i=1:length(alist_bpm)
for i=1:length(alist_bpm)
    bpm = alist_bpm(i);
    quadru = alist_quadru(i);
    is_skew = isSkew(family_data,quadru);
    is_sextupole = isSextupole(family_data,quadru);
    
    %Abre os arquivos das simulações neste bpm
    string = [caminho_arquivos folder '/' 'M' num2str(m) '_' num2str(recursao) 'r' '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' 'data.mat'];
    load(string);
    string = [caminho_arquivos 'graphics/' folder '/' 'M' num2str(m) '_' num2str(recursao) 'r' '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' 'kicks.mat'];
    load(string,'kicks');
    string = [caminho_arquivos 'graphics/' folder '/' 'M' num2str(m) '_' num2str(recursao) 'r' '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' 'meritfunction.mat'];
    load(string,'meritfunction');
    
    %Seta a escola dos dados (um)
	pot = 1e6;
    kicks = pot*kicks;
    meritfunction = pot*pot*meritfunction;
    data.bpm = bpm;
    data.quadru = quadru;
	data.corrs = data.corrs;
	data.recursao = data.recursao;
	data.kickMin = pot*data.kickMin;
	data.functionMin = pot*pot*data.functionMin;
	data.centerQuadru = pot*data.centerQuadru;
	data.centerBPM = pot*data.centerBPM;
	data.angQuadru = pot*data.angQuadru;
	data.posQuadruFinal = pot*data.posQuadruFinal;
	data.angQuadruFinal = pot*data.angQuadruFinal;
    data.posQuadruInicio = pot*data.posQuadruInicio;
	data.angQuadruInicio = pot*data.angQuadruInicio;
	data.desvEnerg = pot*data.desvEnerg;
	data.centerQuadruPosPerp = pot*data.centerQuadruPosPerp;
    
    
    %Escolhe o indice correto para cada quadrupolo
    index = 1;
    if(is_skew == true)
        index = index + 1;
        if(is_sextupole == true)
            index = index + 1;
        end
    end
    
    %Ordem de 100-300
    %fprintf('%d -- %d\n', index, data.desvEnerg(1));
    
    text_bpm{index} = [text_bpm{index}; bpm];
    text_quadru{index} = [text_quadru{index}; quadru];
    
	list_bpm{index} = [list_bpm{index}; bpm];
	list_quadru{index} = [list_quadru{index}; quadru];
    functionMin{index} = [functionMin{index}; data.functionMin];
    
	list_desv{index} = [list_desv{index}; [data.centerQuadru(1) - pot*ring{quadru}.T2(1) data.centerQuadru(2) - pot*ring{quadru}.T2(3)]];
    %Mudança para o relatório em list_desv
    %list_desv{index} = [list_desv{index}; [data.centerBPM(1) - pot*ring{quadru}.T2(1) data.centerBPM(2) - pot*ring{quadru}.T2(3)]];
	list_aux{index} = [list_aux{index}; [data.centerQuadruPosPerp(1) - pot*ring{quadru}.T2(3) data.centerQuadruPosPerp(2) - pot*ring{quadru}.T2(1)]];
    
	desvbpm{index} = [desvbpm{index}; data.centerBPM - data.centerQuadru];
    ang{index} = [ang{index}; data.angQuadru];
    
    %Faz as contas corretas dependendo se o BPM está antes ou depois do
    %Quadrupolo
    if(bpm > quadru)
        desvInt{index} = [desvInt{index}; data.posQuadruFinal - data.centerQuadru];
        angInt{index} = [angInt{index}; data.angQuadru];
        
        desvReto{index} = [desvReto{index}; data.centerBPM - data.posQuadruFinal];
        angReto{index} = [angReto{index}; data.angQuadruFinal];
    else
        desvInt{index} = [desvInt{index}; data.centerQuadru - data.posQuadruInicio];
        angInt{index} = [angInt{index}; data.angQuadruInicio];
        
        desvReto{index} = [desvReto{index}; data.posQuadruInicio - data.centerBPM];
        angReto{index} = [angReto{index}; data.angQuadruInicio];
    end
    
    %Plota os gráficos das funções de mérito
    if(is_skew == true)
        if(is_sextupole == true)
            plot(ax1,kicks(1,:),sqrt(meritfunction(1,:)),'k');
            plot(ax2,kicks(2,:),sqrt(meritfunction(2,:)),'k');
        else
           plot(ax1,kicks(1,:),sqrt(meritfunction(1,:)),'r');
           plot(ax2,kicks(2,:),sqrt(meritfunction(2,:)),'r');
        end
    else
        plot(ax1,kicks(1,:),sqrt(meritfunction(1,:)),'b');
        plot(ax2,kicks(2,:),sqrt(meritfunction(2,:)),'b');
    end
    
    %Calcula as expressões teóricas de correção
    if(corrigir == true)
        L = the_ring{quadru}.Length;
        if(bpm > quadru)
            D = findsposOff(the_ring,bpm) - findsposOff(the_ring,quadru) - L;
            x0l = data.angQuadru(1);
            y0l = data.angQuadru(2);
        else
            D = findsposOff(the_ring,quadru) - findsposOff(the_ring,bpm);
            x0l = data.angQuadru(1);
            y0l = data.angQuadru(2);
        end
        %fprintf('%d -- %d\n', index, D);
        %fprintf('%d -- %d\n', index, L);
        %fprintf('%d -- %d   %d\n', index, x0l, y0l);
        x0l = 0; %Não corrige erro do angulo
        y0l = 0; %Não corrige erro do angulo
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
        correcao1x{index} = [correcao1x{index}; pot*x0];
        correcao1y{index} = [correcao1y{index}; pot*y0];
        correcao2x{index} = [correcao2x{index}; pot*((1/8)*(-Gy)*L*L + (1/8)*x0*(-K)*L*L + (Gy*L*L)*(K*L*L)/(12*32)) + sign(bpm-quadru)*(x0l*L/2)*(1 + (-K)*L*L/24)];
        correcao2y{index} = [correcao2y{index}; pot*((1/8)*(Gx)*L*L + (1/8)*y0*(K)*L*L + (Gx*L*L)*(K*L*L)/(12*32)) + sign(bpm-quadru)*(y0l*L/2)*(1 + (K)*L*L/24)];
        correcao3x{index} = [correcao3x{index}; pot*(D/2)*((-Gy)*L + x0*(-K)*L + ((-Gy)*L*L)*((-K)*L)/24) + sign(bpm-quadru)*x0l*D*(1 + (-K)*L*L/8)];
        correcao3y{index} = [correcao3y{index}; pot*(D/2)*((Gx)*L + y0*(K)*L + ((Gx)*L*L)*((K)*L)/24) + sign(bpm-quadru)*y0l*D*(1 + (K)*L*L/8)];
    else
        correcao1x{index} = [correcao1x{index}; 0];
        correcao1y{index} = [correcao1y{index}; 0];
        correcao2x{index} = [correcao2x{index}; 0];
        correcao2y{index} = [correcao2y{index}; 0];
        correcao3x{index} = [correcao3x{index}; 0];
        correcao3y{index} = [correcao3y{index}; 0];
    end

end

%Plota os gráficos de mínimos das funções de mérito
for i=1:3
    plot(ax3,findsposOff(ring,list_quadru{i}),functionMin{i}(:,1),[l(i,:) '-']);
    plot(ax4,findsposOff(ring,list_quadru{i}),functionMin{i}(:,2),[l(i,:) '-']);
end

%Cria os espaços para os gráficos na segunda figura
if(corrigir == true)
    figure('NumberTitle', 'off', 'Name', ['Máquina ' num2str(m) '_' num2str(recursao) 'r - Gráficos Análise 1 Corrigido']);
else
    figure('NumberTitle', 'off', 'Name', ['Máquina ' num2str(m) '_' num2str(recursao) 'r - Gráficos Análise 1']);
end
gr1x = subplot(2,3,1);
gr2x = subplot(2,3,2);
gr3x = subplot(2,3,3);
gr1y = subplot(2,3,4);
gr2y = subplot(2,3,5);
gr3y = subplot(2,3,6);
hold(gr1x,'on');
hold(gr2x,'on');
hold(gr3x,'on');
hold(gr1y,'on');
hold(gr2y,'on');
hold(gr3y,'on');
xlabel(gr1x,'posicao do Quadru (m)');
ylabel(gr1x,'X: Dif Quadru e Real (um)');
xlabel(gr2x,'Dist Y no Quadru do Centro (um)');
ylabel(gr2x,'X: Dif Quadru e Real (um)');
xlabel(gr3x,'X: Angulo no Quadru (urad)');
ylabel(gr3x,'X: Dif BPM e Quadru (um)');
xlabel(gr1y,'posicao do BPM (m)');
ylabel(gr1y,'Y: Dif Quadru e Real (um)');
xlabel(gr2y,'Dist X no Quadru do Centro (um)');
ylabel(gr2y,'Y: Dif Quadru e Real (um)');
xlabel(gr3y,'Y: Angulo no Quadru (urad)');
ylabel(gr3y,'Y: Dif BPM e Quadru (um)');

%Plota os gráficos da segunda figura
for i=1:3
    plot(gr1x,findsposOff(ring,list_quadru{i}),list_desv{i}(:,1) - correcao1x{i},[l(i,:) '-']);
    plot(gr2x,list_aux{i}(:,1),list_desv{i}(:,1) - correcao1x{i},l(i,:));
    plot(gr3x,ang{i}(:,1),desvbpm{i}(:,1) - correcao2x{i} - correcao3x{i},l(i,:));
    
    plot(gr1y,findsposOff(ring,list_quadru{i}),list_desv{i}(:,2) - correcao1y{i},[l(i,:) '-']);
    plot(gr2y,list_aux{i}(:,2),list_desv{i}(:,2) - correcao1y{i},l(i,:));
    plot(gr3y,ang{i}(:,2),desvbpm{i}(:,2) - correcao2y{i} - correcao3y{i},l(i,:));
    %text(ang{i}(:,2),desvbpm{i}(:,2) - correcao2y{i} - correcao3y{i},int2str(text_bpm{1}));
    %text(ang{i}(:,2),desvbpm{i}(:,2) - correcao2y{i} - correcao3y{i},int2str(text_quadru{1}));
end

%cria os espaços para os gráficos da terceira figura
figure('NumberTitle', 'off', 'Name', ['Máquina ' num2str(m) '_' num2str(recursao) 'r - Kscan']);
graf1 = subplot(3,2,1);
graf2 = subplot(3,2,2);
graf3 = subplot(3,2,3);
graf4 = subplot(3,2,4);
graf5 = subplot(3,2,5);
graf6 = subplot(3,2,6);
hold(graf1,'on');
hold(graf2,'on');
hold(graf3,'on');
hold(graf4,'on');
hold(graf5,'on');
hold(graf6,'on');
xlabel(graf1,'DeltaK no Quadrupolo (m-2)');
ylabel(graf1,'Desvio Horiz H-blue/ V-red/black (um)');
xlabel(graf2,'DeltaK no Quadrupolo (m-2)');
ylabel(graf2,'Desvio Vert H-blue/ V-red/black (um)');
xlabel(graf3,'InclinaçãoX (urad)');
ylabel(graf3,'DerivadaX (um/m-2)');
xlabel(graf4,'InclinaçãoY (urad)');
ylabel(graf4,'DerivadaY (um/m-2)');
xlabel(graf5,'CenterX (um)');
ylabel(graf5,'DerivadaX (um/m-2)');
xlabel(graf6,'CenterY (um)');
ylabel(graf6,'DerivadaY (um/m-2)');

iQuadrux = {};
iQuadruy = {};
cQuadrux = {};
cQuadruy = {};
dervX = {};
dervY = {};
for i=1:3
    iQuadrux{i} = [];
    iQuadruy{i} = [];
    cQuadrux{i} = [];
    cQuadruy{i} = [];
    dervX{i} = [];
    dervY{i} = [];
end

%for i=1:length(alist_bpm)
for i=1:length(alist_bpm)
    bpm = alist_bpm(i);
    quadru = alist_quadru(i);
    is_skew = isSkew(family_data,quadru);
    is_sextupole = isSextupole(family_data,quadru);
    
    %Abre os arquivos das simulações neste bpm
    string = [caminho_arquivos folder '/' 'M' num2str(m) '_' num2str(recursao) 'r' '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' 'data.mat'];
    load(string);
    
    %Seta a escola dos dados (um)
	pot = 1e6;
    Kresult = data.Kresult;
    Ks = Kresult.Ks;
    meritfunctionKx = Kresult.meritfunctionKx*pot;
    meritfunctionKy = Kresult.meritfunctionKy*pot;
    derivadaX = Kresult.derivadaX*pot;
    derivadaY = Kresult.derivadaY*pot;
    centerQuadrux = Kresult.centerQuadrux*pot;
    centerQuadruy = Kresult.centerQuadruy*pot;
    inclQuadrux = Kresult.inclQuadrux*pot;
    inclQuadruy = Kresult.inclQuadruy*pot;
    
    %Escolhe o indice correto para cada quadrupolo
    index = 1;
    if(is_skew == true)
        index = index + 1;
        if(is_sextupole == true)
            index = index + 1;
        end
    end
    
    cQuadrux{index} = [cQuadrux{index}; centerQuadrux - pot*ring{quadru}.T2(1)];
    cQuadruy{index} = [cQuadruy{index}; centerQuadruy - pot*ring{quadru}.T2(3)];
    iQuadrux{index} = [iQuadrux{index}; inclQuadrux];
    iQuadruy{index} = [iQuadruy{index}; inclQuadruy];
    dervX{index} = [dervX{index}; derivadaX];
    dervY{index} = [dervY{index}; derivadaY];
    
    %Plota os gráficos das funções de méritoK
    if(is_skew == true)
        if(is_sextupole == true)
            plot(graf1,Ks,meritfunctionKx,'k');
            plot(graf2,Ks,meritfunctionKy,'k');
        else
           plot(graf1,Ks,meritfunctionKx,'r');
           plot(graf2,Ks,meritfunctionKy,'r');
        end
    else
        plot(graf1,Ks,meritfunctionKx,'b');
        plot(graf2,Ks,meritfunctionKy,'b');
    end

end

for i=1:3
    plot(graf3,iQuadrux{i},dervX{i},l(i,:));
    plot(graf4,iQuadruy{i},dervY{i},l(i,:));
    plot(graf5,cQuadrux{i},dervX{i},l(i,:));
    plot(graf6,cQuadruy{i},dervY{i},l(i,:));
end

%{
figure;
ax = subplot(1,1,1);
hold(ax,'on')
xlabel(ax,'posição no anel - s (m)','FontSize',28);
ylabel(ax,'distância entre feixe e centro magnético (um)','FontSize',28);
%ylabel(ax,'erro de BBA (um)','FontSize',28);
ax.FontSize = 28;
for i = 1:3
    listAuxX = list_desv{i}(:,1) - correcao1x{i} - correcao2x{i} - correcao3x{i};
    %listAuxX = list_desv{i}(:,1) - correcao1x{i};
    listAuxY = list_desv{i}(:,2) - correcao1y{i} - correcao2y{i} - correcao3y{i};
    %listAuxY = list_desv{i}(:,2) - correcao1y{i};
    values = listAuxX.*listAuxX + listAuxY.*listAuxY;
    values = sqrt(values);
    plot(ax, findsposOff(ring,list_quadru{i}), values, [l(i,:) '-'], 'linewidth', 3);
    
    med = 0;
    for j=1:length(values)
        med = med + values(j);
    end
    med = med/length(values);
    %fprintf('%d\n', med);
end
legend(ax,{'Quadrupolo','QS','Sextupolo + QS'});
%}