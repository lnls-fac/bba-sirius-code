ring = machine{1};
ring = setcavity('on',ring);
ring = setradiation('on',ring);
orbit = findorbit6(ring,1:length(ring));
figure;
ax = subplot(1,1,1);
hold(ax,'on')
xlabel(ax,'posição no anel - s (m)','FontSize',28);
ylabel(ax,'órbita horizontal - x (um)','FontSize',28);
ax.FontSize = 28; 
plot(ax, findsposOff(ring,1:length(ring)), orbit(1,:)*10^6, 'linewidth',3);