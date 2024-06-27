%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Experiment #1

k = 1;
LANE{k} = '_L1andL4';
TITULO{k} = 'withodor';
MOUSE{k} = '20220804_FCM22';  %done

BASEPATH{k} = '/media/fabio/CrucialP3/Miniscope_20230407_JOVE/Final/20220804_FCM22/';
TIMESTAMPS{k} = strcat(BASEPATH{k},'/arena01/session001/20220804_arena01_session001_topCam_timestamps.txt');
EVENTOS{k} = strcat(BASEPATH{k},'arena01/session001/20220804_arena01_session001_topCam_events.txt');
OUT_FILENAME{k} = strcat(MOUSE{k},TITULO{k},'_odorarena',LANE{k},'.mat');
OUT_FILENAME_SYNC{k} = strcat(MOUSE{k},TITULO{k},'_odorarena',LANE{k},'_sync','.mat');

%data FLIR (*avi created)
FILME_FLIR_PATH{k} = strcat(BASEPATH{k},'arena01/session001/20220804_arena01_session001_topCam-0000.avi');
AVI_OUT_FLIR_FILENAME{k} = strcat('20220804_FCM22_WithOdor_flir_sync',LANE{k},'.avi');

%data MINISCOPE
MINISCOPE_PATH{k} = strcat(BASEPATH{k},'20220804_FCM22_lanes1_and4_withodor/FCM22/customEntValHere/2022_08_04/11_40_26/miniscopeDeviceName');

AVI_OUT_MINISCOPE_FILENAME{k} = strcat('20220804_FCM22_',TITULO{k},'_miniscope_sync',LANE{k},'.avi');
AVI_OUT_MINISCOPE_CONCAT{k} = strcat('20220804_FCM22_',TITULO{k},'_miniscope_concat',LANE{k},'.avi');

HEADORIENTATION_FILENAME{k} = strcat(MINISCOPE_PATH,'/headOrientation.csv');

%data INTAN
INTAN_PATH{k} = strcat(BASEPATH{k},'20220804_FCM22_lanes1_and4_withodor_220804_114013/');
INTAN_FILENAME{k} = '20220804_FCM22_lanes1_and4_withodor_220804_114013.rhd';

%odorarena metadata
ODORARENA_METADATA_PATH{k} = '/media/fabio/CrucialP3/Miniscope_20230407_JOVE/Final/';



