caminho_arquivos = '../bba-sirius-data/';
folder = 'grid';

%configuracoes do arquivo a ser carregado
m = 1;
range = 10;
random_error = false;
steps_interp = 5000;

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
    
    kickx = data.kickx;
    kicky = data.kicky;
    func = data.func;
    xQuadru = data.xQuadru;
    yQuadru = data.yQuadru;
    xBPM = data.xBPM;
    yBPM = data.yBPM;
    
    [kX, kY] = meshgrid(min(kickx(1,:)):(max(kickx(1,:))-min(kickx(1,:)))/steps_interp:max(kickx(1,:)), min(kicky(:,1)):(max(kicky(:,1))-min(kicky(:,1)))/steps_interp:max(kicky(:,1)));
    Vq = interp2(kickx, kicky, func, kX, kY, 'spline');
    Xq = interp2(kickx, kicky, xQuadru, kX, kY, 'spline');
    Yq = interp2(kickx, kicky, yQuadru, kX, kY, 'spline');
    Xb = interp2(kickx, kicky, xBPM, kX, kY, 'spline');
    Yb = interp2(kickx, kicky, yBPM, kX, kY, 'spline');
    
    minMatrix = min(Vq(:));
    [row,col] = find(Vq == minMatrix);
    xMinQuadru = Xq(row,col);
    yMinQuadru = Yq(row,col);
    
    xReal = ring{quadru}.T2(1);
    yReal = ring{quadru}.T2(3);
    
    xMinBPM = Xb(row,col);
    yMinBPM = Yb(row,col);
    
    BBAanalyse = [];
    BBAanalyse.steps_interp = steps_interp;
    BBAanalyse.Vq = Vq;
    BBAanalyse.Xq = Xq;
    BBAanalyse.Yq = Yq;
    BBAanalyse.Xb = Xb;
    BBAanalyse.Yb = Yb;
    BBAanalyse.xMinQuadru = xMinQuadru;
    BBAanalyse.yMinQuadru = yMinQuadru;
    BBAanalyse.xMinBPM = xMinBPM;
    BBAanalyse.yMinBPM = yMinBPM;
    BBAanalyse.xReal = xReal;
    BBAanalyse.yReal = yReal;
    
    data.BBAanalyse = BBAanalyse;
    
    string = [caminho_arquivos folder '/' 'M' num2str(m) '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' 'data.mat'];
    save(string,'data');
    tf = datenum(datetime('now'));
    
    fprintf('Índice do BPM: %d\n', bpm);
    fprintf('Índice do Quadrupolo mais perto: %d\n', quadru);
    fprintf('É Skew: %d\n', is_skew);
    fprintf('É Sextupolo: %d\n', is_sextupole);
    fprintf('Tempo de Execução (s): %.2f\n', (tf-t0)*100000);
    fprintf('--------------------\n');
end