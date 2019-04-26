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
    
    points = data.points;
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
            
    posQuadru = data.posQuadru;
    xQuadru = zeros(2*range+1,2*range+1);
    yQuadru = zeros(2*range+1,2*range+1);
    xlQuadru = zeros(2*range+1,2*range+1);
    ylQuadru = zeros(2*range+1,2*range+1);
    for j = 1:2*range+1
        for k = 1:2*range+1
            xQuadru(k,j) = posQuadru(1,(j-1)*(2*range + 1) + k);
            yQuadru(k,j) = posQuadru(3,(j-1)*(2*range + 1) + k);
            xlQuadru(k,j) = posQuadru(2,(j-1)*(2*range + 1) + k);
            ylQuadru(k,j) = posQuadru(4,(j-1)*(2*range + 1) + k);
        end
    end
            
    posBPM = data.posBPM;
    xBPM = zeros(2*range+1,2*range+1);
    yBPM = zeros(2*range+1,2*range+1);
    for j = 1:2*range+1
        for k = 1:2*range+1
            xBPM(k,j) = posBPM(1,(j-1)*(2*range + 1) + k);
            yBPM(k,j) = posBPM(3,(j-1)*(2*range + 1) + k);
        end
    end
    
    data.kickx = kickx;
    data.kicky = kicky;
    data.func = func;
    data.xQuadru = xQuadru;
    data.yQuadru = yQuadru;
    data.xBPM = xBPM;
    data.yBPM = yBPM;
    data.xlQuadru = xlQuadru;
    data.ylQuadru = ylQuadru;
    
    [kX, kY] = meshgrid(min(kickx(1,:)):(max(kickx(1,:))-min(kickx(1,:)))/steps_interp:max(kickx(1,:)), min(kicky(:,1)):(max(kicky(:,1))-min(kicky(:,1)))/steps_interp:max(kicky(:,1)));
    Vq = interp2(kickx, kicky, func, kX, kY, 'spline');
    Xq = interp2(kickx, kicky, xQuadru, kX, kY, 'spline');
    Yq = interp2(kickx, kicky, yQuadru, kX, kY, 'spline');
    Xb = interp2(kickx, kicky, xBPM, kX, kY, 'spline');
    Yb = interp2(kickx, kicky, yBPM, kX, kY, 'spline');
    Xlq = interp2(kickx, kicky, xlQuadru, kX, kY, 'spline');
    Ylq = interp2(kickx, kicky, ylQuadru, kX, kY, 'spline');
    
    minMatrix = min(Vq(:));
    [row,col] = find(Vq == minMatrix);
    kickxMin = kX(row,col);
    kickyMin = kY(row,col);
    
    xMinQuadru = Xq(row,col);
    yMinQuadru = Yq(row,col);
    
    xReal = ring{quadru}.T2(1);
    yReal = ring{quadru}.T2(3);
    
    xMinBPM = Xb(row,col);
    yMinBPM = Yb(row,col);
    
    xlMinQuadru = Xlq(row,col);
    ylMinQuadru = Ylq(row,col);
    
    BBAanalyse = [];
    BBAanalyse.steps_interp = steps_interp;
    %BBAanalyse.Vq = Vq;
    %BBAanalyse.Xq = Xq;
    %BBAanalyse.Yq = Yq;
    %BBAanalyse.Xb = Xb;
    %BBAanalyse.Yb = Yb;
    %BBAanalyse.Xlq = Xlq;
    %BBAanalyse.Ylq = Ylq;
    BBAanalyse.kickxMin = kickxMin;
    BBAanalyse.kickyMin = kickyMin;
    BBAanalyse.xMinQuadru = xMinQuadru;
    BBAanalyse.yMinQuadru = yMinQuadru;
    BBAanalyse.xMinBPM = xMinBPM;
    BBAanalyse.yMinBPM = yMinBPM;
    BBAanalyse.xlMinQuadru = xlMinQuadru;
    BBAanalyse.ylMinQuadru = ylMinQuadru;
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