%Encontra a posição no centro de um elemento
function r_out = findFinal(ring,orbit, ind)
    Elem_aux = ring(ind);
    r_out = linepass(Elem_aux,orbit(:,ind));
end
