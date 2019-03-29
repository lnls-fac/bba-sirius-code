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

%cria os espaços para os gráficos da primeira figura
figure('NumberTitle', 'off', 'Name', ['Máquina ' num2str(m) '_' num2str(recursao) 'r - Desvios']);
ax1 = subplot(1,1,1);
hold(ax1,'on');
xlabel(ax1,'xQuadru (um)');
ylabel(ax1,'yQuadru (um)');
zlabel(ax1, 'Desvio (m^2)');

%colormap(gray)
colormap(flipud(gray(256)));

%for i=1:length(alist_bpm)
for i=1:1
    bpm = alist_bpm(i);
    quadru = alist_quadru(i);
    is_skew = isSkew(family_data,quadru);
    is_sextupole = isSextupole(family_data,quadru);
    
    %Abre os arquivos das simulações neste bpm
    string = [caminho_arquivos folder '/' 'M' num2str(m) '_' num2str(recursao) 'r' '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' 'data.mat'];
    load(string);
    
    %Seta a escala dos dados (um)
	pot = 1e6;
    data.kickx = data.kickx*pot;
    data.kicky = data.kicky*pot;
    data.func = data.func;
    data.xQuadru = data.xQuadru*pot;
    data.yQuadru = data.yQuadru*pot;
    data.xBPM = data.xBPM*pot;
    data.yBPM = data.yBPM*pot;
    
    kickx = data.kickx;
    kicky = data.kicky;
    func = data.func;
    xQuadru = data.xQuadru;
    yQuadru = data.yQuadru;
    xBPM = data.xBPM;
    yBPM = data.yBPM;
    
    [kX, kY] = meshgrid(min(kickx(1,:)):(max(kickx(1,:))-min(kickx(1,:)))/5000:max(kickx(1,:)), min(kicky(:,1)):(max(kicky(:,1))-min(kicky(:,1)))/5000:max(kicky(:,1)));
    Vq = interp2(kickx, kicky, func, kX, kY, 'spline');
    Xq = interp2(kickx, kicky, xQuadru, kX, kY, 'spline');
    Yq = interp2(kickx, kicky, yQuadru, kX, kY, 'spline');
    Xb = interp2(kickx, kicky, xBPM, kX, kY, 'spline');
    Yb = interp2(kickx, kicky, yBPM, kX, kY, 'spline');
    
    minMatrix = min(Vq(:));
    [row,col] = find(Vq == minMatrix);
    xMin = Xq(row,col);
    yMin = Yq(row,col);
    
    xReal = ring{quadru}.T2(1);
    yReal = ring{quadru}.T2(3);
    
    xMinBPM = Xb(row,col);
    yMinBPM = Yb(row,col);
    
    %surf(xQuadru,yQuadru,func);
    %surf(xQuadru,yQuadru,F(xQuadru,yQuadru));
    %contourf(xQuadru,yQuadru,func);
    contourf(Xq, Yq, Vq);
    plot(xMin,yMin,'b*');
    plot(xReal,yReal,'ro');
    plot(xMinBPM,yMinBPM,'bs');

end