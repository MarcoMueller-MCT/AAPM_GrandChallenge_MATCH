function output = PrepareMATCHExperimentalData(output)

% This program was used tor preprocess/extract the submitted data for the AAPM
% 2020 MATCH Challenge, PART B, before they were analyzed with the "AnalyzeMATCH" program.

% Written by Per Poulsen

%*************************************************************
% PART 1: Varian submission
%*************************************************************

if 0
    
    method = 'E'; % Values = A-B-C-E
    for plan = 1:2     % Values = 1-2
        for trace = 1:5    %Values = 1-5
            
            if trace == 1 traceName = 'BaseLineShift';
            elseif trace == 2 traceName = 'HighFrequency';
            elseif trace == 3 traceName = 'LRDominant';
            elseif trace == 4 traceName = 'Sinusoidal';
            elseif trace == 5 traceName = 'TypicalLung';
            end
            
            
            if strcmp(method, 'A')
                if plan == 1
                    dataFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\Varian\Method_A\Plan1 MethodA Tracks and Ground Truth\Tracks_A_Plan1_140kV_100mA_10ms_20200429_' traceName '_60-120-0.5-1mm.xlsx'];
                elseif plan == 2
                    dataFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\Varian\Method_A\Plan2 MethodA Tracks and Ground Truth\Tracks_A_Plan2_140kV_100mA_10ms_20200430_' traceName '_60-120-0.5-1mm.xlsx'];
                end
            elseif strcmp(method, 'B')
                if plan == 1
                    dataFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\Varian\Method_B\Plan1 MethodB Tracks and Ground Truth\Tracks_A_Plan1_140kV_100mA_10ms_20200429_' traceName '_Stereo_Merged.xlsx'];
                elseif plan == 2
                    dataFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\Varian\Method_B\Plan2 MethodB Tracks and Ground Truth\Tracks_A_Plan2_140kV_100mA_10ms_20200430_' traceName '_Stereo_Merged.xlsx'];
                end
            elseif strcmp(method, 'C')
                if plan == 1
                    dataFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\Varian\Method_C\Plan1 MethodC Tracks and Ground Truth\Track++_Plan1_140kV_100mA_10ms_20200429_' traceName '_60-120-0.5-1mm.csv'];
                elseif plan == 2
                    dataFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\Varian\Method_C\Plan2 MethodC Tracks and Ground Truth\Track++_Plan2_140kV_100mA_10ms_20200430_' traceName '_60-120-0.5-1mm.csv'];
                end
            elseif strcmp(method, 'E')
                if plan == 1
                    dataFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\Varian\Method_E\Plan1 MethodE Tracks and Ground Truth\MethodE_Tracks_A_Plan1_140kV_100mA_10ms_20200429_' traceName '.xlsx'];
                elseif plan == 2
                    dataFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\Varian\Method_E\Plan2 MethodE Tracks and Ground Truth\MethodE_Tracks_A_Plan2_140kV_100mA_10ms_20200430_' traceName '.xlsx'];
                end
            end
            
            
            [data, ~, ~] = xlsread(dataFile,'B2:I2000');
            
            time = data(:,1);
            
            if strcmp(method, 'A') || strcmp(method, 'B')
                trackingResult = data(:,6:8);
            elseif strcmp(method, 'C') || strcmp(method, 'E')
                trackingResult = data(:,3:5);
            end
            
            % Apparently LR has wrong sign:
            trackingResult(:,1) = -trackingResult(:,1);
            
            figure(1)
            plot(time,trackingResult)
            
            samplingFreq = length(time)/(time(end)-time(1));
            % NOTE: Although the time stamps indicate a sampling frequency around
            % 7Hz it is rather about the following:
            % 12.4 Hz for Baseline shifts
            % 12.5 Hz for High frequency
            % 15.3 Hz for LRDominant
            % 15.5 Hz for Sinusoidal
            % 12.6 Hz for Typical Lung
            
            outputFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\Varian\Varian_Method_' method '_Plan_' num2str(plan) '_' traceName '.mat'];
            
            save(outputFile,'trackingResult')
        end
    end
end



%*************************************************************
% PART 2: MCW submission
%*************************************************************

if 0
    
    motionType{1} = 'BaselineShift';
    motionType{2} = 'HighFrequency';
    motionType{3} = 'LRDominant';
    motionType{4} = 'Sinusoidal';
    motionType{5} = 'TypicalLung';
    
    for motionNo = 1:10
        
        if motionNo <= 5
            dataDir = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\MCW\LowerTumor\' motionType{motionNo} '_Tx'];
        elseif motionNo <= 10
            dataDir = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\MCW\UpperTumor\' motionType{motionNo-5} '_Tx'];
        end
        
        % ExpNo 7 and 8 have several fragments. Choose the longest one:
        if motionNo == 7  % Se
            dataFile = 'Frag6_matlabresults.xlsx';
        elseif motionNo == 8
            dataFile = 'Frag10_matlabresults.xlsx';
        else
            dataFile = 'Frag2_matlabresults.xlsx';
        end
        
        sheet = 'Sheet1';
        
        timeData = readtable([dataDir '\' dataFile],'Sheet',sheet,'Range','A3:A100000');
        posData = readmatrix([dataDir '\' dataFile],'Sheet',sheet,'Range','B3:D100000');
        
        trackingResult = posData;
        
        figure(motionNo)
        plot(trackingResult)
        
        %    samplingFreq = length(time)/(time(end)-time(1));
        samplingFreq = 95;
        
        if motionNo <= 5
            outputFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\MCW\analyzeMATHCinput\MCW_LowerTumor_' motionType{motionNo} '_Tx.mat'];
        elseif motionNo <= 10
            outputFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\MCW\analyzeMATHCinput\MCW_UpperTumor_' motionType{motionNo-5} '_Tx.mat'];
        end
        save(outputFile,'trackingResult')
    end
end


%*************************************************************
% PART 3: MMC submission
%*************************************************************

if 0
    
    traceName{1} = 'INF_BaselineShift';
    traceName{2} = 'INF_HighFrequency';
    traceName{3} = 'INF_LRDominant';
    traceName{4} = 'INF_Sinusoidal';
    traceName{5} = 'INF_TypicalLung';
    traceName{6} = 'SUP_BaselineShift';
    traceName{7} = 'SUP_HighFrequency';
    traceName{8} = 'SUP_LRDominant';
    traceName{9} = 'SUP_Sinusoidal';
    traceName{10} = 'SUP_TypicalLung';
    
    sheet = 'TLTS';
    
    for motionNo = 1:10
        dataFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\MMC\' traceName{motionNo} '_Tx\' traceName{motionNo} '_Tx.xlsx'];
        
        timeData = readtable(dataFile,'Sheet',sheet,'Range','A3:A100000');
        posData = readmatrix(dataFile,'Sheet',sheet,'Range','B2:D100000');
        
        trackingResult = posData;
        
        figure(motionNo)
        plot(trackingResult)
        
        %    samplingFreq = length(time)/(time(end)-time(1));
        samplingFreq = 95;
        
        outputFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\MMC\analyzeMATHCinput\MMC_' traceName{motionNo} '.mat'];
        save(outputFile,'trackingResult')
    end
    
    iuoiuo
end



%*************************************************************
% PART 4: UMN submission
%*************************************************************

if 0
    
    traceName{1} = 'Baseline shift';
    traceName{2} = 'High Frequency';
    traceName{3} = 'Lateral dominant';
    traceName{4} = 'Sinusoidal';
    traceName{5} = 'Typical Lung';
    
    
    for motionNo = 1:5
        for isoNo = 1:3
            dataFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\UMN\' traceName{motionNo} '\Motion Tracking Results\' traceName{motionNo} ' Iso' num2str(isoNo) '.txt'];
            
            data = readmatrix(dataFile);
            
            timeData = data(:,1);
            time = timeData - timeData(1);
            
            posData = data(:,2:4);
            
            % According to the headlines in the data file from UMN, the
            % data are as follows: Time LR AP SI
            % In addition to this, it seems like the first axis (LR)
            % has wrong sign. Therefore the following conversion:
            
            clear trackingResult
            trackingResult(:,1) = -posData(:,1);
            trackingResult(:,2) = posData(:,3);
            trackingResult(:,3) = posData(:,2);
            
            figure(motionNo)
            plot(time,trackingResult)
            
            samplingFreq = length(time)/(time(end)-time(1));  % This is about 13.7 Hz for UMN
            
            outputFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\UMN\analyzeMATHCinput\UMN_Iso' num2str(isoNo) '_' traceName{motionNo} '.mat'];
            
            save(outputFile,'trackingResult')
        end
    end
end



%*************************************************************
% PART 5: RNSH submission
%*************************************************************

if 1
    
    traceName{1} = 'BaselineShift';
    traceName{2} = 'HighFreq';
    traceName{3} = 'LRDominant';
    traceName{4} = 'Sinusoidal';
    traceName{5} = 'TypicalLung';
    
    
    for planNo = 1:2
        for traceNo = 1:5
            dataFile = ['A:\MCT\MAGIK_Development\MATCH\Result analysis\RNSH\Motion tracking results\MATCHResultsSubmission_Plan' num2str(planNo) '_' traceName{traceNo} '.xlsx'];
            
            data = readmatrix(dataFile);
            
            imageNum = data(:,1);
            posData = data(:,2:4);
            
            clear trackingResult
            trackingResult(imageNum,1) = posData(:,1);
            trackingResult(imageNum,2) = posData(:,2);
            trackingResult(imageNum,3) = posData(:,3);
            trackingResult(1:imageNum-1,:)=[];
            trackingResult(trackingResult==0)=nan;
            figure(10* planNo + traceNo)
            plot(trackingResult)
            
             
               
            outputFile = ['A:\MCT\MAGIK_Development\MATCH\Result analysis\RNSH\Motion tracking results\New\RNSH_Plan' num2str(planNo) '_' traceName{traceNo} '.mat'];
            
            save(outputFile,'trackingResult')
        end
    end
end



%*************************************************************
% PART 6: BCCancer submission
%*************************************************************

if 0
    % This trace is very fragmented into small pieces. 
    % To get reasonable results with AnalyzeMATCH.m, one long ground truth
    % motion was used and the BCCancer submission was pieced together,
    % using segments of NaNs with lenghts at maximized the correlation with
    % ground truth motion.
    
    
    traceName{1} = 'BaselineShift';
    traceName{2} = 'LRDominant';
    traceName{3} = 'TypicalLung';
    
    
    for PTV = 2 % 1 or 2
        for traceNo = 1
            dataFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\BCCancer\New submission\Combined_BEAMControl_Files\Combine_BeamControl_PTV' num2str(PTV) '_' traceName{traceNo} '.xls'];
      
            groundTruthFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\MotionTraces B\ContinuouslyRepeatedMotionTracesB\' traceName{traceNo} '_Tx_repeated.txt'];
            fileID = fopen(groundTruthFile,'r');
            fgetl(fileID);
            SigKv = textscan(fileID,'%f\t%f\t%f\n'); % Read the motion data
            fclose(fileID);
            GTsignal = cell2mat(SigKv);
            GTtime = 0:0.02:ceil(length(GTsignal)/50);
            GTtime = GTtime(1:length(GTsignal));
            
         
            data = readmatrix(dataFile);
            
            timeData = data(:,1);
            time = timeData - timeData(1);
            time = time/1000;
            posData = data(:,5:7);
            
            figure(110)
            plot(posData)
            
            % Manually remove clearly wrong phantom position data where the phantom transfers from one repetition of the motion track to the next
            % Also specify approximate time for the first sample along the ground truth (GT) trajectory.
            if PTV == 1
                if traceNo == 1
                   posData = posData([1:9120 9420:15970 16320:end],:);
                   time = time([1:9120 9420:15970 16320:end]);
                   timeForFirstSample = 66;
                elseif traceNo == 2
                   posData = posData([1:4620 4850:16600 16820:19540 19770:28060 28190:end],:);
                   time = time([1:4620 4850:16600 16820:19540 19770:28060 28190:end]);
                   timeForFirstSample = 204.5;
                elseif traceNo == 3
                   posData = posData([1:525 591:7367 7536:end],:);
                   time = time([1:525 591:7367 7536:end]);
                   timeForFirstSample = 272;
                end
            elseif PTV == 2
               if traceNo == 1
                   posData = posData([203:26100 28070:end],:);
                   time = time([203:26100 28070:end]);
                   timeForFirstSample = 87;
                elseif traceNo == 2
                   posData = posData([304:20350 20580:end],:);
                   time = time([304:20350 20580:end]);
                   timeForFirstSample = 38;
                elseif traceNo == 3
                   posData = posData([1:15960 16150:22580 22730:end],:);
                   time = time([1:15960 16150:22580 22730:end]);
                   timeForFirstSample = 56;
                end
            end
            
            trackingResultLR = posData(:,1);
            trackingResultSI = posData(:,2);
            trackingResultAP = posData(:,3);
    
            
            
            figure(10* PTV + traceNo)
            plot(time,posData)
            
      if traceNo == 1         
          samplingFreq = 52.5;  
      elseif traceNo == 2         
          samplingFreq = 52.5;
      elseif traceNo == 3         
          samplingFreq = 51.6;
      end
      
      
      timeStep = 1/samplingFreq;
      
            timeIncrements = time(2:end) - time(1:end-1);
            
            figure(2)
            plot(timeIncrements)
            
            indInterruptions = find (timeIncrements > 3);  % Assume that steps >3s are caused by interruptions in the sampling
            interruptDurations = timeIncrements(indInterruptions);
            
            % Some manual assignments of pauses in cases where it is not found well automatically:
             if PTV == 1 && traceNo == 1
                 interruptDurations(8) = 102;
             end
             if PTV == 1 && traceNo == 2
                 interruptDurations(2) = 190;
                 interruptDurations(8) = 204;
                 interruptDurations(14) = 44;
             end
             if PTV == 2 && traceNo == 1
                 interruptDurations(5) = 322;
                 interruptDurations(9) = 56;
             end
             if PTV == 2 && traceNo == 3
                 interruptDurations(2) = 64;
             end
                 
            
            nIntervals = length(indInterruptions) + 1;
            indIntervals = [1 indInterruptions' length(timeIncrements)]';
            

           % samplingFreq = 1/timeStep(1);  % This is maybe about 52.6 Hz for BBCancer.
                                           % Best result with typical lung
                                           % when using 51.5Hz:
            
            timeNew = 0:1/samplingFreq:ceil(length(posData)*samplingFreq);
            timeNew = timeNew(1:length(posData));

            deltaTimeInitialGuess = [timeForFirstSample interruptDurations']';
            figure(10)
            if traceNo == 1 || traceNo == 2  % LR dominant and baseline shifts. Show LR motion
                plot(GTtime,GTsignal(:,1))
            else    % Use CC motion   
                plot(GTtime,GTsignal(:,2))
            end
            hold on
            
            deltaTimeFinalEstimation = [];
            nTimeStepsInterrupted = [];
            nTimeStepsInterruptedOriginalTimeScale = [];
            for i = 1:nIntervals                
                cumDeltaTime = sum(deltaTimeFinalEstimation(1:i-1)) + deltaTimeInitialGuess(i);                
                testTimes = cumDeltaTime-5:0.01:cumDeltaTime+5;
                for j = 1:length(testTimes)
                    if traceNo == 1 || traceNo == 2  % LR dominant and baseline shifts. Show LR motion
                        posGTonTimeScale = interp1(GTtime,GTsignal(:,1),timeNew(indIntervals(i)+1:indIntervals(i+1))+testTimes(j));
                        rmse(j) = rms(posGTonTimeScale - posData(indIntervals(i)+1:indIntervals(i+1),1)');
                    else   % Use CC motion 
                        posGTonTimeScale = interp1(GTtime,GTsignal(:,2),timeNew(indIntervals(i)+1:indIntervals(i+1))+testTimes(j));
                        rmse(j) = rms(posGTonTimeScale - posData(indIntervals(i)+1:indIntervals(i+1),2)');
                    end
                end
                if i == 1
                    deltaTimeFinalEstimation(i) = testTimes(find(rmse == min(rmse),1));
                else 
                    deltaTimeFinalEstimation(i) = testTimes(find(rmse == min(rmse),1)) - sum(deltaTimeFinalEstimation(1:i-1));
                end
                nTimeStepsInterrupted(i) = round(deltaTimeFinalEstimation(i)/timeStep);
                nTimeStepsInterruptedOriginalTimeScale(i) = round(deltaTimeFinalEstimation(i)/timeIncrements(1));
                cumDeltaTimeFinalEstimation = sum(deltaTimeFinalEstimation(1:i));
                if traceNo == 1 || traceNo == 2  % LR dominant and baseline shifts. Show LR motion
                    plot(timeNew(indIntervals(i)+1:indIntervals(i+1))+cumDeltaTimeFinalEstimation,posData(indIntervals(i)+1:indIntervals(i+1),1),'r')
                else
                    plot(timeNew(indIntervals(i)+1:indIntervals(i+1))+cumDeltaTimeFinalEstimation,posData(indIntervals(i)+1:indIntervals(i+1),2),'r')
                end
            end
            
               
         
            trackingResultLRout = trackingResultLR(1:indInterruptions(1));
            trackingResultSIout = trackingResultSI(1:indInterruptions(1));
            trackingResultAPout = trackingResultAP(1:indInterruptions(1));
            
            for i = 1:length(indInterruptions)
                missingPos = nan(nTimeStepsInterrupted(i+1),1);
                if i < length(indInterruptions)  
                    trackingResultLRout = [trackingResultLRout' missingPos' trackingResultLR(indInterruptions(i)+1:indInterruptions(i+1))']';
                    trackingResultSIout = [trackingResultSIout' missingPos' trackingResultSI(indInterruptions(i)+1:indInterruptions(i+1))']';
                    trackingResultAPout = [trackingResultAPout' missingPos' trackingResultAP(indInterruptions(i)+1:indInterruptions(i+1))']';
                else
                   trackingResultLRout = [trackingResultLRout' missingPos' trackingResultLR(indInterruptions(i)+1:end)']';
                    trackingResultSIout = [trackingResultSIout' missingPos' trackingResultSI(indInterruptions(i)+1:end)']';
                    trackingResultAPout = [trackingResultAPout' missingPos' trackingResultAP(indInterruptions(i)+1:end)']';
                end                   
            end
            
            
            timeOut = 0:1/samplingFreq:ceil(length(trackingResultSIout)*samplingFreq);
            timeOut = timeOut(1:length(trackingResultSIout));
   
                   
            figure(11)
            plot(GTtime,GTsignal(:,2))
            hold on
            plot(timeOut+deltaTimeFinalEstimation(1),trackingResultSIout)
           
            clear trackingResult
            trackingResult(:,1) = trackingResultLRout;
            trackingResult(:,2) = trackingResultSIout;
            trackingResult(:,3) = trackingResultAPout;
            
            figure(100* PTV + traceNo)
            plot(timeOut,trackingResult)
        
            outputFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\BCCancer\analyzeMATCHinput\BBCancer_PTV' num2str(PTV) '_' traceName{traceNo} '.mat'];
            
            save(outputFile,'trackingResult')
        end
    end
end


%*************************************************************
% PART 7: Stanford
%*************************************************************

if 0
    
    motionType{1} = '1_Sin';
    motionType{2} = '2_Normal';
    motionType{3} = '3_BaseLineShift';
    motionType{4} = '4_LRDominant';
    motionType{5} = '5_HighFreq';
    
    homeDir = 'D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\Stanford';
    
    % Stanford reported some offsets to be added to the submitted motion:
    offsetData = readmatrix([homeDir '\Shift for CK Traces at Stanford Dec 21 2020.xlsx']);
    
    
    
    for PTV = 1:2
        
        
        for traceNo = 1:5
            if PTV == 1
                traceDirPart1 = [homeDir '\' motionType{traceNo} '_PTV'];
            else
                traceDirPart1 = [homeDir '\' motionType{traceNo} '_PTV_2'];
            end
            
            offset = offsetData(2*traceNo-(2-PTV),2:4);
            
            subdirList = dir([traceDirPart1 '\tfdl*']);
            dataFile = [traceDirPart1 '\' subdirList.name '\\plan\frac\Predictor.log'];
            
            data = readmatrix(dataFile);
            
            pos = data(:,6:8);
            
            figure(1)
            plot( pos)
            
            %Remove initial part of trace with none or interrupted 3D motion estimation:
            if PTV == 1 && traceNo == 1
                startIndex = 16790;
            elseif PTV == 1 && traceNo == 4
                startIndex = 5200;
            elseif PTV == 1 && traceNo == 5
                startIndex = 4000;
            elseif PTV == 2 && traceNo == 1
                startIndex = 1600;
            elseif PTV == 2 && traceNo == 2
                startIndex = 3270;
            else
                startIndex = 1;
            end
            
            pos = pos(startIndex:end,:);
            time = data(:,4);
            time = time(startIndex:end);
            time = time - time(1);
            
            figure(2)
            plot(time, pos)
            
            samplingFreq = length(time)/(time(end)-time(1))  %25.9 Hz for CK
            
            clear trackingResult
            trackingResult(:,1) = pos(:,2) + offset(1);
            trackingResult(:,2) = -pos(:,1) - offset(2);
            trackingResult(:,3) = pos(:,3) + offset(3);
            
            if PTV == 1
                outputFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\Stanford\analyzeMATCHinput\Stanford_PTV1_' motionType{traceNo}  '.mat'];
            else
                outputFile = ['D:\PhD MSc projekter\MATCH Challenge 2020\Part B\ParticipantResults\Stanford\analyzeMATCHinput\Stanford_PTV2_' motionType{traceNo}  '.mat'];
            end
            
            save(outputFile,'trackingResult')
            
        end
    end
    
    
end


%*************************************************************
% PART 8: CDI
%*************************************************************

if 0
    
  % Used to find submitted traces:
    motionType{1} = 'baseline_shift';
    motionType{2} = 'high_frequency';
    motionType{3} = 'LR_dominant';
    %motionType{4} = 'sinusoidal';
    %motionType{5} = 'typical_lung';
    
  % Used to find GT traces:
    traceName{1} = 'BaselineShift';
    traceName{2} = 'HighFrequency';
    traceName{3} = 'LRDominant';            
    %traceName{4} = 'Sinusoidal';
    %traceName{5} = 'TypicalLung';            
    
    homeDir = 'A:\MCT\MAGIK_Development\MATCH\Result analysis\CDI';
    
     
    for PTV = 1:2        
        
        for traceNo = 1:3
            if PTV == 1
                 dataFile = [homeDir '\CAUDAL LESION\Log Files\caudal_' motionType{traceNo} '\Predictor.log'];
            else
                dataFile = [homeDir '\CRANIAL LESION\Log Files\cranial_' motionType{traceNo} '\Predictor.log'];
            end
                        
            data = readmatrix(dataFile);  
            pos = data(:,5:7);
%             pos1 = data(:,4:6);
%             pos2 = data(:,8:10);
%             pos1 = pos1 -mean(pos1);
%             pos2 = pos2 -mean(pos2);
            
%              RealdataFile = [homeDir '\CAUDAL LESION\Log Files\caudal_' motionType{traceNo} '\Modeler.log'];
%              data = readmatrix(RealdataFile);  
%                pos1 = data(:,8:10);
%             data(1,:)=[];
%             pos = data(:,5:7);
            
            RotationMatrix = rotz(45);
            pos = (RotationMatrix*pos')';
            %NewOffset = (RotationMatrix * mean(pos)')';
            %figure; plot(pos(:,1)); hold on; plot(pos1(:,1))
%             for c=1:length(pos)
%             pos(c,:)= -(RotationMatrix * (pos1(c,:)-mean(pos1))')' + NewOffset;
%             end
            
% 
             %hold on; hold on; plot3(pos2(:,1),pos2(:,2),pos2(:,3)); hold on; plot3(pos1(:,1),pos1(:,2),pos1(:,3)); hold on; plot3(pos(:,1),pos(:,2),pos(:,3));
%             
%             coeff = pca(pos,'NumComponents',1)
%             X = [-10:10];
%             firstPCA = X .* coeff;
%             hold on; plot3(firstPCA(1,:)',firstPCA(2,:)',firstPCA(3,:))

            %figure;plot(pos)
            
            %Remove initial part of trace with none or interrupted 3D motion estimation:
            if PTV == 1
                if traceNo == 1 
                    startIndex = 9710; % The motion phantom apparently restarted this trace prematurely beofr this start index
                    endIndex = length(pos);
                elseif traceNo == 2
                    startIndex = 11800;
                    endIndex = length(pos);
                elseif traceNo == 5
                    startIndex = 510;
                    endIndex = 17980;
                else    
                    startIndex = 2;
                    endIndex = length(pos);
                end
            elseif PTV == 2
                if traceNo == 2  % NOTE: IN this case CDI used motion trace LRDominant instead of HighFrequency
                    startIndex = 2;
                    endIndex = 20000;
                elseif traceNo == 3
                    startIndex = 1461;
                    endIndex = 20200;
                else    
                    startIndex = 2;
                    endIndex = length(pos);
                end
             end
            
            pos = pos(startIndex:endIndex,:);
             time = data(:,2);
             
            % figure(4)
             %plot(time)
             
            time = time(startIndex:endIndex);
            time = time - time(1);
            
            figure
            plot(pos); title(traceName{traceNo})
            
            samplingFreq = length(time)/(time(end)-time(1));  %25.9 Hz for CK
            
            
            % TEST for trace 1:
            
            groundTruthFile = ['A:\MCT\MAGIK_Development\Processed_Data\Phantom\MATCH Part B MotionTraces\' traceName{traceNo} '_Tx.txt'];
            fileID = fopen(groundTruthFile,'r');
            fgetl(fileID);
            SigKv = textscan(fileID,'%f\t%f\t%f\n'); % Read the motion data
            fclose(fileID);
            GTsignal = cell2mat(SigKv);
            GTtime = 0:0.02:ceil(length(GTsignal)/50);
            GTtime = GTtime(1:length(GTsignal));
      
            
            %figure(100)
            %plot(GTtime,GTsignal)
            
            round(mean(GTsignal),2);
           
            
            clear trackingResult
            trackingResult(:,1) = pos(:,2);
            trackingResult(:,2) = -pos(:,1);
            trackingResult(:,3) = pos(:,3);
%             trackingResult(:,1) = pos(:,2);
%             trackingResult(:,2) = -pos(:,1);
%             trackingResult(:,3) = pos(:,3);
            
            %figure(PTV*10 + traceNo)
            %plot(time,trackingResult)
            
            disp(['The observed shift for ',motionType{traceNo},' is in Patient Coordinates [LR|SI|AP] : ', num2str(round(mean(trackingResult),1)),' mm ']);%and in Robot Coordiantes [SI|LR|AP]: ', num2str(round((rotz(-45) * mean(pos)')',1)),' mm.'])
            if PTV == 1
                outputFile = ['A:\MCT\MAGIK_Development\MATCH\Result analysis\CDI\analyzeMATCHinput\CDI_CAUDAL_LESION_' motionType{traceNo}  '.mat'];
            else
                outputFile = ['A:\MCT\MAGIK_Development\MATCH\Result analysis\CDI\analyzeMATCHinput\CDI_CRANIAL_LESION_' motionType{traceNo}  '.mat'];
            end
            
            save(outputFile,'trackingResult')
            
        end
    end
    
    
end


