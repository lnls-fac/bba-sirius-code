caminho_arquivos = '../bba-sirius-data/';
folder = 'plusK';

%configuracoes do arquivo a ser carregado
recursao = 1;
range = 10;
random_error = false;
interp_num = 1000000;
corrigir = true;
corrigir_ang = false;

t0 = datenum(datetime('now'));
string = [caminho_arquivos folder '/' 'Media' '_' num2str(recursao) 'r' '_' num2str(range) '_' num2str(random_error) '_' num2str(interp_num) '_' num2str(corrigir) '_' num2str(corrigir_ang) '_' 'data.mat'];
load(string);

string = [caminho_arquivos folder '/' 'Sigma' '_' num2str(recursao) 'r' '_' num2str(range) '_' num2str(random_error) '_' num2str(interp_num) '_' num2str(corrigir) '_' num2str(corrigir_ang) '_' 'data.mat'];
load(string);

text_bpm = {};
text_quadru = {};
listbpm = {};
listquadru = {};
cte = {};
for i=1:3
    text_bpm{i} = [];
    text_quadru{i} = [];
    listbpm{i} = [];
    listquadru{i} = [];
    cte{i} = [];
end
for i=1:length(alist_bpm)
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
    
    L = the_ring{quadru}.Length;
    if(bpm > quadru)
        D = findsposOff(the_ring,bpm) - findsposOff(the_ring,quadru) - L;
    else
        D = findsposOff(the_ring,quadru) - findsposOff(the_ring,bpm);
    end
    cte{index} = [cte{index}; 1/(L/2 + D)];
end
tf = datenum(datetime('now'));
fprintf('Tempo de Execução (s): %.2f\n', (tf-t0)*100000);

ring = the_ring;

%seta o formato dos pontos e cores nos gráficos
l2 = ['b'; 'r'; 'k'];
l = ['bo'; 'rs'; 'k*'];

size_num = 20;

%{
%Cria os espaços para os gráficos na segunda figura
if(corrigir == true)
    figure('NumberTitle', 'off', 'Name', [num2str(recursao) 'r - Gráficos Análise bbaX Corrigido']);
else
    figure('NumberTitle', 'off', 'Name', [num2str(recursao) 'r - Gráficos Análise bbaX']);
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
    plot(gr1x,findsposOff(ring,listquadru{i}),desvQuadruXm{i}(1,:) - correcao1xm{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(gr2x,desvQuadruXm{i}(1,:) - correcao1xm{i},desvQuadruXm{i}(3,:) - correcao1ym{i},l(i,:), 'linewidth', width_line);
    plot(gr3x,findsposOff(ring,listquadru{i}),desvBPMXm{i}(1,:) - correcao1xm{i} - correcao2xm{i} - correcao3x_Xm{i},[l(i,:) '-'], 'linewidth', width_line);
    
    plot(gr1y,findsposOff(ring,listquadru{i}),desvQuadruXm{i}(3,:) - correcao1ym{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(gr2y,desvBPMXm{i}(1,:) - correcao1xm{i} - correcao2xm{i} - correcao3x_Xm{i},desvBPMXm{i}(3,:) - correcao1ym{i} - correcao2ym{i} - correcao3y_Xm{i},l(i,:), 'linewidth', width_line);
    plot(gr3y,findsposOff(ring,listquadru{i}),desvBPMXm{i}(3,:) - correcao1ym{i} - correcao2ym{i} - correcao3y_Xm{i},[l(i,:) '-'], 'linewidth', width_line);
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
    figure('NumberTitle', 'off', 'Name', [num2str(recursao) 'r - Gráficos Análise bbaY Corrigido']);
else
    figure('NumberTitle', 'off', 'Name', [num2str(recursao) 'r - Gráficos Análise bbaY']);
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
    plot(gr1x,findsposOff(ring,listquadru{i}),desvQuadruYm{i}(1,:) - correcao1xm{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(gr2x,desvQuadruYm{i}(1,:) - correcao1xm{i},desvQuadruYm{i}(3,:) - correcao1ym{i},l(i,:), 'linewidth', width_line);
    plot(gr3x,findsposOff(ring,listquadru{i}),desvBPMYm{i}(1,:) - correcao1xm{i} - correcao2xm{i} - correcao3x_Ym{i},[l(i,:) '-'], 'linewidth', width_line);
    
    plot(gr1y,findsposOff(ring,listquadru{i}),desvQuadruYm{i}(3,:) - correcao1ym{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(gr2y,desvBPMYm{i}(1,:) - correcao1xm{i} - correcao2xm{i} - correcao3x_Ym{i},desvBPMYm{i}(3,:) - correcao1ym{i} - correcao2ym{i} - correcao3y_Ym{i},l(i,:), 'linewidth', width_line);
    plot(gr3y,findsposOff(ring,listquadru{i}),desvBPMYm{i}(3,:) - correcao1ym{i} - correcao2ym{i} - correcao3y_Ym{i},[l(i,:) '-'], 'linewidth', width_line);
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
    figure('NumberTitle', 'off', 'Name', [num2str(recursao) 'r - Gráficos Análise bbaXY Corrigido']);
else
    figure('NumberTitle', 'off', 'Name', [num2str(recursao) 'r - Gráficos Análise bbaXY']);
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
    plot(gr1x,findsposOff(ring,listquadru{i}),desvQuadruXm{i}(1,:) - correcao1xm{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(gr2x,desvQuadruXm{i}(1,:) - correcao1xm{i},desvQuadruYm{i}(3,:) - correcao1ym{i},l(i,:), 'linewidth', width_line);
    plot(gr3x,findsposOff(ring,listquadru{i}),desvBPMXm{i}(1,:) - correcao1xm{i} - correcao2xm{i} - correcao3x_Xm{i},[l(i,:) '-'], 'linewidth', width_line);
    
    plot(gr1y,findsposOff(ring,listquadru{i}),desvQuadruYm{i}(3,:) - correcao1ym{i},[l(i,:) '-'], 'linewidth', width_line);
    plot(gr2y,desvBPMXm{i}(1,:) - correcao1xm{i} - correcao2xm{i} - correcao3x_Xm{i},desvBPMYm{i}(3,:) - correcao1ym{i} - correcao2ym{i} - correcao3y_Ym{i},l(i,:), 'linewidth', width_line);
    plot(gr3y,findsposOff(ring,listquadru{i}),desvBPMYm{i}(3,:) - correcao1ym{i} - correcao2ym{i} - correcao3y_Ym{i},[l(i,:) '-'], 'linewidth', width_line);
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
    figure('NumberTitle', 'off', 'Name', [num2str(recursao) 'r - Gráficos Análise BBA Média e Sigma Corrigido']);
else
    figure('NumberTitle', 'off', 'Name', [num2str(recursao) 'r - Gráficos Análise BBA Média e Sigma']);
end
medx = subplot(2,2,1);
medy = subplot(2,2,2);
sigmx = subplot(2,2,3);
sigmy = subplot(2,2,4);
medx.FontSize = size_num;
medy.FontSize = size_num;
sigmx.FontSize = size_num;
sigmy.FontSize = size_num;
hold(medx,'on');
hold(medy,'on');
hold(sigmx,'on');
hold(sigmy,'on');
xlabel(medx,'posicao - s (m)','FontSize',size_num);
ylabel(medx,'X: Dist Média BPM-CM (um)','FontSize',size_num);
xlabel(medy,'posicao - s (m)','FontSize',size_num);
ylabel(medy,'Y: Dist Média BPM-CM (um)','FontSize',size_num);
xlabel(sigmx,'posicao - s (m)','FontSize',size_num);
ylabel(sigmx,'X: Desvio Padrão Dist BPM-CM (um)','FontSize',size_num);
xlabel(sigmy,'posicao - s (m)','FontSize',size_num);
ylabel(sigmy,'Y: Desvio Padrão Dist BPM-CM (um)','FontSize',size_num);
for i=1:3
    width_line = 2;
    plot(medx,findsposOff(ring,listquadru{i}), abs(desvBPMXm{i}(1,:) - correcao1xm{i} - correcao2xm{i} - correcao3x_Xm{i}),[l(i,:) '-'], 'linewidth', width_line);
    plot(sigmx,findsposOff(ring,listquadru{i}),sigmaX{i},[l(i,:) '-'], 'linewidth', width_line);
    %sigmaX{i}.*transpose(cte{i})
    
    plot(medy,findsposOff(ring,listquadru{i}),abs(desvBPMYm{i}(3,:) - correcao1ym{i} - correcao2ym{i} - correcao3y_Ym{i}),[l(i,:) '-'], 'linewidth', width_line);
    plot(sigmy,findsposOff(ring,listquadru{i}),sigmaY{i},[l(i,:) '-'], 'linewidth', width_line);
    %text(findsposOff(ring,listquadru{i}),desvBPMX{i}(3,:),int2str(text_bpm{i}));
    %text(findsposOff(ring,listquadru{i}),desvBPMX{i}(3,:) - correcao1y{i} - correcao2y{i} - correcao3y{i},int2str(text_quadru{i}));
end
legend(medx,{'Quadrupolo','QS','Sextupolo + QS'});
legend(medy,{'Quadrupolo','QS','Sextupolo + QS'});
legend(sigmx,{'Quadrupolo','QS','Sextupolo + QS'});
legend(sigmy,{'Quadrupolo','QS','Sextupolo + QS'});
line(sigmx, [0 600],[10 10],'LineWidth',3);
line(sigmy, [0 600],[10 10],'LineWidth',3);


figure('NumberTitle', 'off', 'Name', ['teste']);
test = subplot(1,1,1);
hold(test,'on');
for i=1:3
    %plot((1/sqrt(twi.betax(listquadru{i}))).*sqrt(1 + (1/4)*twi.alphax(listquadru{i}).*twi.alphax(listquadru{i})) + twi.etaxl(listquadru{i}), sigmaX{i}.*transpose(cte{i}), l(i,:));
    %plot(abs(twi.etax(listquadru{i})), sigmaX{i}.*transpose(cte{i}), l(i,:));
    %plot((1/sqrt(twi.betay(listquadru{i}))).*sqrt(1 + (1/4)*twi.alphay(listquadru{i}).*twi.alphay(listquadru{i})), sigmaY{i}.*transpose(cte{i}), l(i,:));
    %plot(twi.alphax(listquadru{i}), (sigmaX{i}.*transpose(cte{i})).*transpose(sqrt(twi.betax(listquadru{i}))), l(i,:));
    %plot(sqrt(twi.betay(listquadru{i})), sigmaY{i}.*transpose(cte{i}), l(i,:));
    plot(1./sqrt(twi.betax(listquadru{i})), sigmaX{i}.*transpose(cte{i}), l(i,:));
    plot(twi.alphax(listquadru{i}), sigmaX{i}.*transpose(cte{i}), l(i,:));
end
