caminho_arquivos = '../bba-sirius-data/';
folder = 'sext2';

%configuracoes do arquivo a ser carregado
m = 1;
recursao = 0;
range = 11;
random_error = true;
interp_num = 1000000;

%configura se usará as expressões teóricas de correção
corrigir = true; 
corrigir_ang = false;

%totalBPM = length(alist_bpm);
totalBPM = length(alist_bpm);

string = [caminho_arquivos folder '/' 'Graficos' '_' 'M' num2str(m) '_' num2str(recursao) 'r' '_' num2str(range) '_' num2str(random_error) '_' num2str(interp_num) '_' 'data.mat'];
load(string);

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
listbpm = {};
listquadru = {};

if(corrigir == false)
    correcao1x = {};
    correcao2x = {};
    correcao1y = {};
    correcao2y = {};
    correcao3x_X = {};
    correcao3y_X = {};
    correcao3x_Y = {};
    correcao3y_Y = {};
end
if(corrigir_ang == false)
    correcao3x_X = {};
    correcao3y_X = {};
    correcao3x_Y = {};
    correcao3y_Y = {};
end

for i=1:3
    text_bpm{i} = [];
    text_quadru{i} = [];
    listbpm{i} = [];
    listquadru{i} = [];
    if(corrigir == false)
        correcao1x{i} = [];
        correcao2x{i} = [];
        correcao1y{i} = [];
        correcao2y{i} = [];
        correcao3x_X{i} = [];
        correcao3y_X{i} = [];
        correcao3x_Y{i} = [];
        correcao3y_Y{i} = [];
    end
    if(corrigir_ang == false)
        correcao3x_X{i} = [];
        correcao3y_X{i} = [];
        correcao3x_Y{i} = [];
        correcao3y_Y{i} = [];
    end
end

t0 = datenum(datetime('now'));
for i=1:totalBPM
    bpm = alist_bpm(i);
    quadru = alist_quadru(i);
    is_skew = isSkew(family_data,quadru);
    is_sextupole = isSextupole(family_data,quadru);
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
	listbpm{index} = [listbpm{index}; bpm];
	listquadru{index} = [listquadru{index}; quadru];
    if(corrigir == false)
        correcao1x{index} = [correcao1x{index}, 0];
        correcao1y{index} = [correcao1y{index}, 0];
        correcao2x{index} = [correcao2x{index}, 0];
        correcao2y{index} = [correcao2y{index}, 0];
        correcao3x_X{index} = [correcao3x_X{index}, 0];
        correcao3y_X{index} = [correcao3y_X{index}, 0];
        correcao3x_Y{index} = [correcao3x_Y{index}, 0];
        correcao3y_Y{index} = [correcao3y_Y{index}, 0];
    end
    if(corrigir_ang == false && corrigir == true)
        correcao3x_X{index} = [correcao3x_X{index}, 0];
        correcao3y_X{index} = [correcao3y_X{index}, 0];
        correcao3x_Y{index} = [correcao3x_Y{index}, 0];
        correcao3y_Y{index} = [correcao3y_Y{index}, 0];
    end
end
tf = datenum(datetime('now'));
fprintf('Tempo de Execução (s): %.2f\n', (tf-t0)*100000);

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
    plot(ax3,findsposOff(ring,listquadru{i}),functionMinX{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(ax4,findsposOff(ring,listquadru{i}),functionMinY{i},[l(i,:) '-'], 'linewidth', width_line);
end
legend(ax1,{'Quadrupolo','QS','Sextupolo + QS'});
legend(ax2,{'Quadrupolo','QS','Sextupolo + QS'});
legend(ax3,{'Quadrupolo','QS','Sextupolo + QS'});
legend(ax4,{'Quadrupolo','QS','Sextupolo + QS'});

%{

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
    plot(gr1x,findsposOff(ring,listquadru{i}),desvQuadruX{i}(1,:) - correcao1x{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(gr2x,desvQuadruX{i}(1,:) - correcao1x{i},desvQuadruX{i}(3,:) - correcao1y{i},l(i,:), 'linewidth', width_line);
    plot(gr3x,findsposOff(ring,listquadru{i}),desvBPMX{i}(1,:) - correcao1x{i} - correcao2x{i} - correcao3x_X{i},[l(i,:) '-'], 'linewidth', width_line);
    
    plot(gr1y,findsposOff(ring,listquadru{i}),desvQuadruX{i}(3,:) - correcao1y{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(gr2y,desvBPMX{i}(1,:) - correcao1x{i} - correcao2x{i} - correcao3x_X{i},desvBPMX{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y_X{i},l(i,:), 'linewidth', width_line);
    plot(gr3y,findsposOff(ring,listquadru{i}),desvBPMX{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y_X{i},[l(i,:) '-'], 'linewidth', width_line);
    %text(findsposOff(ring,listquadru{i}),desvBPMX{i}(3,:),int2str(text_bpm{i}));
    %text(findsposOff(ring,listquadru{i}),desvBPMX{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y{i},int2str(text_quadru{i}));
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
    plot(gr1x,findsposOff(ring,listquadru{i}),desvQuadruY{i}(1,:) - correcao1x{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(gr2x,desvQuadruY{i}(1,:) - correcao1x{i},desvQuadruY{i}(3,:) - correcao1y{i},l(i,:), 'linewidth', width_line);
    plot(gr3x,findsposOff(ring,listquadru{i}),desvBPMY{i}(1,:) - correcao1x{i} - correcao2x{i} - correcao3x_Y{i},[l(i,:) '-'], 'linewidth', width_line);
    
    plot(gr1y,findsposOff(ring,listquadru{i}),desvQuadruY{i}(3,:) - correcao1y{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(gr2y,desvBPMY{i}(1,:) - correcao1x{i} - correcao2x{i} - correcao3x_Y{i},desvBPMY{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y_Y{i},l(i,:), 'linewidth', width_line);
    plot(gr3y,findsposOff(ring,listquadru{i}),desvBPMY{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y_Y{i},[l(i,:) '-'], 'linewidth', width_line);
    %text(findsposOff(ring,listquadru{i}),desvBPMX{i}(3,:),int2str(text_bpm{i}));
    %text(findsposOff(ring,listquadru{i}),desvBPMX{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y{i},int2str(text_quadru{i}));
end
legend(gr1x,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr2x,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr3x,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr1y,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr2y,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr3y,{'Quadrupolo','QS','Sextupolo + QS'});

%}

%{
%Cria os espaços para os gráficos na terceira figura
if(corrigir == true)
    figure('NumberTitle', 'off', 'Name', ['Máquina ' num2str(m) '_' num2str(recursao) 'r - Gráficos Análise bbaXY Corrigido']);
else
    figure('NumberTitle', 'off', 'Name', ['Máquina ' num2str(m) '_' num2str(recursao) 'r - Gráficos Análise bbaXY']);
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
    plot(gr1x,findsposOff(ring,listquadru{i}),desvQuadruX{i}(1,:) - correcao1x{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(gr2x,desvQuadruX{i}(1,:) - correcao1x{i},desvQuadruY{i}(3,:) - correcao1y{i},l(i,:), 'linewidth', width_line);
    plot(gr3x,findsposOff(ring,listquadru{i}),desvBPMX{i}(1,:) - correcao1x{i} - correcao2x{i} - correcao3x_X{i},[l(i,:) '-'], 'linewidth', width_line);
    
    plot(gr1y,findsposOff(ring,listquadru{i}),desvQuadruY{i}(3,:) - correcao1y{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(gr2y,desvBPMX{i}(1,:) - correcao1x{i} - correcao2x{i} - correcao3x_X{i},desvBPMY{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y_Y{i},l(i,:), 'linewidth', width_line);
    plot(gr3y,findsposOff(ring,listquadru{i}),desvBPMY{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y_Y{i},[l(i,:) '-'], 'linewidth', width_line);
    %text(findsposOff(ring,listquadru{i}),desvBPMX{i}(3,:),int2str(text_bpm{i}));
    %text(findsposOff(ring,listquadru{i}),desvBPMX{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y{i},int2str(text_quadru{i}));
end
legend(gr1x,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr2x,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr3x,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr1y,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr2y,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr3y,{'Quadrupolo','QS','Sextupolo + QS'});
%}

%Cria os espaços para os gráficos na terceira figura
if(corrigir == true)
    figure('NumberTitle', 'off', 'Name', ['Máquina ' num2str(m) '_' num2str(recursao) 'r - Gráficos Análise bbaXY Corrigido Regr']);
else
    figure('NumberTitle', 'off', 'Name', ['Máquina ' num2str(m) '_' num2str(recursao) 'r - Gráficos Análise bbaXY Regr']);
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
    plot(gr1x,findsposOff(ring,listquadru{i}),desvQuadruX2{i}(1,:) - correcao1x{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(gr2x,desvQuadruX2{i}(1,:) - correcao1x{i},desvQuadruY2{i}(3,:) - correcao1y{i},l(i,:), 'linewidth', width_line);
    text(gr2x, desvQuadruX2{i}(1,:) - correcao1x{i},desvQuadruY2{i}(3,:) - correcao1y{i},int2str(text_bpm{i}));
    plot(gr3x,findsposOff(ring,listquadru{i}),desvBPMX2{i}(1,:) - correcao1x{i} - correcao2x{i} - correcao3x_X{i},[l(i,:) '-'], 'linewidth', width_line);
    
    plot(gr1y,findsposOff(ring,listquadru{i}),desvQuadruY2{i}(3,:) - correcao1y{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(gr2y,desvBPMX2{i}(1,:) - correcao1x{i} - correcao2x{i} - correcao3x_X{i},desvBPMY2{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y_Y{i},l(i,:), 'linewidth', width_line);
    plot(gr3y,findsposOff(ring,listquadru{i}),desvBPMY2{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y_Y{i},[l(i,:) '-'], 'linewidth', width_line);
    %text(findsposOff(ring,listquadru{i}),desvBPMX{i}(3,:),int2str(text_bpm{i}));
    %text(findsposOff(ring,listquadru{i}),desvBPMX{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y_Y{i},int2str(text_quadru{i}));
end
legend(gr1x,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr2x,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr3x,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr1y,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr2y,{'Quadrupolo','QS','Sextupolo + QS'});
legend(gr3y,{'Quadrupolo','QS','Sextupolo + QS'});

if strcmp(folder,'plusK') || strcmp(folder,'plusKt')
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
    for i=1:1
        plot(graf1,Ks{i},meritfunctionKx{i},l2(i,:));
        plot(graf2,Ks{i},meritfunctionKy{i},l2(i,:));
        plot(graf3,iQuadrux{i},dervX{i},l(i,:));
        plot(graf4,iQuadruy{i},dervY{i},l(i,:));
        plot(graf5,cQuadrux{i},dervX{i},l(i,:));
        plot(graf6,cQuadruy{i},dervY{i},l(i,:));
    end
end

if strcmp(folder,'sext') || strcmp(folder,'sextt') || strcmp(folder,'sextder')
    %Cria os espaços para os gráficos na terceira figura
    if(corrigir == true)
        figure('NumberTitle', 'off', 'Name', ['Máquina ' num2str(m) '_' num2str(recursao) 'r - Gráficos Análise bbaXY Corrigido TUNE']);
    else
        figure('NumberTitle', 'off', 'Name', ['Máquina ' num2str(m) '_' num2str(recursao) 'r - Gráficos Análise bbaXY TUNE']);
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
    for i=3:3
        width_line = 2;
        plot(gr1x,findsposOff(ring,listquadru{i}),desvQuadruXtune{i}(1,:) - correcao1x{i},[l(i,:) '-'], 'linewidth', width_line);
        plot(gr2x,desvQuadruXtune{i}(1,:) - correcao1x{i},desvQuadruYtune{i}(3,:) - correcao1y{i},l(i,:), 'linewidth', width_line);
        plot(gr3x,findsposOff(ring,listquadru{i}),desvBPMXtune{i}(1,:) - correcao1x{i} - correcao2x{i} - correcao3x_X{i},[l(i,:) '-'], 'linewidth', width_line);

        plot(gr1y,findsposOff(ring,listquadru{i}),desvQuadruYtune{i}(3,:) - correcao1y{i},[l(i,:) '-'], 'linewidth', width_line);
        plot(gr2y,desvBPMXtune{i}(1,:) - correcao1x{i} - correcao2x{i} - correcao3x_X{i},desvBPMYtune{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y_Y{i},l(i,:), 'linewidth', width_line);
        plot(gr3y,findsposOff(ring,listquadru{i}),desvBPMYtune{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y_Y{i},[l(i,:) '-'], 'linewidth', width_line);
        %text(findsposOff(ring,listquadru{i}),desvBPMX{i}(3,:),int2str(text_bpm{i}));
        %text(findsposOff(ring,listquadru{i}),desvBPMX{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y{i},int2str(text_quadru{i}));
    end
end