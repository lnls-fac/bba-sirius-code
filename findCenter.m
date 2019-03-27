%Encontra a posição no centro de um elemento
function r_out = findCenter(ring,orbit, ind)
    Elem_aux = ring(ind);
    Elem_aux{1}.Length = Elem_aux{1}.Length/2;
    r_out = linepass(Elem_aux,orbit(:,ind));
end
