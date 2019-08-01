function p = fitQuartic(kicks, meritfunction, flag)
    tam = length(kicks);
    %{
    c = min(meritfunction);
    meritfunction = meritfunction - c;
    
    sumv = [];
	sumv2 = [];
	for v=0:(tam-1)/2
        coef = [];
        sumang = [];
        for j=2:length(kicks)-2-v
            kicks1=kicks(1:j);
            kicks2=kicks(j+1+v:end);
            meritfunction1=meritfunction(1:j);
            meritfunction2=meritfunction(j+1+v:end);
            meritfunction1=meritfunction1.^(1/4);
            meritfunction2=meritfunction2.^(1/4);
            p1 = polyfit(kicks1, meritfunction1, 1);
            p2 = polyfit(kicks2, meritfunction2, 1);
            f1 = fit(kicks1, meritfunction1, 'poly1');
            f2 = fit(kicks2, meritfunction2, 'poly1');
            r1 = meritfunction1 - f1(kicks1);
            r1 = norm(r1)*norm(r1);
            var1 = var(meritfunction1)*(length(meritfunction1)-1);
            r1 = 1 - (r1/var1);
            r2 = meritfunction2 - f2(kicks2);
            r2 = norm(r2)*norm(r2);
            var2 = var(meritfunction2)*(length(meritfunction2)-1);
            r2 = 1 - (r2/var2);
            kickMin3 = (p2(2) - p1(2))/(p1(1) - p2(1));
            coef = [coef; 2*r1*r2/(r1+r2)];
            sumang = [sumang; abs(p2(1) + p1(1))];
        end
        [M,I] = max(coef);
        %[M,I] = min(sumang);
        %sumv = [sumv; M];
        sumv = [sumv; coef(I)];
        sumv2 = [sumv2; I];
    end
	[M,I] = max(sumv);
	v = I-1;
	j = sumv2(I)+1;
	kicks1=kicks(1:j);
	kicks2=kicks(j+1+v:end);
	meritfunction1=meritfunction(1:j);
	meritfunction2=meritfunction(j+1+v:end);
    meritfunction1=meritfunction1.^(1/4);
    meritfunction2=meritfunction2.^(1/4);
	p1 = polyfit(kicks1, meritfunction1, 1);
	p2 = polyfit(kicks2, meritfunction2, 1);
	kickMin3 = (p2(2) - p1(2))/(p1(1) - p2(1));
    c1 = length(kicks1);
    c2 = length(kicks2);
    p0 = (c1*p1(1)^4 + c2*p2(1)^4)/(c1+c2); 
    x = [p0 kickMin3 0];
    if(flag == true)
        v
        figure;
        hold on;
        plot(kicks, meritfunction.^(1/4), 'ko');
        plot(kicks, p1(1)*kicks + p1(2))
        plot(kicks, p2(1)*kicks + p2(2))
        plot(kickMin3, p1(1)*kickMin3 + p1(2), '*')
        hold off;
    end
    %}
    
    p = polyfit(kicks, meritfunction, 4);
    p0 = p(1);
    kickMin3 = -p(2)/(4*p0);
    c = min(meritfunction);
    x = [p0 kickMin3 c];
    %{
	F = @(x,xdata)x(1)*(xdata - x(2)).^4 + x(3);
	x0 = [p0 kickMin3 c];
	[x,resnorm,~,exitflag,output] = lsqcurvefit(F,x0,kicks,meritfunction);
	t = x - x0;
    t(1) = t(1)*100/x0(1);
    t(2) = t(2)*100/x0(2);
    t(3) = t(3)*100/x0(3);
    t
    %}
    
    p = [x(1) -4*x(1)*x(2) 6*x(1)*x(2)*x(2) -4*x(1)*x(2)*x(2)*x(2)  x(1)*x(2)*x(2)*x(2)*x(2)+x(3)];
    %kicks = [kicks1; kicks2];
    %meritfunction = [meritfunction1; meritfunction2];
    %meritfunction = meritfunction.^4;
    %p = polyfit(kicks, meritfunction, 4);

    %c = 0;
    for i=1:3
        A = p(1);
        kicksc = kicks - kickMin3;
        f = polyval(p,kicks);
        meritfunctionc = meritfunction - f;
        
        %p_aux = polyfit(kicksc, meritfunctionc, 4);
        M = [sum(kicksc.^4) sum(kicksc.^3) length(kicksc) ; sum(kicksc.^7) sum(kicksc.^6) sum(kicksc.^3); sum(kicksc.^8) sum(kicksc.^7) sum(kicksc.^4)];
        C = [sum(meritfunctionc); sum(meritfunctionc.*(kicksc.^3)); sum(meritfunctionc.*(kicksc.^4))];
        p_aux = linsolve(M,C);
        p_aux = [p_aux(1) p_aux(2) 0 0 p_aux(3)];
        
        p0 = p0 + p_aux(1);
        kickMin3 = kickMin3 - p_aux(2)/(4*A);
        c = c + p_aux(5);
        
        x = [p0 kickMin3 c];
        p = [x(1) -4*x(1)*x(2) 6*x(1)*x(2)*x(2) -4*x(1)*x(2)*x(2)*x(2)  x(1)*x(2)*x(2)*x(2)*x(2)+x(3)];
        f = polyval(p_aux, kicksc);
        if(flag == true)
            figure;
            hold on;
            plot(kicksc, meritfunctionc, 'ko');
            plot(kicksc, f);
            hold off;
        end
    end

    %x = [p0 kickMin3 0];
    %p = [x(1) -4*x(1)*x(2) 6*x(1)*x(2)*x(2) -4*x(1)*x(2)*x(2)*x(2)  x(1)*x(2)*x(2)*x(2)*x(2)+x(3)];
end

