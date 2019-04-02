caminho_arquivos = '../bba-sirius-data/';
folder = 'gridsext';

%configuracoes do arquivo a ser carregado
range = 10;
random_error = false;
m = 1;
recursao = 0;

%carrega o anel correspondente
if(m==0)
	ring = the_ring;
else
	ring = machine{m};
end

%for i=1:length(alist_bpm)
for i=1:1
    t0 = datenum(datetime('now'));
    bpm = alist_bpm(i);
    quadru = alist_quadru(i);
    is_skew = isSkew(family_data,quadru);
    is_sextupole = isSextupole(family_data,quadru);
    
    %Abre os arquivos das simulações neste bpm
    string = [caminho_arquivos folder '/' 'M' num2str(m) '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' 'data.mat'];
    load(string);
    
    %cria os espaços para os gráficos da primeira figura
    figure('NumberTitle', 'off', 'Name', ['Máquina ' num2str(m) '_' num2str(recursao) 'r - Desvios']);
    ax1 = subplot(1,1,1);
    hold(ax1,'on');
    xlabel(ax1,'xQuadru (um)');
    ylabel(ax1,'yQuadru (um)');
    zlabel(ax1, 'Desvio (m^2)');

    %colormap(gray)
    colormap(flipud(gray(256)));
    
    %Seta a escala dos dados (um)
	pot = 1e6;
    Vq = data.BBAanalyse.Vq*pot;
    Xq = data.BBAanalyse.Xq*pot;
    Yq = data.BBAanalyse.Yq*pot;
    Xb = data.BBAanalyse.Xb*pot;
    Yb = data.BBAanalyse.Yb*pot;
    xReal = data.BBAanalyse.xReal*pot;
    yReal = data.BBAanalyse.yReal*pot;
    xMinQuadru = data.BBAanalyse.xMinQuadru*pot;
    yMinQuadru = data.BBAanalyse.yMinQuadru*pot;
    xMinBPM = data.BBAanalyse.xMinQuadru*pot;
    yMinBPM = data.BBAanalyse.yMinQuadru*pot;
    
    %surf(xQuadru,yQuadru,func);
    %surf(xQuadru,yQuadru,F(xQuadru,yQuadru));
    %contourf(xQuadru,yQuadru,func);
    contourf(Xq, Yq, Vq);
    plot(xMinQuadru,yMinQuadru,'b*');
    plot(xReal,yReal,'ro');
    plot(xMinBPM,yMinBPM,'bs');
    
    tf = datenum(datetime('now'));
    fprintf('Tempo de Execução (s): %.2f\n', (tf-t0)*100000);
end