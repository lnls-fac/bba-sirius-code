caminho_arquivos = '../bba-sirius-data/';
folder = 'plusK';

%configuracoes do arquivo a ser carregado
m = 1;
range = 10;
random_error = false;
recursao = 0;

pot = 1e6; % seta a escola dos dados (um)
corrigir = false; % configura se usará as expressões teóricas de correção

%carrega o anel correspondente
if(m==0)
	ring = the_ring;
else
	ring = machine{m};
end

%seta o formato dos pontos e cores nos gráficos
l2 = ['b'; 'r'; 'k'];
l = ['bo'; 'rs'; 'k*'];

%inicializa as variáveis necessárias
text_bpm = {};
text_quadru = {};
list_bpm = {};
list_quadru = {};

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

correcao1x = {};
correcao2x = {};
correcao1y = {};
correcao2y = {};
correcao3x = {};
correcao3y = {};

for i=1:3
    text_bpm{i} = [];
    text_quadru{i} = [];
    list_bpm{i} = [];
    list_quadru{i} = [];
    
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
    
    correcao1x{i} = [];
    correcao2x{i} = [];
    correcao1y{i} = [];
    correcao2y{i} = [];
    correcao3x{i} = [];
    correcao3y{i} = [];
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
    
    %Escolhe o indice correto para cada quadrupolo
    index = 1;
    if(is_skew == true)
        index = index + 1;
        if(is_sextupole == true)
            index = index + 1;
        end
    end
    
    text_bpm{index} = [text_bpm{index}; bpm];
    text_quadru{index} = [text_quadru{index}; quadru];
	list_bpm{index} = [list_bpm{index}; bpm];
	list_quadru{index} = [list_quadru{index}; quadru];
    
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
    
    posCenterQuadru = [pot*ring{quadru}.T2(1); pot*ring{quadru}.T2(2); pot*ring{quadru}.T2(3); pot*ring{quadru}.T2(4); 0; 0];
    
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
        %x0l = data.BBAanalyseX.posQuadruMin(2)*pot;
        %y0l = data.BBAanalyseX.posQuadruMin(4)*pot;
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
        correcao1x{index} = [correcao1x{index}, pot*x0];
        correcao1y{index} = [correcao1y{index}, pot*y0];
        correcao2x{index} = [correcao2x{index}, pot*((1/8)*(-Gy)*L*L + (1/8)*x0*(-K)*L*L + (Gy*L*L)*(K*L*L)/(12*32)) + sign(bpm-quadru)*(x0l*L/2)*(1 + (-K)*L*L/24)];
        correcao2y{index} = [correcao2y{index}, pot*((1/8)*(Gx)*L*L + (1/8)*y0*(K)*L*L + (Gx*L*L)*(K*L*L)/(12*32)) + sign(bpm-quadru)*(y0l*L/2)*(1 + (K)*L*L/24)];
        correcao3x{index} = [correcao3x{index}, pot*(D/2)*((-Gy)*L + x0*(-K)*L + ((-Gy)*L*L)*((-K)*L)/24) + sign(bpm-quadru)*x0l*D*(1 + (-K)*L*L/8)];
        correcao3y{index} = [correcao3y{index}, pot*(D/2)*((Gx)*L + y0*(K)*L + ((Gx)*L*L)*((K)*L)/24) + sign(bpm-quadru)*y0l*D*(1 + (K)*L*L/8)];
    else
        correcao1x{index} = [correcao1x{index}, 0];
        correcao1y{index} = [correcao1y{index}, 0];
        correcao2x{index} = [correcao2x{index}, 0];
        correcao2y{index} = [correcao2y{index}, 0];
        correcao3x{index} = [correcao3x{index}, 0];
        correcao3y{index} = [correcao3y{index}, 0];
    end

end

%cria os espaços para os gráficos da primeira figura
size_num = 20;
figure('NumberTitle', 'off', 'Name', ['Máquina ' num2str(m) '_' num2str(recursao) 'r - Desvios']);
ax1 = subplot(2,2,1);
ax2 = subplot(2,2,2);
ax3 = subplot(2,2,3);
ax4 = subplot(2,2,4);
ax1.FontSize = size_num;
ax2.FontSize = size_num;
ax3.FontSize = size_num;
ax4.FontSize = size_num;
hold(ax1,'on');
hold(ax2,'on');
hold(ax3,'on');
hold(ax4,'on');
xlabel(ax1,'Kick Horizontal (urad)','FontSize',size_num);
ylabel(ax1,'Distorção de órbita (um^2)','FontSize',size_num);
xlabel(ax2,'Kick Vertical (urad)','FontSize',size_num);
ylabel(ax2,'Distorção de órbita (um^2)','FontSize',size_num);
xlabel(ax3,'Posicao do Quadru (m)','FontSize',size_num);
ylabel(ax3,'Desvio Mínimo - Horz (um^2)','FontSize',size_num);
xlabel(ax4,'Posicao do Quadru (m)','FontSize',size_num);
ylabel(ax4,'Desvio Mínimo - Vert (um^2)','FontSize',size_num);
for i=1:3
    width_line = 2;
    plot(ax1,kicksX{i},meritfunctionX{i},l2(i,:), 'linewidth', width_line);
    plot(ax2,kicksY{i},meritfunctionY{i},l2(i,:), 'linewidth', width_line);
    plot(ax3,findsposOff(ring,list_quadru{i}),functionMinX{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(ax4,findsposOff(ring,list_quadru{i}),functionMinY{i},[l(i,:) '-'], 'linewidth', width_line);
end
%legend(ax1,{'Quadrupolo','QS','Sextupolo + QS'});
%legend(ax2,{'Quadrupolo','QS','Sextupolo + QS'});
legend(ax3,{'Quadrupolo','QS','Sextupolo + QS'});
legend(ax4,{'Quadrupolo','QS','Sextupolo + QS'});

%Cria os espaços para os gráficos na segunda figura
if(corrigir == true)
    figure('NumberTitle', 'off', 'Name', ['Máquina ' num2str(m) '_' num2str(recursao) 'r - Gráficos Análise bbaX Corrigido']);
else
    figure('NumberTitle', 'off', 'Name', ['Máquina ' num2str(m) '_' num2str(recursao) 'r - Gráficos Análise bbaX']);
end
gr1x = subplot(2,3,1);
gr2x = subplot(2,3,2);
gr3x = subplot(2,3,3);
gr1y = subplot(2,3,4);
gr2y = subplot(2,3,5);
gr3y = subplot(2,3,6);
gr1x.FontSize = size_num;
gr2x.FontSize = size_num;
gr3x.FontSize = size_num;
gr1y.FontSize = size_num;
gr2y.FontSize = size_num;
gr3y.FontSize = size_num;
hold(gr1x,'on');
hold(gr2x,'on');
hold(gr3x,'on');
hold(gr1y,'on');
hold(gr2y,'on');
hold(gr3y,'on');
xlabel(gr1x,'posicao - s (m)','FontSize',size_num);
ylabel(gr1x,'X: Dist Feixe e CM (um)','FontSize',size_num);
xlabel(gr2x,'x Feixe-CM (um)','FontSize',size_num);
ylabel(gr2x,'y Feixe-CM (um)','FontSize',size_num);
xlabel(gr3x,'posicao - s (m)','FontSize',size_num);
ylabel(gr3x,'X: Dist BPM e CM (um)','FontSize',size_num);
xlabel(gr1y,'posicao - s (m)');
ylabel(gr1y,'Y: Dist Feixe e CM (um)','FontSize',size_num);
xlabel(gr2y,'x BPM-CM (um)','FontSize',size_num);
ylabel(gr2y,'y BPM-CM  (um)','FontSize',size_num);
xlabel(gr3y,'posicao - s (m)','FontSize',size_num);
ylabel(gr3y,'Y: Dist BPM e CM (um)','FontSize',size_num);
for i=1:3
    width_line = 2;
    plot(gr1x,findsposOff(ring,list_quadru{i}),desvQuadruX{i}(1,:) - correcao1x{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(gr2x,desvQuadruX{i}(1,:) - correcao1x{i},desvQuadruX{i}(3,:) - correcao1y{i},l(i,:), 'linewidth', width_line);
    plot(gr3x,findsposOff(ring,list_quadru{i}),desvBPMX{i}(1,:) - correcao1x{i} - correcao2x{i} - correcao3x{i},[l(i,:) '-'], 'linewidth', width_line);
    
    plot(gr1y,findsposOff(ring,list_quadru{i}),desvQuadruX{i}(3,:) - correcao1y{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(gr2y,desvBPMX{i}(1,:) - correcao1x{i} - correcao2x{i} - correcao3x{i},desvBPMX{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y{i},l(i,:), 'linewidth', width_line);
    plot(gr3y,findsposOff(ring,list_quadru{i}),desvBPMX{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y{i},[l(i,:) '-'], 'linewidth', width_line);
    %text(findsposOff(ring,list_quadru{i}),desvBPMX{i}(3,:),int2str(text_bpm{i}));
    %text(findsposOff(ring,list_quadru{i}),desvBPMX{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y{i},int2str(text_quadru{i}));
end
legend(gr1x,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr2x,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr3x,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr1y,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr2y,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr3y,{'Quadrupolo','QS','Sextupolo + QS'});

%Cria os espaços para os gráficos na terceira figura
if(corrigir == true)
    figure('NumberTitle', 'off', 'Name', ['Máquina ' num2str(m) '_' num2str(recursao) 'r - Gráficos Análise bbaY Corrigido']);
else
    figure('NumberTitle', 'off', 'Name', ['Máquina ' num2str(m) '_' num2str(recursao) 'r - Gráficos Análise bbaY']);
end
gr1x = subplot(2,3,1);
gr2x = subplot(2,3,2);
gr3x = subplot(2,3,3);
gr1y = subplot(2,3,4);
gr2y = subplot(2,3,5);
gr3y = subplot(2,3,6);
gr1x.FontSize = size_num;
gr2x.FontSize = size_num;
gr3x.FontSize = size_num;
gr1y.FontSize = size_num;
gr2y.FontSize = size_num;
gr3y.FontSize = size_num;
hold(gr1x,'on');
hold(gr2x,'on');
hold(gr3x,'on');
hold(gr1y,'on');
hold(gr2y,'on');
hold(gr3y,'on');
xlabel(gr1x,'posicao - s (m)','FontSize',size_num);
ylabel(gr1x,'X: Dist Feixe e CM (um)','FontSize',size_num);
xlabel(gr2x,'x Feixe-CM (um)','FontSize',size_num);
ylabel(gr2x,'y Feixe-CM (um)','FontSize',size_num);
xlabel(gr3x,'posicao - s (m)','FontSize',size_num);
ylabel(gr3x,'X: Dist BPM e CM (um)','FontSize',size_num);
xlabel(gr1y,'posicao - s (m)');
ylabel(gr1y,'Y: Dist Feixe e CM (um)','FontSize',size_num);
xlabel(gr2y,'x BPM-CM (um)','FontSize',size_num);
ylabel(gr2y,'y BPM-CM  (um)','FontSize',size_num);
xlabel(gr3y,'posicao - s (m)','FontSize',size_num);
ylabel(gr3y,'Y: Dist BPM e CM (um)','FontSize',size_num);
for i=1:3
    width_line = 2;
    plot(gr1x,findsposOff(ring,list_quadru{i}),desvQuadruY{i}(1,:) - correcao1x{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(gr2x,desvQuadruY{i}(1,:) - correcao1x{i},desvQuadruY{i}(3,:) - correcao1y{i},l(i,:), 'linewidth', width_line);
    plot(gr3x,findsposOff(ring,list_quadru{i}),desvBPMY{i}(1,:) - correcao1x{i} - correcao2x{i} - correcao3x{i},[l(i,:) '-'], 'linewidth', width_line);
    
    plot(gr1y,findsposOff(ring,list_quadru{i}),desvQuadruY{i}(3,:) - correcao1y{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(gr2y,desvBPMY{i}(1,:) - correcao1x{i} - correcao2x{i} - correcao3x{i},desvBPMY{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y{i},l(i,:), 'linewidth', width_line);
    plot(gr3y,findsposOff(ring,list_quadru{i}),desvBPMY{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y{i},[l(i,:) '-'], 'linewidth', width_line);
    %text(findsposOff(ring,list_quadru{i}),desvBPMX{i}(3,:),int2str(text_bpm{i}));
    %text(findsposOff(ring,list_quadru{i}),desvBPMX{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y{i},int2str(text_quadru{i}));
end
legend(gr1x,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr2x,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr3x,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr1y,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr2y,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr3y,{'Quadrupolo','QS','Sextupolo + QS'});

%{

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

%}