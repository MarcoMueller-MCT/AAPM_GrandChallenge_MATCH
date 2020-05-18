%{

This script is used to quickly analyse participant submissions for MATCH
by displaying the ground truth HexaMotion trace with the Markerless tracking trace.

Instructions:
1. Save the tracked target location as distance from isocenter in mm
as a 3 coloumn numeric matrix [LR|SI|AP] with double precision in a .mat-file.
2. Run this script and enter the details of the data.
3. When Figure pops up, visually check the alignment of the ground truth with the
tracked target location trace. Use the "Pan"-tool (Hand-symbol) on the upper plot
to manually align the ground truth. Do not use the zoom function, as this
will change the start and end points of the selected trace section.

%}

% This line is a test change made to check commitment of changes/Per Poulsen

%%
clear all
%close all

prompt = {'Participant name:','System latency [ms]:','Tracking sampling rate [Hz]:'};
dlgtitle = 'Input';
dims = [1 55];
definput = {'Test_Participant','0','95'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

Participant = answer{1};
latency = str2double(answer{2}); % latency in ms
Sampling = str2double(answer{3}); % Sampling rate of the tracked target location in Hz

TrackingResult = cell2mat(struct2cell(load(uigetfile('','Please select tracking result file'))));

MarkerlessFile.LR_mm = TrackingResult(:,1);
MarkerlessFile.SI_mm = TrackingResult(:,2);
MarkerlessFile.AP_mm = TrackingResult(:,3);

tracefile = uigetfile('C:\Users\Work\Google Drive\MarcosData\PhD\MATCH\Part B\MATCH Part B MotionTraces\*.txt','Please select trajectory file');
fileID = fopen(['C:\Users\Work\Google Drive\MarcosData\PhD\MATCH\Part B\MATCH Part B MotionTraces\',tracefile],'r');
fgetl(fileID);
SigKv = textscan(fileID,'%f\t%f\t%f\n'); % Read the motion data
fclose(fileID);

GTSignal = cell2mat(SigKv);
%GTSignal(:,2) = -GTSignal(:,2);

Fs = [50 Sampling];
[p,q] = rat(Fs(1) / Fs(2));

MarkerlessFile.LR_mm = resample(MarkerlessFile.LR_mm,p,q);
MarkerlessFile.SI_mm = resample(MarkerlessFile.SI_mm,p,q);
MarkerlessFile.AP_mm = resample(MarkerlessFile.AP_mm,p,q);
GTSignalRes = GTSignal;

while length(MarkerlessFile.SI_mm)>length(GTSignalRes)
    GTSignalRes(length(GTSignalRes)+1:length(GTSignalRes)+length(GTSignal),:) = GTSignal;
end

if size(GTSignal,1) > length(MarkerlessFile.SI_mm)
    for I = 1:size(GTSignalRes,1)-length(MarkerlessFile.SI_mm)
        GTSignalResTemp = GTSignalRes(I:I+length(MarkerlessFile.SI_mm)-1,:);
        GT_MT_Dist(I) = sum(diag(corr([MarkerlessFile.LR_mm,MarkerlessFile.SI_mm,[MarkerlessFile.AP_mm]],GTSignalResTemp)));
    end
    [~,x] = max(GT_MT_Dist);
else
    deleteddatapoints = [];
    for I = 1:0.8*size(GTSignal,1)
        clear MarkerlessResTemp GTSignalResTemp
        GTSignalResTemp = GTSignal(I:length(GTSignal)-1,:);
        MarkerlessResTemp(:,1) = MarkerlessFile.LR_mm(1:length(GTSignal)-I,:);
        MarkerlessResTemp(:,2) = MarkerlessFile.SI_mm(1:length(GTSignal)-I,:);
        MarkerlessResTemp(:,3) = MarkerlessFile.AP_mm(1:length(GTSignal)-I,:);
        GT_MT_Dist_1(I) = sum(diag(corr(MarkerlessResTemp,GTSignalResTemp)));
    end
    [~,x] = max(GT_MT_Dist_1);
    GT_Trace = GTSignal;
    periodstart = length(GTSignal)-x;
    
    while periodstart + size(GTSignal,1) +300 < length(MarkerlessFile.LR_mm)
        clear MarkerlessResTemp GTSignalResTemp GT_MT_Dist
        for I = periodstart:periodstart +300
            MarkerlessResTemp(:,1) = MarkerlessFile.LR_mm(I:I+length(GTSignal)-1,:);
            MarkerlessResTemp(:,2) = MarkerlessFile.SI_mm(I:I+length(GTSignal)-1,:);
            MarkerlessResTemp(:,3) = MarkerlessFile.AP_mm(I:I+length(GTSignal)-1,:);
            GT_MT_Dist(I) = sum(diag(corr(MarkerlessResTemp,GTSignal)));
        end
        [~,x1] = max(GT_MT_Dist);
        GT_Trace(x1+x:x1+x+length(GTSignal)-1,:) = GTSignal;
        deleteddatapoints = [deleteddatapoints, periodstart:x1];
        periodstart = length(GTSignal) + x1;
       
    end
    if periodstart + size(GTSignal,1) +300 > length(MarkerlessFile.LR_mm)
            clear GT_MT_Dist
            for I = periodstart:periodstart +300
                clear MarkerlessResTemp GTSignalResTemp
                Limit = length(MarkerlessFile.LR_mm)-I;
                GTSignalResTemp = GTSignal(1:Limit+1,:);
                MarkerlessResTemp(:,1) = MarkerlessFile.LR_mm(I:end,:);
                MarkerlessResTemp(:,2) = MarkerlessFile.SI_mm(I:end,:);
                MarkerlessResTemp(:,3) = MarkerlessFile.AP_mm(I:end,:);
                GT_MT_Dist(I) = sum(diag(corr(MarkerlessResTemp,GTSignalResTemp)));
            end
            [~,x1] = max(GT_MT_Dist);
            deleteddatapoints = [deleteddatapoints, periodstart:x1];
            GT_Trace(x1+x:x1+x+length(GTSignal)-1,:) = GTSignal;
    end
end

Tracefig = figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,1,1); plot(GT_Trace,'LineWidth',2); title('HexaMotion Trace','FontSize',16); legend('LR','SI','AP','Deleted data'); hold on; plot(deleteddatapoints+x,GT_Trace(deleteddatapoints+x),'ro','LineWidth',2); xlim([x,x+length(MarkerlessFile.LR_mm)]); ylim([min(min(GTSignalRes)),max(max(GTSignalRes))]); 
subplot(2,1,2); plot(MarkerlessFile.LR_mm,'LineWidth',2);hold on; plot(MarkerlessFile.SI_mm,'LineWidth',2); hold on; plot(MarkerlessFile.AP_mm,'LineWidth',2);hold on; plot(deleteddatapoints,MarkerlessFile.SI_mm(deleteddatapoints),'ro','LineWidth',2);plot(deleteddatapoints,MarkerlessFile.AP_mm(deleteddatapoints),'ro','LineWidth',2);plot(deleteddatapoints,MarkerlessFile.LR_mm(deleteddatapoints),'ro','LineWidth',2); title('Markerless Tracking Trace','FontSize',16); legend('LR','SI','AP','Deleted data');xlim([1,1+length(MarkerlessFile.LR_mm)]); ylim([min(min(GTSignalRes)),max(max(GTSignalRes))])

pause(2.0);
f = figure;
annotation('textbox', [0.25, 0.25, 0.6, 0.15], 'string', 'Please double check and correct the X-Axis of the HexaMotion Trace to match the Markerless Trace if required.')
h = uicontrol('Position',[180 20 200 40],'String','Analyse result',...
    'Callback','uiresume(gcbf)');
uiwait(gcf);
close(f);

dataObjs=     get(Tracefig,'Children');
all_axesObjs = findobj(dataObjs, 'type', 'axes');
xlimi = get(all_axesObjs, 'xlim');
HexaTracelim= round(xlimi{2,1});

Markerless_Trace(:,1) = MarkerlessFile.LR_mm;
Markerless_Trace(:,2) = MarkerlessFile.SI_mm;
Markerless_Trace(:,3) = MarkerlessFile.AP_mm;

if latency ~=0
    NewHexaTracelim = ceil(HexaTracelim/p*q) + ceil(latency*q/1000);
    GT_Trace = GT_Trace(NewHexaTracelim(1):NewHexaTracelim(2),:);
    GT_Trace(length(Markerless_Trace)+1:end,:)=[];
else
    GT_Trace = GT_Trace(HexaTracelim(1):HexaTracelim(2)-1,:);
end

%% Note on deleted data (red circles in plot): 
%%When the motion traces was played in a loop, the
%%motion platform may follow some unknown motion at the transition from the
%%end of one trace to the beginning of the next. These data points were
%%identified during the correlation with the ground truth and deleted:
Markerless_Trace(deleteddatapoints,:)=[];
GT_Trace(deleteddatapoints,:)=[];

%%
TrackingError =  Markerless_Trace- GT_Trace;

ME = mean(TrackingError);
STD = std(TrackingError);

xAxisTimeLabel= [(1:size(GT_Trace(:,1)))/7];

figure('units','normalized','outerposition',[0 0.25 1 0.6]);
subplot(1,3,1);
plot(xAxisTimeLabel,GT_Trace(:,1)-mean(GT_Trace(:,1)),'LineWidth',1.5,'Color','black');
hold on; plot(xAxisTimeLabel,Markerless_Trace(:,1)-mean(GT_Trace(:,1)),'LineWidth',1.5);
legend('Ground truth','Tracking');
%axis([-inf inf min(Result.PhantomMotionTrace.GroundTruth(:,1))-0.2*(max(Result.PhantomMotionTrace.GroundTruth(:,1))-min(Result.PhantomMotionTrace.GroundTruth(:,1))) inf])
title('LR direction','FontSize',16);
ylabel('Displacement [mm]','FontSize',16);
xlabel('Time [sec]');
ylim([min([min(min(GT_Trace)),min(min(Markerless_Trace))]),max([max(max(GT_Trace)),max(max(Markerless_Trace))])])
annotation('textbox', [0.18, 0.175, 0.1, 0.025], 'string', ['ME: ' num2str(round(ME(1),1)) ' +- ' num2str(round(STD(1),1)),' mm'],'FontSize',14,'FitBoxToText','on', 'Color','red','Backgroundcolor','white', 'FaceAlpha',.9 );

subplot(1,3,2);
plot(xAxisTimeLabel,GT_Trace(:,2)-mean(GT_Trace(:,2)),'LineWidth',1.5,'Color','black');
hold on; plot(xAxisTimeLabel,Markerless_Trace(:,2)-mean(GT_Trace(:,2)),'LineWidth',1.5);
legend('Ground truth','Tracking');
%axis([-inf inf min(Result.PhantomMotionTrace.GroundTruth(:,2))-0.2*(max(Result.PhantomMotionTrace.GroundTruth(:,2))-min(Result.PhantomMotionTrace.GroundTruth(:,2))) inf])
title('SI direction','FontSize',16);
xlabel('Time [sec]');
ylim([min([min(min(GT_Trace)),min(min(Markerless_Trace))]),max([max(max(GT_Trace)),max(max(Markerless_Trace))])])
annotation('textbox', [0.46, 0.175, 0.1, 0.025], 'string', ['ME: ' num2str(round(ME(2),1)) ' +- ' num2str(round(STD(2),1)),' mm'],'FontSize',14,'FitBoxToText','on', 'Color','red','Backgroundcolor','white', 'FaceAlpha',.9 );

subplot(1,3,3);
plot(xAxisTimeLabel,GT_Trace(:,3)-mean(GT_Trace(:,3)),'LineWidth',1.5,'Color','black');
hold on; plot(xAxisTimeLabel,Markerless_Trace(:,3)-mean(GT_Trace(:,3)),'LineWidth',1.5);
legend('Ground truth','Tracking');
%axis([-inf inf min(Result.PhantomMotionTrace.GroundTruth(:,3))-0.2*(max(Result.PhantomMotionTrace.GroundTruth(:,3))-min(Result.PhantomMotionTrace.GroundTruth(:,3))) inf])
title('AP direction','FontSize',16);
xlabel('Time [sec]');
ylim([min([min(min(GT_Trace)),min(min(Markerless_Trace))]),max([max(max(GT_Trace)),max(max(Markerless_Trace))])])
annotation('textbox', [0.741, 0.175, 0.1, 0.025], 'string', ['ME: ' num2str(round(ME(3),1)) ' +- ' num2str(round(STD(3),1)),' mm'],'FontSize',14,'Backgroundcolor','white','FitBoxToText','on', 'Color','red','FaceAlpha',.9 );

mkdir('Results\');
print(['Results\',Participant,'_', tracefile(1:end-4)],'-dpng');
savefig(['Results\',Participant,'_', tracefile(1:end-4),'.fig']);

Analysis.PercentWith1mm = length(find(vecnorm(TrackingError')<=1))/length(TrackingError);
Analysis.PercentWith2mm = length(find(vecnorm(TrackingError')<=2))/length(TrackingError);
Analysis.PercentWith3mm = length(find(vecnorm(TrackingError')<=3))/length(TrackingError);
Analysis.TrackingError = TrackingError;
Analysis.TrackingError3D = vecnorm(TrackingError')';
Analysis.MeanError = ME;
Analysis.MeanErrorSTD = STD;
Analysis.AUC = sort(vecnorm(TrackingError'))';
Analysis.Percentile95th = Analysis.AUC(round(0.95*length(TrackingError)));

save(['Results\',Participant,'_', tracefile(1:end-4),'.mat'],'Markerless_Trace','GT_Trace','Analysis')
