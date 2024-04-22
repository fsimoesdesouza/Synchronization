
clear all
close all


%Add the current path with the matlab scripts  
addpath('.')

experiment = 1; %experiment number (defined on the ChoicesFilesJOVE.m)

Convert_Arena_Metadata_JOVE;

lane = LANE{experiment};
titulo = TITULO{experiment};

filme_flir_path = FILME_FLIR_PATH{experiment};
avi_out_flir_filename = AVI_OUT_FLIR_FILENAME{experiment};


%data MINISCOPE
miniscope_path = MINISCOPE_PATH{experiment};
avi_out_miniscope_filename = AVI_OUT_MINISCOPE_FILENAME{experiment};
avi_out_miniscope_concat = AVI_OUT_MINISCOPE_CONCAT{experiment};


headorientation_filename = HEADORIENTATION_FILENAME{experiment};
headorientation = importdata(headorientation_filename{experiment});

odorarena_metadata_path = ODORARENA_METADATA_PATH{experiment};

out_filename = OUT_FILENAME{experiment};
out_filename_sync = OUT_FILENAME_SYNC{experiment};


%concat miniscope data

cd(miniscope_path );
tmp = dir('*.avi');        % all .avi video clips
videoList = {tmp.name}';  

% create output in separate folder (to avoid accidentally using it as input)
mkdir('output');
outputVideo = VideoWriter(strcat('output/',avi_out_miniscope_concat));

inputVideo_init = VideoReader(videoList{1}); % first video
outputVideo.FrameRate = inputVideo_init.FrameRate;
outputVideo.Quality = 100;

open(outputVideo) % >> open stream

disp('Concatenating Miniscope Files')
for i = 1:length(videoList)
    disp(i)
    inputVideo = VideoReader(videoList{i});
    while hasFrame(inputVideo)
        writeVideo(outputVideo, readFrame(inputVideo));
    end
end
close(outputVideo) % << close after having iterated through all videos


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Reads Intan files
read_Intan_RHD2000_file_JOVE(INTAN_PATH{experiment},INTAN_FILENAME{experiment});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Parameters for finding the TTL pulses
limiar1 = 0.8; %miniscope
limiar2 = 0.8; %flir

%figure(1)
%plot(t_board_adc,board_adc_data(1,:),'r',t_board_adc,board_adc_data(2,:),'g')

miniscope.intantime = t_board_adc;
miniscope.rate = frequency_parameters.board_adc_sample_rate;
miniscope.dt = 1/miniscope.rate;
miniscope.raw = board_adc_data(1,:);

[b,a] = butter(4,500/(miniscope.rate*0.5),'low');           % IIR filter design
miniscope.raw = filtfilt(b,a,miniscope.raw);                    % zero-phase filtering

miniscope.raw = diff([miniscope.raw miniscope.raw(end)]);

miniscope.max= max(miniscope.raw);
miniscope.min= min(miniscope.raw);

miniscope.bin = miniscope.raw > miniscope.max*limiar1 | miniscope.raw < miniscope.min*limiar1;


miniscope.diff = diff(miniscope.bin);

miniscope.frameindex = find(miniscope.diff == 1)+1;
miniscope.timing = miniscope.intantime(miniscope.frameindex);

flir.intantime = t_board_adc;
flir.rate = frequency_parameters.board_adc_sample_rate;
flir.dt = 1/flir.rate;
flir.raw = board_adc_data(2,:);

[b,a] = butter(4,500/(flir.rate*0.5),'low');           % IIR filter design
flir.raw = filtfilt(b,a,flir.raw);                    % zero-phase filtering

flir.raw = diff([flir.raw flir.raw(end)]);

flir.max = max(flir.raw);
flir.min = min(flir.raw);

flir.bin = flir.raw < flir.min*limiar2;
flir.diff = diff(flir.bin);


flir.frameindex = find(flir.diff == 1)+1;
flir.timing = flir.intantime(flir.frameindex);

%Look at timestamps to check whether the nframes are correct
miniscope.nframes = length(miniscope.timing);
flir.nframes = length(flir.timing);

disp(strcat('miniscope nframes=',num2str(miniscope.nframes)));
disp(strcat('flir nframes=',num2str(flir.nframes)));

miniscope.latency = miniscope.timing(1);
flir.latency = flir.timing(1);

latency =  flir.latency - miniscope.latency;

disp(strcat('miniscopelatency(sec)=',num2str(miniscope.latency)))
disp(strcat('flirlatency(sec)=',num2str(flir.latency)));

miniscope.begintime = miniscope.timing(1);
flir.begintime = flir.timing(1);

miniscope.endtime = miniscope.timing(end);
flir.endtime = flir.timing(end);

begintime = max([miniscope.begintime flir.begintime])+0.1;
endtime = min([miniscope.endtime flir.endtime])-0.1;

[indices, valor]= find(miniscope.timing' > begintime & miniscope.timing' < endtime);


%Synchronizing FLIR with Miniscope
%For each Miniscope frame, I find the nearest neighbor FLIR frame
c = 1;
for p = indices(1):indices(end)
instante = miniscope.timing(p);
proximo_dot = find(flir.timing > (instante-0.1) & flir.timing < (instante+0.1) );

dt = flir.timing(proximo_dot)-instante;
[M,I]=min(abs(dt));
deltas(p) = M(1); %delay between flir and miniscope frames

proximo(c) = proximo_dot(I(1));

c = c + 1;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Save indexes for each chosen frames
load(strcat(odorarena_metadata_path,out_filename));
arena.index_flirsynctominiscope = proximo;

%Save indexes for each chosen frames
arena.index_miniscopebehavioraltask = indices(1):indices(end);

%Save the xy position of the mouse for each miniscope frame
arena.xsync = arena.x(arena.index_flirsynctominiscope);
arena.ysync = arena.y(arena.index_flirsynctominiscope);

%Save odor and water delivery
arena.odorsync = odor(arena.index_flirsynctominiscope);
arena.watersync = water(arena.index_flirsynctominiscope);

%Save headorientation data
arena.quarternionsync = headorientation.data(arena.index_miniscopebehavioraltask,2:5);

save(strcat(odorarena_metadata_path,out_filename_sync),'arena')

%Saves synchronized FLIR movie

v0 = VideoReader(filme_flir_path);

aviobj_flir = VideoWriter(avi_out_flir_filename);
aviobj_flir.Quality = 100;

open(aviobj_flir)

disp('Video flir Sync start')

for p = 1:length(proximo)
    vidFrame = read(v0,proximo(p));
    disp(100*p/length(proximo))
    writeVideo(aviobj_flir,vidFrame);
end
close(aviobj_flir);

disp('Video flir Sync end')

v1 = VideoReader(strcat(miniscope_path,'/output/',avi_out_miniscope_concat));

aviobj_miniscope = VideoWriter(strcat(odorarena_metadata_path,avi_out_miniscope_filename));
aviobj_miniscope.Quality = 100;

open(aviobj_miniscope)

disp('Video miniscope Sync start')


for p = indices(1):indices(end)

    vidFrame = read(v1,p);
    disp(100*p/length(indices(1):indices(end)))

    writeVideo(aviobj_miniscope,vidFrame);
end
close(aviobj_miniscope);

outputVideo = VideoWriter(strcat(odorarena_metadata_path,avi_out_miniscope_filename));


disp('Sync Completed')


