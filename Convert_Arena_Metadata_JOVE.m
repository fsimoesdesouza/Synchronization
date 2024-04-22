%Choices File
%name of all experiments {1, 2, 3, etc ...}
ChoicesFiles_JOVE; %read choices files

%experiment = 1; %experiment number

timestamps = importdata(TIMESTAMPS{experiment});
eventos = importdata(EVENTOS{experiment});
out_filename = OUT_FILENAME{experiment};
titulo = TITULO{experiment};

x = timestamps.data(:,2);
y = timestamps.data(:,3);

n_frames = length(timestamps.data);

labels = eventos.textdata;

n_reward = 0;
n_odordelivery = 0;
n_odorstop = 0;

[linha,coluna] = find(eventos.data == 1 | eventos.data == 2 ...
    | eventos.data == 3 | eventos.data == 4);
if coluna(1) == 2
    coluna = coluna(1);
    estampa = 1;
end
if coluna(1) == 1
    coluna = coluna(1);
    estampa = 2;
end



for p = 1:length(labels)
if(strcmp(labels{p},'reward'))
    n_reward = n_reward + 1;
    indice_reward(n_reward) = eventos.data(p,estampa); 
    lane_reward(n_reward) = eventos.data(p,coluna);
end

if(strcmp(labels{p},'odor_delivery'))
    n_odordelivery = n_odordelivery + 1;
    indice_odordelivery(n_odordelivery) = eventos.data(p,estampa); 
    lane_odordelivery(n_odordelivery) = eventos.data(p,coluna);
end

if(strcmp(labels{p},'odor_stop'))
    n_odorstop = n_odorstop + 1;
    indice_odorstop(n_odorstop) = eventos.data(p,estampa); 
    lane_odorstop(n_odorstop) = eventos.data(p,coluna);
end

end

if n_odordelivery > n_odorstop
   n_odordelivery = n_odorstop;
%  indice_odordelivery(end) = [];     
end

laneodor = zeros(n_frames,1);
lanewater = zeros(n_frames,1);

odor = zeros(n_frames,1);
for p = 1:n_odordelivery
odor(indice_odordelivery(p):indice_odorstop(p)) = 1;
laneodor(indice_odordelivery(p):indice_odorstop(p)) = lane_odordelivery(p);
end

water = zeros(n_frames,1);
for p = 1:n_reward
water(indice_reward(p):indice_reward(p)+50) = 1;
lanewater(indice_reward(p):indice_reward(p)+50) = lane_reward(p);
end

contalaneodor1 = zeros(n_frames,1);
contalaneodor2 = zeros(n_frames,1);
contalaneodor3 = zeros(n_frames,1);
contalaneodor4 = zeros(n_frames,1);

contalanewater1 = zeros(n_frames,1);
contalanewater2 = zeros(n_frames,1);
contalanewater3 = zeros(n_frames,1);
contalanewater4 = zeros(n_frames,1);

for p = 2:n_frames
    if laneodor(p) > laneodor(p-1)
        if laneodor(p) == 1
            contalaneodor1(p) = 1;
            
        end        
        if laneodor(p) == 2
            contalaneodor2(p) = 1;
        end
        if laneodor(p) == 3
            contalaneodor3(p) = 1;
        end
        if laneodor(p) == 4
            contalaneodor4(p) = 1;
        end
    end

k = 1000; %500
    if p < n_frames && p > k
    if laneodor(p) < laneodor(p-1) 
        i1 = find(lanewater(p-k:p) == 1);    
        i2 = find(lanewater(p-k:p) == 2);    
        i3 = find(lanewater(p-k:p) == 3);    
        i4 = find(lanewater(p-k:p) == 4);    

        if ~isempty(i1)
            contalanewater1(p) = 1;
        end        
        if  ~isempty(i2)
            contalanewater2(p) = 1;
        end
        if  ~isempty(i3)
            contalanewater3(p) = 1;
        end
        if  ~isempty(i4)
            contalanewater4(p) = 1;
        end
    end
    end

end

%HITS e MISSES
%lane 1
choicelanewater = contalanewater1;
choicelaneodor = contalaneodor1;

alfaf1(1) = 0;
alfab1 = zeros(1,length(choicelaneodor));
tau = 500;
p1 = length(choicelaneodor)+1;
p2 = 0;

for p = 2:length(choicelaneodor)
    alfaf1(p) = alfaf1(p-1);
    if choicelaneodor(p) == 1
        p1 = p;
    end

    alfaf1(p) = exp(-abs(p-p1)/tau);
end

for p = length(choicelanewater):-1:2
    alfab1(p) = alfab1(p-1);

    if choicelanewater(p) == 1
        p2 = p;
    end

    alfab1(p) = exp(-abs(p-p2)/tau);

end

hits1 = (alfaf1.*alfab1) > mean(alfaf1.*alfab1);

%lane 4
choicelanewater = contalanewater4;
choicelaneodor = contalaneodor4;

alfaf1(1) = 0;
alfab1 = zeros(1,length(choicelaneodor));
tau = 500;
p1 = length(choicelaneodor)+1;
p2 = 0;

for p = 2:length(choicelaneodor)
    alfaf1(p) = alfaf1(p-1);
    if choicelaneodor(p) == 1
        p1 = p;
    end

    alfaf1(p) = exp(-abs(p-p1)/tau);
end

for p = length(choicelanewater):-1:2
    alfab1(p) = alfab1(p-1);

    if choicelanewater(p) == 1
        p2 = p;
    end

    alfab1(p) = exp(-abs(p-p2)/tau);

end

hits4 = (alfaf1.*alfab1) > mean(alfaf1.*alfab1);


misses1 = ((laneodor == 1)-hits1')>0;
misses4 = ((laneodor == 4)-hits4')>0;

%Counting hits and misses
contalanehits1 = zeros(n_frames,1);
contalanehits4 = zeros(n_frames,1);

contalanemisses1 = zeros(n_frames,1);
contalanemisses4 = zeros(n_frames,1);

for p = 2:n_frames
    if hits1(p) > hits1(p-1)
            contalanehits1(p) = 1;         
    end
    if hits4(p) > hits4(p-1)
            contalanehits4(p) = 1;         
    end
    if misses1(p) > misses1(p-1)
            contalanemisses1(p) = 1;         
    end
    if misses4(p) > misses4(p-1)
            contalanemisses4(p) = 1;         
    end
    
end

%Creating output

arena.contalanehits1 = contalanehits1;
arena.contalanehits4 = contalanehits4;
arena.contalanemisses1 = contalanemisses1;
arena.contalanemisses4 = contalanemisses4;

arena.hits1 = hits1;
arena.hits4 = hits4;
arena.misses1 = misses1;
arena.misses4 = misses4;

arena.x = x;
arena.y = y;
arena.odor = odor;
arena.water = water;
arena.lanewater = lanewater; %water delivery
arena.laneodor = laneodor; %odor delivery

arena.laneodor1 = contalaneodor1;
arena.laneodor2 = contalaneodor2;
arena.laneodor3 = contalaneodor3;
arena.laneodor4 = contalaneodor4;

arena.lanewater1 = contalanewater1;
arena.lanewater2 = contalanewater2;
arena.lanewater3 = contalanewater3;
arena.lanewater4 = contalanewater4;

%dados finais
arena.final.ntotal1 = sum(contalaneodor1);
arena.final.ntotal4 = sum(contalaneodor4);
arena.final.nhits1 = sum(contalanehits1);
arena.final.nhits4 = sum(contalanehits4);
arena.final.nmisses1 = sum(contalanemisses1);
arena.final.nmisses4 = sum(contalanemisses4);


save(out_filename,'arena');
