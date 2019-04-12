caminho_arquivos = '../bba-sirius-data/';
folder = 'grid';

%configuracoes do arquivo a ser carregado
m = 1;

range = 10;
random_error = false;

corrigir = true;
corrigir_ang = false;

%carrega o anel correspondente
if(m==0)
	ring = the_ring;
else
	ring = machine{m};
end

l1 = ['b*'; 'r*'; 'k*'];
l2 = ['bs'; 'rs'; 'ks'];

%cria os espaços para os gráficos da primeira figura
figure('NumberTitle', 'off', 'Name', ['Máquina ' num2str(m) '_' num2str(recursao) 'r - Desvios']);
ax1 = subplot(1,1,1);
hold(ax1,'on');
xlabel(ax1,'xQuadru (um)');
ylabel(ax1,'yQuadru (um)');
zlabel(ax1, 'Desvio (m^2)');

width_line = 1;

%colormap(gray)
colormap(flipud(gray(256)));

sum1 = 0;
sum2 = 0;
sum3 = 0;

i1 = 0;
i2 = 0;
i3 = 0;

%for i=1:length(alist_bpm)
for i=1:length(alist_bpm)
    t0 = datenum(datetime('now'));
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
    
    %Abre os arquivos das simulações neste bpm
    string = [caminho_arquivos folder '/' 'M' num2str(m) '_' num2str(bpm) '_' num2str(range) '_' num2str(random_error) '_' 'data.mat'];
    load(string);
    
    %Seta a escala dos dados (um)
	pot = 1e6;
    xReal = data.BBAanalyse.xReal*pot;
    yReal = data.BBAanalyse.yReal*pot;
    xMinQuadru = data.BBAanalyse.xMinQuadru*pot;
    yMinQuadru = data.BBAanalyse.yMinQuadru*pot;
    xMinBPM = data.BBAanalyse.xMinBPM*pot;
    yMinBPM = data.BBAanalyse.yMinBPM*pot;
    %xQuadru = data.xQuadru*pot;
    %yQuadru = data.yQuadru*pot;
    %func = data.func*pot*pot;
    %{
    Vq = data.BBAanalyse.Vq*pot*pot;
    Xq = data.BBAanalyse.Xq*pot;
    Yq = data.BBAanalyse.Yq*pot;
    Xb = data.BBAanalyse.Xb*pot;
    Yb = data.BBAanalyse.Yb*pot;
    %}
    
    %Calcula as expressões teóricas de correção
    if(corrigir == true)
        L = the_ring{quadru}.Length;
        if(bpm > quadru)
            D = findsposOff(the_ring,bpm) - findsposOff(the_ring,quadru) - L;
        else
            D = findsposOff(the_ring,quadru) - findsposOff(the_ring,bpm);
        end
        if(corrigir_ang == true)
            x0l = data.BBAanalyse.xlMinQuadru;
            y0l = data.BBAanalyse.ylMinQuadru;
        else
            x0l = 0; %Não corrige erro do angulo
            y0l = 0; %Não corrige erro do angulo
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
        corr1x = pot*x0;
        corr1y = pot*y0;
        corr2x = pot*((1/8)*(-Gy)*L*L + (1/8)*x0*(-K)*L*L + (Gy*L*L)*(K*L*L)/(12*32)) + pot*(D/2)*((-Gy)*L + x0*(-K)*L + ((-Gy)*L*L)*((-K)*L)/24);
        corr2y = pot*((1/8)*(Gx)*L*L + (1/8)*y0*(K)*L*L + (Gx*L*L)*(K*L*L)/(12*32)) + pot*(D/2)*((Gx)*L + y0*(K)*L + ((Gx)*L*L)*((K)*L)/24);
        corr3x = pot*sign(bpm-quadru)*(x0l*L/2)*(1 + (-K)*L*L/24) + pot*sign(bpm-quadru)*x0l*D*(1 + (-K)*L*L/8);
        corr3y = pot*sign(bpm-quadru)*(y0l*L/2)*(1 + (K)*L*L/24) + pot*sign(bpm-quadru)*y0l*D*(1 + (K)*L*L/8);
    else
        corr1x = 0;
        corr1y = 0;
        corr2x = 0;
        corr2y = 0;
        corr3x = 0;
        corr3y = 0;
    end
    
    dist = (xMinBPM - xReal - corr1x - corr2x - corr3x)*(xMinBPM - xReal - corr1x - corr2x - corr3x);
    dist = dist + (yMinBPM - yReal - corr1y - corr2y - corr3y)*(yMinBPM - yReal - corr1y - corr2y - corr3y);
    if(index == 1)
        i1 = i1 + 1;
        sum1 = sum1 + sqrt(dist);
    elseif(index == 2)
        i2 = i2 + 1 ;
        sum2 = sum2 + sqrt(dist);
    elseif(index == 3)
        i3 = i3 + 1;
        sum3 = sum3 + sqrt(dist);
    end
    
    %surf(xQuadru,yQuadru,func);
    %surf(xQuadru,yQuadru,F(xQuadru,yQuadru));
    %contourf(xQuadru - xReal,yQuadru - yReal,func);
    %contourf(Xq, Yq, Vq);
    plot(xMinQuadru - xReal - corr1x ,yMinQuadru - yReal - corr1y,l1(index,:),'linewidth', width_line);
    %plot(xReal,yReal,'ro');
    %plot(0,0,'ro');
    plot(xMinBPM - xReal - corr1x - corr2x - corr3x,yMinBPM - yReal - corr1y - corr2y - corr3y,l2(index,:),'linewidth', width_line);
    tf = datenum(datetime('now'));
    fprintf('Índice do BPM: %d\n', bpm);
    fprintf('Índice do Quadrupolo mais perto: %d\n', quadru);
    fprintf('É Skew: %d\n', is_skew);
    fprintf('É Sextupolo: %d\n', is_sextupole);
    fprintf('%.3f %.3f\n', xMinQuadru - xReal - corr1x, yMinQuadru - yReal - corr1y);
    fprintf('%.3f %.3f\n', xMinBPM - xReal - corr1x - corr2x - corr3x, yMinBPM - yReal - corr1y - corr2y - corr3y);
    fprintf('Tempo de Execução (s): %.2f\n', (tf-t0)*100000);
    fprintf('--------------------\n');
end
    fprintf('%d %d %d', sum1/i1, sum2/i2, sum3/i3);