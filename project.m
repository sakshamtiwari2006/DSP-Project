function gui

clc;

%% ================= MAIN / CONFIGURATION WINDOW =================
mainFig=uifigure('Name','ECG R-Peak Detection System',...
    'Position',[60 35 1450 850]);

mainGrid=uigridlayout(mainFig,[2 2]);
mainGrid.RowHeight={70,'1x'};
mainGrid.ColumnWidth={560,'1x'};

header=uilabel(mainGrid,'Text','ECG R-PEAK DETECTION AND THRESHOLDING',...
    'FontSize',24,'FontWeight','bold','HorizontalAlignment','center');
header.Layout.Row=1; header.Layout.Column=[1 2];

%% ---------- LEFT: ALL SELECTIONS ----------
left=uipanel(mainGrid,'Title','Input and Analysis Options','FontWeight','bold');
left.Layout.Row=2; left.Layout.Column=1;

lg=uigridlayout(left,[29 2]);
lg.RowHeight={25,32,34,32,32,32,25,32,25,32,25,32,25,32,25,32,25,32,25,32,25,32,25,32,25,32,25,48,90};
lg.ColumnWidth={215,'1x'};

uilabel(lg,'Text','Data source:','FontWeight','bold');
source=uidropdown(lg,'Items',{'MIT-BIH via WFDB','MIT-BIH local .dat','MAT file'},...
    'Value','MIT-BIH via WFDB');
source.Layout.Row=1; source.Layout.Column=2;

uilabel(lg,'Text','Record / file:');
fileField=uieditfield(lg,'text','Value','mitdb/100');
fileField.Layout.Row=2; fileField.Layout.Column=2;

browse=uibutton(lg,'push','Text','BROWSE FILE','ButtonPushedFcn',@browseFile);
browse.Layout.Row=3; browse.Layout.Column=[1 2];
browse.Enable='off';

uilabel(lg,'Text','Channel:');
channel=uieditfield(lg,'numeric','Value',1,'Limits',[1 2],...
    'RoundFractionalValues','on');
channel.Layout.Row=4; channel.Layout.Column=2;

uilabel(lg,'Text','Start time (s):');
startSec=uieditfield(lg,'numeric','Value',0,'Limits',[0 Inf]);
startSec.Layout.Row=5; startSec.Layout.Column=2;

uilabel(lg,'Text','Duration (s):');
durationSec=uieditfield(lg,'numeric','Value',60,'Limits',[1 Inf]);
durationSec.Layout.Row=6; durationSec.Layout.Column=2;

uilabel(lg,'Text','Thresholding:','FontWeight','bold');
threshold=uidropdown(lg,'Items',{'3-Level Adaptive','3-Level Fixed','Single-Level'},...
    'Value','3-Level Adaptive');
threshold.Layout.Row=7; threshold.Layout.Column=2;

uilabel(lg,'Text','QRS feature:','FontWeight','bold');
featureMethod=uidropdown(lg,'Items',{'Wavelet + Hilbert','Classical derivative'},...
    'Value','Wavelet + Hilbert');
featureMethod.Layout.Row=8; featureMethod.Layout.Column=2;

compare=uicheckbox(lg,'Text','Compare all 3 thresholding methods','Value',true);
compare.Layout.Row=9; compare.Layout.Column=[1 2];

uilabel(lg,'Text','Low cutoff (Hz):');
lowCut=uieditfield(lg,'numeric','Value',0.5,'Limits',[0.01 Inf]);
lowCut.Layout.Row=10; lowCut.Layout.Column=2;

uilabel(lg,'Text','High cutoff (Hz):');
highCut=uieditfield(lg,'numeric','Value',40,'Limits',[0.1 Inf]);
highCut.Layout.Row=11; highCut.Layout.Column=2;

uilabel(lg,'Text','Filter order:');
order=uieditfield(lg,'numeric','Value',3,'Limits',[1 10],...
    'RoundFractionalValues','on');
order.Layout.Row=12; order.Layout.Column=2;

uilabel(lg,'Text','Integration window (ms):');
intWin=uieditfield(lg,'numeric','Value',150,'Limits',[20 500]);
intWin.Layout.Row=13; intWin.Layout.Column=2;

uilabel(lg,'Text','Refractory period (ms):');
refractory=uieditfield(lg,'numeric','Value',200,'Limits',[100 500]);
refractory.Layout.Row=14; refractory.Layout.Column=2;

uilabel(lg,'Text','Adaptive alpha:');
alpha=uieditfield(lg,'numeric','Value',0.125,'Limits',[0.001 1]);
alpha.Layout.Row=15; alpha.Layout.Column=2;

uilabel(lg,'Text','High level fraction:');
highFrac=uieditfield(lg,'numeric','Value',0.50,'Limits',[0.01 1]);
highFrac.Layout.Row=16; highFrac.Layout.Column=2;

uilabel(lg,'Text','Normal level fraction:');
normalFrac=uieditfield(lg,'numeric','Value',0.25,'Limits',[0.01 1]);
normalFrac.Layout.Row=17; normalFrac.Layout.Column=2;

uilabel(lg,'Text','Search-back fraction:');
searchFrac=uieditfield(lg,'numeric','Value',0.125,'Limits',[0.001 1]);
searchFrac.Layout.Row=18; searchFrac.Layout.Column=2;

uilabel(lg,'Text','Search-back RR ratio:');
searchRatio=uieditfield(lg,'numeric','Value',1.50,'Limits',[1.05 4]);
searchRatio.Layout.Row=19; searchRatio.Layout.Column=2;

uilabel(lg,'Text','R-peak search radius (ms):');
searchRadius=uieditfield(lg,'numeric','Value',75,'Limits',[20 150]);
searchRadius.Layout.Row=20; searchRadius.Layout.Column=2;

validate=uicheckbox(lg,'Text','Use SYNTHETIC demo metrics','Value',true);
validate.Layout.Row=21; validate.Layout.Column=[1 2];

uilabel(lg,'Text','Annotation tolerance (ms):');
tolerance=uieditfield(lg,'numeric','Value',150,'Limits',[20 500]);
tolerance.Layout.Row=22; tolerance.Layout.Column=2;

validate.Layout.Row=21; validate.Layout.Column=[1 2];

showOriginal=uicheckbox(lg,'Text','Show original ECG in Results','Value',true);
showOriginal.Layout.Row=23; showOriginal.Layout.Column=[1 2];

showStages=uicheckbox(lg,'Text','Open processing stages window','Value',false);
showStages.Layout.Row=24; showStages.Layout.Column=[1 2];

showErrors=uicheckbox(lg,'Text','Show comparison FP/FN plot','Value',true);
showErrors.Layout.Row=25; showErrors.Layout.Column=[1 2];

exportCSV=uicheckbox(lg,'Text','Enable CSV export in Results','Value',true);
exportCSV.Layout.Row=26; exportCSV.Layout.Column=[1 2];

run=uibutton(lg,'push','Text','RUN ANALYSIS','FontSize',18,...
    'FontWeight','bold','ButtonPushedFcn',@runAnalysisCallback);
run.Layout.Row=27; run.Layout.Column=[1 2];

help=uitextarea(lg,'Editable','off','Value',{...
    'Select the ECG source, thresholding method and parameters, then click RUN ANALYSIS.',...
    '3-Level Adaptive = thresholds update with signal/noise estimates.',...
    '3-Level Fixed = High/Normal/Search-back thresholds are initialized once and remain fixed.',...
    'Single-Level = one adaptive threshold.',...
    'Wavelet + Hilbert = SWT (sym2, level 4) + Hilbert envelope + feature fusion.',...
    'All 3 thresholding methods use the SAME QRS feature for a fair comparison.',...
    'Enable Comparison to run and compare all three methods on the same segment.',...
    'SYNTHETIC demo mode replaces validation metrics in the results table.'});
help.Layout.Row=28; help.Layout.Column=[1 2];

%% ---------- RIGHT: SUMMARY / QUICK INFORMATION ----------
right=uipanel(mainGrid,'Title','Configuration Summary','FontWeight','bold');
right.Layout.Row=2; right.Layout.Column=2;
rg=uigridlayout(right,[5 1]);
rg.RowHeight={50,'1x',150,100,65};

status=uilabel(rg,'Text','Status: Ready','FontSize',16,'FontWeight','bold');

summary=uitextarea(rg,'Editable','off');
summary.Layout.Row=2;

note=uitextarea(rg,'Editable','off','Value',{...
    'RECOMMENDED STARTING POINT',...
    'Record: mitdb/100',...
    'Channel: 1',...
    'Duration: 60 s',...
    'Threshold: 3-Level Adaptive',...
    'QRS feature: Wavelet + Hilbert',...
    'Band-pass: 0.5-40 Hz',...
    'Integration: 150 ms',...
    'Refractory: 200 ms',...
    'Comparison: OFF for first test, ON to compare all three.'});
note.Layout.Row=3;

instruction=uitextarea(rg,'Editable','off','Value',{...
    'RESULTS',...
    'After RUN ANALYSIS, a separate Results window opens.',...
    'It contains ECG/R-peaks, processing waveforms, thresholds, RR/HR parameters and validation metrics.',...
    'If Comparison is ON, a comparison table and performance plots are also shown.'});
instruction.Layout.Row=4;

runRight=uibutton(rg,'push', ...
    'Text','RUN ANALYSIS', ...
    'FontSize',18,'FontWeight','bold', ...
    'ButtonPushedFcn',@runAnalysisCallback);
runRight.Layout.Row=5;

%% ---------- LIVE SUMMARY ----------
controls={source,fileField,channel,startSec,durationSec,threshold,featureMethod,compare,...
    lowCut,highCut,order,intWin,refractory,alpha,highFrac,normalFrac,...
    searchFrac,searchRatio,searchRadius,validate,tolerance,showOriginal,showStages,...
    showErrors,exportCSV};
for kk=1:numel(controls)
    try
        controls{kk}.ValueChangedFcn=@(~,~)updateSummary();
    catch
    end
end

source.ValueChangedFcn=@sourceChanged;

updateSummary();

function sourceChanged(~,~)
    if strcmp(source.Value,'MIT-BIH via WFDB')
        fileField.Value='mitdb/100';
        browse.Enable='off';
    else
        fileField.Value='';
        browse.Enable='on';
    end
    updateSummary();
end

function browseFile(~,~)
    if strcmp(source.Value,'MIT-BIH local .dat')
        [f,p]=uigetfile({'*.dat','MIT-BIH DAT files (*.dat)'},...
            'Select MIT-BIH .dat file');
        if isequal(f,0), return; end
        fileField.Value=fullfile(p,f);
        [~,bn]=fileparts(f);
        hea=fullfile(p,[bn '.hea']);
        if ~isfile(hea)
            uialert(mainFig,['Matching .hea file was not found:' newline hea],...
                'Missing Header');
        end
    elseif strcmp(source.Value,'MAT file')
        [f,p]=uigetfile({'*.mat','MAT files (*.mat)'},'Select ECG MAT file');
        if isequal(f,0), return; end
        fileField.Value=fullfile(p,f);
    end
    updateSummary();
end

function updateSummary()
    summary.Value={...
        'CURRENT CONFIGURATION',...
        ['Source: ' source.Value],...
        ['Record/file: ' fileField.Value],...
        sprintf('Channel: %d',round(channel.Value)),...
        sprintf('Segment: %.1f s to %.1f s',startSec.Value,startSec.Value+durationSec.Value),...
        ['QRS feature: ' featureMethod.Value],...
        ['Thresholding: ' threshold.Value],...
        ['Comparison: ' onOff(compare.Value)],...
        sprintf('Band-pass: %.2f - %.2f Hz | order %d',lowCut.Value,highCut.Value,round(order.Value)),...
        sprintf('Integration: %.0f ms | Refractory: %.0f ms',intWin.Value,refractory.Value),...
        sprintf('Alpha: %.3f | H/N/SB: %.3f / %.3f / %.3f',alpha.Value,highFrac.Value,normalFrac.Value,searchFrac.Value),...
        sprintf('Search-back RR ratio: %.2f | R search: %.0f ms',searchRatio.Value,searchRadius.Value),...
        ['Metrics mode: ' onOff(validate.Value) ' (SYNTHETIC DEMO)'],...
        ['Processing stages window: ' onOff(showStages.Value)],...
        ['FP/FN plot: ' onOff(showErrors.Value)],...
        ['CSV export: ' onOff(exportCSV.Value)]};
end

function x=onOff(v)
    if v, x='ON'; else, x='OFF'; end
end

function runAnalysisCallback(~,~)
    try
        if lowCut.Value>=highCut.Value
            error('Low cutoff must be smaller than high cutoff.');
        end
        if highCut.Value>=5000
            error('High cutoff value is not valid.');
        end
        if searchFrac.Value>=normalFrac.Value || normalFrac.Value>=highFrac.Value
            error('Threshold fractions must satisfy Search-back < Normal < High.');
        end
        if isempty(strtrim(fileField.Value))
            error('Select an ECG file or enter a WFDB record name.');
        end

        run.Enable='off';
        runRight.Enable='off';
        status.Text='Status: Running analysis...';
        drawnow;

        s.source=source.Value;
        s.file=strtrim(fileField.Value);
        s.channel=round(channel.Value);
        s.startSec=startSec.Value;
        s.durationSec=durationSec.Value;
        s.thresholdMethod=threshold.Value;
        s.featureMethod=featureMethod.Value;
        s.comparison=compare.Value;
        s.lowCut=lowCut.Value;
        s.highCut=highCut.Value;
        s.filterOrder=round(order.Value);
        s.integrationMs=intWin.Value;
        s.refractoryMs=refractory.Value;
        s.alpha=alpha.Value;
        s.highFrac=highFrac.Value;
        s.normalFrac=normalFrac.Value;
        s.searchFrac=searchFrac.Value;
        s.searchRatio=searchRatio.Value;
        s.searchRadiusMs=searchRadius.Value;
        s.validate=validate.Value;
        s.toleranceMs=tolerance.Value;
        s.showOriginal=showOriginal.Value;
        s.showStages=showStages.Value;
        s.showErrors=showErrors.Value;
        s.exportCSV=exportCSV.Value;

        result=performAnalysis(s);
        status.Text='Status: Complete. Results window opened.';
        run.Enable='on';
        createResultsWindow(result,s);
    catch ME
        run.Enable='on';
        runRight.Enable='on';
        status.Text='Status: Error.';
        uialert(mainFig,ME.message,'Analysis Error');
    end
end

end

%% ================= ANALYSIS ENGINE =================
function result=performAnalysis(s)

    switch s.source
        case 'MIT-BIH via WFDB'
            if exist('rdsamp','file')~=2
                error(['rdsamp was not found. Install the WFDB MATLAB Toolbox and make sure it is on the MATLAB path.']);
            end
            [ecg,Fs,recordBase]=rdsamp(s.file,s.channel);
        case 'MIT-BIH local .dat'
            [ecg,Fs,recordBase]=readMITBIH212(s.file,s.channel);
        case 'MAT file'
            [ecg,Fs,recordBase]=readMATSignal(s.file,s.channel);
        otherwise
            error('Unknown data source.');
    end

    ecg=double(ecg(:));
    ecg=fillmissing(ecg,'linear','EndValues','nearest');
    ecg=ecg-median(ecg,'omitnan');

    i1=max(1,floor(s.startSec*Fs)+1);
    i2=min(numel(ecg),floor((s.startSec+s.durationSec)*Fs));
    if i2<=i1
        error('Requested segment is outside the available ECG.');
    end

    ecgSeg=ecg(i1:i2);
    t=(0:numel(ecgSeg)-1)'/Fs;

    if s.lowCut<=0 || s.highCut>=Fs/2
        error('Cutoffs must satisfy 0 < low < high < Fs/2. Actual Fs = %.2f Hz.',Fs);
    end

    [b,a]=butter(s.filterOrder,[s.lowCut s.highCut]/(Fs/2),'bandpass');
    filtered=filtfilt(b,a,ecgSeg);

    [waveletDetail,hilbertEnvelope,fusedFeature]=waveletHilbertFeature(filtered,Fs);

    derivative=zeros(size(filtered));
    if numel(filtered)>=5
        derivative(3:end-2)=(Fs/8).*(-filtered(1:end-4)-2*filtered(2:end-3)+...
            2*filtered(4:end-1)+filtered(5:end));
    end
    squared=derivative.^2;
    win=max(1,round(s.integrationMs*Fs/1000));
    integrated=movmean(squared,[win-1 0]);

    if strcmp(s.featureMethod,'Wavelet + Hilbert')
        detectionFeature=fusedFeature;
    else
        detectionFeature=integrated;
    end

    methods={'3-Level Adaptive','3-Level Fixed','Single-Level'};
    if s.comparison
        runMethods=methods;
    else
        runMethods={s.thresholdMethod};
    end

    all=repmat(emptyMethodResult(),1,numel(runMethods));
    for k=1:numel(runMethods)
        method=runMethods{k};
        switch method
            case '3-Level Adaptive'
                [cand,levels,thH,thN,thSB]=adaptiveThreeLevelDetector(detectionFeature,Fs,...
                    s.alpha,s.highFrac,s.normalFrac,s.searchFrac,s.refractoryMs/1000,s.searchRatio);
            case '3-Level Fixed'
                [cand,levels,thH,thN,thSB]=fixedThreeLevelDetector(detectionFeature,Fs,...
                    s.highFrac,s.normalFrac,s.searchFrac,s.refractoryMs/1000,s.searchRatio);
            case 'Single-Level'
                [cand,th]=singleThresholdDetector(integrated,Fs,s.alpha,s.refractoryMs/1000);
                levels=2*ones(size(cand)); thH=th; thN=th; thSB=th;
        end

        rPeaks=localizeRPeaks(filtered,cand,Fs,s.searchRadiusMs/1000);
        rPeaks=enforceRefractory(rPeaks,filtered,round(s.refractoryMs*Fs/1000));
        [rr,bpm,meanBPM]=calculateHR(rPeaks,Fs);

        all(k).name=method;
        all(k).rPeaks=rPeaks;
        all(k).levelUsed=levels;
        all(k).rr=rr;
        all(k).bpm=bpm;
        all(k).meanBPM=meanBPM;
        all(k).meanRR=mean(rr,'omitnan');
        all(k).thHigh=thH;
        all(k).thNormal=thN;
        all(k).thSB=thSB;
        all(k).numPeaks=numel(rPeaks);
        all(k).numCandidates=numel(cand);
    end

    validationAvailable=false;
    validationMessage='Synthetic demo metrics disabled.';

    if s.validate
        all=applySyntheticDemoMetrics(all);
        validationAvailable=true;
        validationMessage='SYNTHETIC DEMO: performance metrics are randomly generated for GUI demonstration.';
    end

    idx=find(strcmp(runMethods,s.thresholdMethod),1);
    if isempty(idx), idx=1; end

    result.ecg=ecgSeg;
    result.filtered=filtered;
    result.derivative=derivative;
    result.squared=squared;
    result.integrated=integrated;
    result.waveletDetail=waveletDetail;
    result.hilbertEnvelope=hilbertEnvelope;
    result.fusedFeature=fusedFeature;
    result.detectionFeature=detectionFeature;
    result.featureMethod=s.featureMethod;
    result.t=t;
    result.Fs=Fs;
    result.recordBase=recordBase;
    result.allResults=all;
    result.selected=all(idx);
    result.validationAvailable=validationAvailable;
    result.validationMessage=validationMessage;
end

function r=emptyMethodResult()
    r=struct('name','','rPeaks',[],'levelUsed',[],'rr',[],'bpm',[],...
        'meanBPM',NaN,'meanRR',NaN,'thHigh',[],'thNormal',[],'thSB',[],...
        'numPeaks',0,'numCandidates',0,'TP',NaN,'FP',NaN,'FN',NaN,'sensitivity',NaN,...
        'PPV',NaN,'accuracy',NaN,'F1',NaN);
end

%% ================= SYNTHETIC DEMO METRICS HELPERS =================

function results=applySyntheticDemoMetrics(results)

rng('shuffle');

for k=1:numel(results)

    [TP,FP,FN]=generateDemoMetrics();

    results(k).TP=TP;
    results(k).FP=FP;
    results(k).FN=FN;

    results(k).numPeaks=TP+FP;

    results(k).sensitivity=100*TP/(TP+FN+eps);
    results(k).PPV=100*TP/(TP+FP+eps);
    results(k).accuracy=100*TP/(TP+FP+FN+eps);
    results(k).F1=100*(2*TP)/(2*TP+FP+FN+eps);

end

end


function [TP,FP,FN]=generateDemoMetrics()

base=randi([100 200]);

tpLow=ceil(0.60*base);
tpHigh=floor(0.80*base);

fpLow=ceil(0.20*base);
fpHigh=floor(0.40*base);

fnLow=ceil(0.20*base);
fnHigh=floor(0.40*base);

TP=randi([tpLow tpHigh]);
FP=randi([fpLow fpHigh]);
FN=randi([fnLow fnHigh]);

end


function [results,available,msg]=validateMethods(results,s,Fs,i1,nSeg)

    available=false;
    msg='';

    if ~s.validate
        msg='Validation disabled by user.';
        return;
    end

    if ~startsWith(s.source,'MIT-BIH')
        msg='Validation is available only for MIT-BIH data.';
        return;
    end

    if strcmp(s.source,'MIT-BIH via WFDB')
        record=s.file;
        localAnnotation='';
    else
        [folder,base,~]=fileparts(s.file);
        record=fullfile(folder,base);
        localAnnotation=fullfile(folder,[base '.atr']);
    end

    ann=[];
    typ=[];
    rdannMessage='';

    if exist('rdann','file')==2
        try
            [ann,typ]=rdann(record,'atr');
            ann=double(ann(:));

            if ischar(typ)
                typ=typ(:);
            elseif isstring(typ)
                typ=char(typ(:));
            elseif iscell(typ)
                typ=char(typ);
                typ=typ(:);
            else
                typ=[];
            end

            if isempty(typ) || numel(typ)~=numel(ann)
                error('rdann returned incompatible annotation sample/symbol arrays.');
            end
        catch ME
            rdannMessage=ME.message;
            ann=[];
            typ=[];
        end
    else
        rdannMessage='rdann was not found on the MATLAB path.';
    end

    if isempty(ann) && strcmp(s.source,'MIT-BIH local .dat')
        if ~isfile(localAnnotation)
            msg=['Annotation file not found:' newline localAnnotation newline ...
                 'Keep the .atr file beside the .dat file.'];
            return;
        end
        try
            [ann,typ]=readMITBIHAnnotations(localAnnotation);
        catch ME
            msg=['Annotation validation failed.' newline ...
                 'WFDB/rdann message: ' rdannMessage newline ...
                 'Direct .atr reader error: ' ME.message];
            return;
        end
    end

    if isempty(ann)
        msg=['Unable to load MIT-BIH annotations.' newline ...
             'WFDB/rdann message: ' rdannMessage];
        return;
    end

    ann=round(double(ann(:)));
    typ=char(typ(:));

    beatSymbols='NLRBAaJSVErFfej/Q';
    keep=ismember(typ,beatSymbols);
    ann=ann(keep);

    ann=ann-i1+1;
    ann=ann(ann>=1 & ann<=nSeg);

    if isempty(ann)
        msg='No beat annotations were found inside the selected ECG segment.';
        return;
    end

    if isfield(s,'toleranceMs')
        tolMs=s.toleranceMs;
    else
        tolMs=150;
    end
    tol=round(tolMs*Fs/1000);

    for k=1:numel(results)
        [TP,FN,FP,Se,PPV,Acc,F1]=...
            evaluateDetection(results(k).rPeaks,ann,tol);

        results(k).TP=TP;
        results(k).FP=FP;
        results(k).FN=FN;
        results(k).sensitivity=100*Se;
        results(k).PPV=100*PPV;
        results(k).accuracy=100*Acc;
        results(k).F1=100*F1;
    end

    available=true;
    msg=sprintf('Validation successful: %d reference beats, +/- %.0f ms tolerance.',...
        numel(ann),tolMs);
end

function [samples,symbols]=readMITBIHAnnotations(fileName)

    fid=fopen(fileName,'rb','ieee-le');
    if fid<0
        error('Unable to open annotation file: %s',fileName);
    end
    cleanup=onCleanup(@()fclose(fid));

    b=fread(fid,inf,'uint8=>uint8');
    if isempty(b)
        error('Annotation file is empty.');
    end

    pos=1;
    currentSample=0;
    samples=zeros(0,1);
    symbols=char(zeros(0,1));

    codeToSymbol=containers.Map('KeyType','double','ValueType','char');
    codeToSymbol(1)='N';
    codeToSymbol(2)='L';
    codeToSymbol(3)='R';
    codeToSymbol(4)='A';
    codeToSymbol(5)='a';
    codeToSymbol(6)='J';
    codeToSymbol(7)='S';
    codeToSymbol(8)='V';
    codeToSymbol(9)='F';
    codeToSymbol(10)='(';
    codeToSymbol(11)=')';
    codeToSymbol(12)='p';
    codeToSymbol(13)='t';
    codeToSymbol(14)='u';
    codeToSymbol(15)='`';
    codeToSymbol(16)='~';
    codeToSymbol(17)='A';
    codeToSymbol(18)='a';
    codeToSymbol(19)='J';
    codeToSymbol(20)='S';
    codeToSymbol(21)='E';
    codeToSymbol(22)='j';
    codeToSymbol(23)='F';
    codeToSymbol(24)='e';
    codeToSymbol(25)='n';
    codeToSymbol(26)='?';
    codeToSymbol(27)='Q';
    codeToSymbol(28)='!';
    codeToSymbol(29)='x';
    codeToSymbol(30)='D';
    codeToSymbol(31)='|';
    codeToSymbol(32)='~';
    codeToSymbol(33)='s';
    codeToSymbol(34)='T';
    codeToSymbol(35)='*';
    codeToSymbol(36)='D';
    codeToSymbol(37)='=';
    codeToSymbol(38)='"';
    codeToSymbol(39)='@';
    codeToSymbol(40)='p';
    codeToSymbol(41)='B';
    codeToSymbol(42)='^';
    codeToSymbol(43)='r';
    codeToSymbol(44)='+';
    codeToSymbol(45)='u';
    codeToSymbol(46)='?';
    codeToSymbol(47)='!';
    codeToSymbol(48)='|';
    codeToSymbol(49)='~';
    codeToSymbol(50)='x';
    codeToSymbol(51)='D';
    codeToSymbol(52)='=';
    codeToSymbol(53)='A';
    codeToSymbol(54)='a';
    codeToSymbol(55)='J';
    codeToSymbol(56)='S';
    codeToSymbol(57)='V';
    codeToSymbol(58)='F';

    while pos+1<=numel(b)

        w=double(b(pos))+256*double(b(pos+1));
        pos=pos+2;

        interval=bitand(w,1023);
        code=bitshift(w,-10);

        if code==0
            break;
        end

        if code==59
            if pos+3>numel(b), break; end
            currentSample=double(b(pos))+ ...
                256*double(b(pos+1))+ ...
                65536*double(b(pos+2))+ ...
                16777216*double(b(pos+3));
            pos=pos+4;
            continue;
        end

        if code==63
            if pos>numel(b), break; end
            len=double(b(pos));
            pos=pos+1;
            skipBytes=2*ceil(len/2);
            pos=pos+skipBytes;
            if pos>numel(b)+1, pos=numel(b)+1; end
            continue;
        end

        currentSample=currentSample+interval;

        if isKey(codeToSymbol,code)
            sym=codeToSymbol(code);
        else
            continue;
        end

        samples(end+1,1)=currentSample;
        symbols(end+1,1)=sym;
    end

    samples=round(samples(:));
    symbols=symbols(:);

    if isempty(samples)
        error('No annotations could be decoded from %s.',fileName);
    end
end

%% ================= RESULTS WINDOW =================
function createResultsWindow(r,s)

    f=uifigure('Name',['ECG Results - ' r.recordBase],...
        'Position',[40 40 1500 900]);

    root=uigridlayout(f,[2 1]);
    root.RowHeight={55,'1x'};
    root.ColumnWidth={'1x'};

    %% ---------------- TOP TOOLBAR ----------------
    top=uigridlayout(root,[1 5]);
    top.Layout.Row=1;
    top.RowHeight={42};
    top.ColumnWidth={180,180,180,180,'1x'};

    uibutton(top,'push','Text','PROCESSING STAGES',...
        'ButtonPushedFcn',@processingStages);
    uibutton(top,'push','Text','THRESHOLD DETAILS',...
        'ButtonPushedFcn',@thresholdDetails);
    uibutton(top,'push','Text','PERFORMANCE PLOT',...
        'ButtonPushedFcn',@performancePlot);
    uibutton(top,'push','Text','EXPORT CSV',...
        'ButtonPushedFcn',@exportCSV);
    uilabel(top,'Text',sprintf('Record: %s | Fs: %.1f Hz | Selected: %s',...
        r.recordBase,r.Fs,r.selected.name),'FontWeight','bold');

    %% ---------------- MAIN CONTENT ----------------
    main=uigridlayout(root,[1 2]);
    main.Layout.Row=2;
    main.ColumnWidth={'1x',500};

    %% LEFT: WAVEFORMS
    pg=uigridlayout(main,[4 1]);
    pg.Layout.Column=1;
    pg.RowHeight={'1.25x','1.0x','0.85x','0.85x'};

    ax1=uiaxes(pg);
    grid(ax1,'on');
    plot(ax1,r.t,r.filtered,'DisplayName','Filtered ECG');
    hold(ax1,'on');
    if ~isempty(r.selected.rPeaks)
        plot(ax1,r.t(r.selected.rPeaks),r.filtered(r.selected.rPeaks),...
            '^','MarkerFaceColor','r','MarkerEdgeColor','r',...
            'DisplayName','R-peaks');
    end
    title(ax1,[r.selected.name ' - R-Peak Detection']);
    xlabel(ax1,'Time (s)');
    ylabel(ax1,'Amplitude');
    legend(ax1,'Location','best');

    ax2=uiaxes(pg);
    grid(ax2,'on');
    plot(ax2,r.t,r.integrated,'DisplayName','Integrated');
    hold(ax2,'on');
    if ~isempty(r.selected.thHigh)
        plot(ax2,r.t,r.selected.thHigh,'DisplayName','High');
    end
    if ~isempty(r.selected.thNormal)
        plot(ax2,r.t,r.selected.thNormal,'DisplayName','Normal');
    end
    if ~isempty(r.selected.thSB)
        plot(ax2,r.t,r.selected.thSB,'DisplayName','Search-back');
    end
    title(ax2,'Integrated Signal and Thresholds');
    xlabel(ax2,'Time (s)');
    ylabel(ax2,'Integrated amplitude');
    legend(ax2,'Location','best');

    ax3=uiaxes(pg);
    grid(ax3,'on');
    if numel(r.selected.rPeaks)>=2 && ~isempty(r.selected.bpm)
        hb=r.selected.rPeaks(2:end);
        n=min(numel(hb),numel(r.selected.bpm));
        plot(ax3,r.t(hb(1:n)),r.selected.bpm(1:n),'o-');
        hold(ax3,'on');
        if ~isnan(r.selected.meanBPM)
            yline(ax3,r.selected.meanBPM,'--','Mean HR');
        end
    end
    title(ax3,'Instantaneous Heart Rate');
    xlabel(ax3,'Time (s)');
    ylabel(ax3,'BPM');

    ax4=uiaxes(pg);
    grid(ax4,'on');
    plot(ax4,r.t,r.ecg);
    title(ax4,'Original ECG');
    xlabel(ax4,'Time (s)');
    ylabel(ax4,'Amplitude');

    %% RIGHT: PARAMETERS TABLE
    rg=uigridlayout(main,[2 1]);
    rg.Layout.Column=2;
    rg.RowHeight={42,'1x'};

    methodLabel=uilabel(rg,'Text',['SELECTED METHOD: ' r.selected.name],...
        'FontSize',15,'FontWeight','bold');
    methodLabel.HorizontalAlignment='center';

    pt=uitable(rg);
    pt.Data=parameterTable(r.selected,r);
    pt.ColumnName={'Parameter','Value'};
    pt.ColumnWidth={260,190};

    %% ---------------- NESTED CALLBACKS ----------------
    function processingStages(~,~)
        g=uifigure('Name','ECG Processing Stages','Position',[170 70 1250 820]);
        gg=uigridlayout(g,[6 1]);
        gg.RowHeight={'1x','1x','1x','1x','1x','1x'};

        a=uiaxes(gg); plot(a,r.t,r.ecg); grid(a,'on');
        title(a,'1. Original ECG'); xlabel(a,'Time (s)');

        b=uiaxes(gg); plot(b,r.t,r.filtered); grid(b,'on');
        title(b,'2. Band-pass Filtered ECG'); xlabel(b,'Time (s)');

        c=uiaxes(gg); plot(c,r.t,r.waveletDetail); grid(c,'on');
        title(c,'3. SWT QRS Detail - sym2 Level 4'); xlabel(c,'Time (s)');

        d=uiaxes(gg); plot(d,r.t,r.hilbertEnvelope); grid(d,'on');
        title(d,'4. Hilbert Envelope'); xlabel(d,'Time (s)');

        e=uiaxes(gg); plot(e,r.t,r.detectionFeature); grid(e,'on');
        title(e,['5. Common Detection Feature - ' r.featureMethod]); xlabel(e,'Time (s)');

        z=uiaxes(gg); plot(z,r.t,r.integrated); grid(z,'on');
        title(z,'6. Classical Derivative + Integration Baseline'); xlabel(z,'Time (s)');
    end

    function thresholdDetails(~,~)
        g=uifigure('Name','Threshold Details','Position',[250 130 1000 650]);
        gg=uigridlayout(g,[2 1]);
        gg.RowHeight={'1x',145};

        ax=uiaxes(gg);
        grid(ax,'on'); hold(ax,'on');
        plot(ax,r.t,r.detectionFeature,'DisplayName','Common detection feature');
        if ~isempty(r.selected.thHigh)
            plot(ax,r.t,r.selected.thHigh,'DisplayName','High');
        end
        if ~isempty(r.selected.thNormal)
            plot(ax,r.t,r.selected.thNormal,'DisplayName','Normal');
        end
        if ~isempty(r.selected.thSB)
            plot(ax,r.t,r.selected.thSB,'DisplayName','Search-back');
        end
        title(ax,['Thresholds - ' r.selected.name]);
        xlabel(ax,'Time (s)');
        ylabel(ax,'Threshold / integrated amplitude');
        legend(ax,'Location','best');

        uitextarea(gg,'Editable','off','Value',{...
            sprintf('High threshold fraction: %.3f',s.highFrac),...
            sprintf('Normal threshold fraction: %.3f',s.normalFrac),...
            sprintf('Search-back fraction: %.3f',s.searchFrac),...
            sprintf('Adaptive alpha: %.3f',s.alpha),...
            sprintf('Search-back RR ratio: %.2f',s.searchRatio),...
            'Level 1 = High, Level 2 = Normal, Level 3 = Search-back.'});
    end

    function performancePlot(~,~)
        if ~s.comparison
            uialert(f,...
                'Enable Compare all 3 thresholding methods and run the analysis again.',...
                'Comparison Required');
            return;
        end

        T=comparisonTable(r.allResults);
        g=uifigure('Name','Thresholding Performance Comparison',...
            'Position',[220 150 1050 650]);
        gg=uigridlayout(g,[2 1]);
        gg.RowHeight={'1x',170};

        ax=uiaxes(gg);
        grid(ax,'on');
        vals=[T.Sensitivity T.PPV T.Accuracy T.F1];
        bar(ax,vals);
        ax.XTick=1:height(T);
        ax.XTickLabel=T.Method;
        ylabel(ax,'Performance (%)');
        ylim(ax,[0 100]);
        legend(ax,{'Sensitivity','PPV','Accuracy','F1'},...
            'Location','southoutside');
        title(ax,'3-Level Adaptive vs 3-Level Fixed vs Single-Level');

        uitextarea(gg,'Editable','off','Value',{...
            'All methods use the same ECG segment and preprocessing.',...
            '3-Level Adaptive: thresholds update with signal/noise estimates.',...
            '3-Level Fixed: thresholds are initialized once and then fixed.',...
            'Single-Level: one adaptive threshold is used.',...
            'If reference annotations are unavailable, validation metrics are N/A.'});
    end

    function exportCSV(~,~)
        [fn,pn]=uiputfile('ecg_comparison.csv','Save comparison table');
        if isequal(fn,0), return; end
        try
            writetable(comparisonTable(r.allResults),fullfile(pn,fn));
            uialert(f,['Saved:' newline fullfile(pn,fn)],'Export Complete');
        catch ME
            uialert(f,ME.message,'Export Error');
        end
    end
end

%% ================= TABLE HELPERS =================
function T=parameterTable(m,r)
    if isempty(m.bpm) || all(isnan(m.bpm))
        minHR=NaN; maxHR=NaN;
    else
        minHR=min(m.bpm,[],'omitnan'); maxHR=max(m.bpm,[],'omitnan');
    end
    names={'Data source';'Sampling frequency (Hz)';'Segment duration (s)';...
        'Detected candidates';'Detected R-peaks';'Mean RR (s)';'Mean HR (BPM)';'Minimum HR (BPM)';...
        'Maximum HR (BPM)';'Thresholding method';'QRS feature';...
        'True Positives (TP)';'False Positives (FP)';'False Negatives (FN)';...
        'Sensitivity (%)';'PPV (%)';'Accuracy (%)';'F1 Score (%)'};
    values={r.recordBase;sprintf('%.2f',r.Fs);sprintf('%.2f',r.t(end));...
        sprintf('%d',m.numCandidates);sprintf('%d',m.numPeaks);fmt(m.meanRR,'%.4f');fmt(m.meanBPM,'%.2f');...
        fmt(minHR,'%.2f');fmt(maxHR,'%.2f');m.name;r.featureMethod;...
        fmt(m.TP,'%.0f');fmt(m.FP,'%.0f');fmt(m.FN,'%.0f');...
        fmt(m.sensitivity,'%.2f');fmt(m.PPV,'%.2f');...
        fmt(m.accuracy,'%.2f');fmt(m.F1,'%.2f')};
    T=table(names,values,'VariableNames',{'Parameter','Value'});
end

function T=comparisonTable(R)
    n=numel(R);
    Method=cell(n,1); RPeaks=zeros(n,1); MeanHR=nan(n,1); MeanRR=nan(n,1);
    Sensitivity=nan(n,1); PPV=nan(n,1); Accuracy=nan(n,1); F1=nan(n,1); FP=nan(n,1); FN=nan(n,1);
    for k=1:n
        Method{k}=R(k).name; RPeaks(k)=R(k).numPeaks; MeanHR(k)=R(k).meanBPM; MeanRR(k)=R(k).meanRR;
        Sensitivity(k)=R(k).sensitivity; PPV(k)=R(k).PPV; Accuracy(k)=R(k).accuracy; F1(k)=R(k).F1;
        FP(k)=R(k).FP; FN(k)=R(k).FN;
    end
    T=table(Method,RPeaks,MeanHR,MeanRR,Sensitivity,PPV,Accuracy,F1,FP,FN);
end

function s=fmt(x,f)
    if isempty(x)||isnan(x), s='N/A'; else, s=sprintf(f,x); end
end
function s=validationText(r)
    if contains(upper(r.validationMessage),'SYNTHETIC DEMO')
        s=['SYNTHETIC DEMO METRICS' newline ...
           'TP / FP / FN and performance values are randomly generated for GUI demonstration.'];
    elseif r.validationAvailable
        s=['VALIDATION SUCCESSFUL' newline ...
           'Sensitivity / PPV / Accuracy / F1 / TP / FP / FN are available.'];
    else
        s=['VALIDATION UNAVAILABLE' newline r.validationMessage];
    end
end
function s=validationShort(r)
    if contains(upper(r.validationMessage),'SYNTHETIC DEMO')
        s='Synthetic / Demo';
    elseif r.validationAvailable
        s='Available';
    else
        s='Not available';
    end
end

function v=validationDetails(r)
    if contains(upper(r.validationMessage),'SYNTHETIC DEMO')
        m=r.selected;
        v={...
            'SYNTHETIC DEMO METRICS',...
            sprintf('Synthetic values for selected method: %s',m.name),...
            sprintf('TP = %s    FP = %s    FN = %s',fmt(m.TP,'%.0f'),fmt(m.FP,'%.0f'),fmt(m.FN,'%.0f')),...
            sprintf('Sensitivity = %s %%',fmt(m.sensitivity,'%.2f')),...
            sprintf('PPV = %s %%',fmt(m.PPV,'%.2f')),...
            sprintf('Accuracy = %s %%',fmt(m.accuracy,'%.2f')),...
            sprintf('F1 Score = %s %%',fmt(m.F1,'%.2f')),...
            'These values are synthetic and are not MIT-BIH validation results.'};
        return;
    end

    if ~r.validationAvailable
        v={...
            'VALIDATION UNAVAILABLE',...
            r.validationMessage};
        return;
    end

    m=r.selected;
    v={...
        'VALIDATION SUCCESSFUL',...
        sprintf('Reference comparison results for selected method: %s',m.name),...
        sprintf('TP = %s    FP = %s    FN = %s',fmt(m.TP,'%.0f'),fmt(m.FP,'%.0f'),fmt(m.FN,'%.0f')),...
        sprintf('Sensitivity = %s %%',fmt(m.sensitivity,'%.2f')),...
        sprintf('PPV = %s %%',fmt(m.PPV,'%.2f')),...
        sprintf('Accuracy = %s %%',fmt(m.accuracy,'%.2f')),...
        sprintf('F1 Score = %s %%',fmt(m.F1,'%.2f')),...
        'Reference beats are matched within the selected annotation tolerance.'};
end

%% ================= MAT READER =================
function [ecg,Fs,recordBase] = readMATSignal(matFile,channel)

S = load(matFile);

candidateNames = {'val','ecg','ECG','signal','Signal','data','Data'};

found = false;

for k=1:numel(candidateNames)

    name = candidateNames{k};

    if isfield(S,name)

        v = S.(name);

        if isnumeric(v)

            if isvector(v)
                ecg = v(:);
                found = true;
                break;

            elseif ismatrix(v)

                if channel <= size(v,2)
                    ecg = v(:,channel);
                    found = true;
                    break;
                end
            end
        end
    end
end

if ~found

    names = fieldnames(S);

    for k=1:numel(names)

        v=S.(names{k});

        if isnumeric(v)

            if isvector(v)
                ecg=v(:);
                found=true;
                break;

            elseif ismatrix(v) && channel<=size(v,2)
                ecg=v(:,channel);
                found=true;
                break;
            end
        end
    end
end

if ~found
    error(['Could not find a numeric ECG variable in the MAT file. ',...
        'Expected a variable such as val, ecg, signal, or data.']);
end

Fs = [];

fsNames = {'Fs','fs','samplingFrequency','sampleRate','frequency'};

for k=1:numel(fsNames)

    if isfield(S,fsNames{k})

        v=S.(fsNames{k});

        if isnumeric(v) && isscalar(v) && v>0
            Fs=double(v);
            break;
        end
    end
end

if isempty(Fs)
    answer = inputdlg(...
        'Sampling frequency of this MAT ECG (Hz):',...
        'Sampling Frequency',[1 45],{'360'});

    if isempty(answer)
        error('Sampling frequency is required for a MAT ECG.');
    end

    Fs=str2double(answer{1});

    if isnan(Fs) || Fs<=0
        error('Invalid sampling frequency.');
    end
end

[~,recordBase,~] = fileparts(matFile);
end

%% ================= MIT-BIH 212 READER =================
function [ecg,Fs,recordBase] = readMITBIH212(datFile,channel)

[folder,recordBase,~] = fileparts(datFile);
heaFile = fullfile(folder,[recordBase '.hea']);

if ~isfile(heaFile)
    error(['Header file not found:\n' heaFile newline newline ...
        'Download the matching .hea file and keep it beside the .dat file.']);
end

fid=fopen(heaFile,'r');

if fid<0
    error('Unable to open header file:\n%s',heaFile);
end

firstLine=strtrim(fgetl(fid));
fclose(fid);

parts=strsplit(firstLine);

if numel(parts)<3
    error('Invalid MIT-BIH header file.');
end

numSignals=str2double(parts{2});
Fs=str2double(parts{3});

if isnan(numSignals) || isnan(Fs)
    error('Could not read number of signals or sampling frequency from .hea.');
end

if numSignals~=2
    error(['This local reader currently supports the standard MIT-BIH ',...
        'two-channel format. Header reports %d channels.'],numSignals);
end

if channel<1 || channel>2
    error('Channel must be 1 or 2.');
end

fid=fopen(datFile,'r');

if fid<0
    error('Unable to open MIT-BIH .dat file:\n%s',datFile);
end

bytes=fread(fid,inf,'uint8=>uint8');
fclose(fid);

nTriplets=floor(length(bytes)/3);

if nTriplets<1
    error('MIT-BIH .dat file is empty or too small.');
end

bytes=bytes(1:3*nTriplets);

b0=double(bytes(1:3:end));
b1=double(bytes(2:3:end));
b2=double(bytes(3:3:end));

s1 = b0 + 256.*bitand(b1,3);
s2 = b2 + 256.*bitshift(bitand(b1,12),-2);

s1(s1>=1024)=s1(s1>=1024)-2048;
s2(s2>=1024)=s2(s2>=1024)-2048;

if channel==1
    ecg=s1;
else
    ecg=s2;
end

ecg=double(ecg(:));

end

%% ================= 3-LEVEL FIXED =================
function [accepted,levelUsed,THhighHist,THnormalHist,THSBHist]=fixedThreeLevelDetector(x,Fs,highFrac,normalFrac,searchFrac,refractorySec,searchBackRatio)

N=numel(x);
refractory=max(1,round(refractorySec*Fs));

noiseLevel=median(x);
signalLevel=localPercentile(x,99);
if signalLevel<=noiseLevel
    signalLevel=max(x);
end
if signalLevel<=noiseLevel
    signalLevel=noiseLevel+eps;
end

THhigh=noiseLevel+highFrac*(signalLevel-noiseLevel);
THnormal=noiseLevel+normalFrac*(signalLevel-noiseLevel);
THSB=noiseLevel+searchFrac*(signalLevel-noiseLevel);

THhighHist=repmat(THhigh,N,1);
THnormalHist=repmat(THnormal,N,1);
THSBHist=repmat(THSB,N,1);

[pks,locs]=findpeaks(x,'MinPeakDistance',max(1,round(0.08*Fs)));

accepted=zeros(0,1);
levelUsed=zeros(0,1);
rejectedLocs=zeros(0,1);
rejectedPks=zeros(0,1);

for k=1:numel(locs)
    pk=pks(k); loc=locs(k);

    if pk>=THhigh
        if isempty(accepted) || loc-accepted(end)>=refractory
            accepted(end+1,1)=loc;
            levelUsed(end+1,1)=1;
        elseif pk>x(accepted(end))
            accepted(end)=loc;
            levelUsed(end)=1;
        end
    elseif pk>=THnormal
        if isempty(accepted) || loc-accepted(end)>=refractory
            accepted(end+1,1)=loc;
            levelUsed(end+1,1)=2;
        else
            rejectedLocs(end+1,1)=loc;
            rejectedPks(end+1,1)=pk;
        end
    else
        rejectedLocs(end+1,1)=loc;
        rejectedPks(end+1,1)=pk;
    end
end

if numel(accepted)>=2 && ~isempty(rejectedLocs)
    changed=true;
    while changed
        changed=false;
        accepted=sort(accepted);
        rrNow=diff(accepted);
        if isempty(rrNow), break; end
        medRR=median(rrNow);

        for k=2:numel(accepted)
            gap=accepted(k)-accepted(k-1);
            if gap<=searchBackRatio*medRR, continue; end

            mask=rejectedLocs>accepted(k-1) & rejectedLocs<accepted(k);
            idx=rejectedLocs(mask);
            vals=rejectedPks(mask);
            keep=vals>=THSB;
            idx=idx(keep); vals=vals(keep);
            if isempty(idx), continue; end

            expected=accepted(k-1)+medRR;
            [~,j]=max(vals);
            bestLoc=idx(j);
            if abs(bestLoc-expected)<=0.35*medRR && all(abs(bestLoc-accepted)>=refractory)
                accepted(end+1,1)=bestLoc;
                levelUsed(end+1,1)=3;
                rm=rejectedLocs==bestLoc;
                rejectedLocs(rm)=[]; rejectedPks(rm)=[];
                changed=true;
                break;
            end
        end
    end
end

[accepted,idx]=sort(accepted);
levelUsed=levelUsed(idx);
[accepted,idx]=unique(accepted,'stable');
levelUsed=levelUsed(idx);
end

%% ================= 3-LEVEL ADAPTIVE =================
function [accepted,levelUsed,THhighHist,THnormalHist,THSBHist]=adaptiveThreeLevelDetector(x,Fs,alpha,highFrac,normalFrac,searchFrac,refractorySec,searchBackRatio)

N=numel(x);
refractory=max(1,round(refractorySec*Fs));
THhighHist=zeros(N,1); THnormalHist=zeros(N,1); THSBHist=zeros(N,1);

base=x(1:min(N,max(1,round(2*Fs))));
NPKI=median(base);
SPKI=localPercentile(base,95);
if SPKI<=NPKI, SPKI=max(base); end
if SPKI<=NPKI, SPKI=NPKI+eps; end

THhigh=NPKI+highFrac*(SPKI-NPKI);
THnormal=NPKI+normalFrac*(SPKI-NPKI);
THSB=NPKI+searchFrac*(SPKI-NPKI);

[pks,locs]=findpeaks(x,'MinPeakDistance',max(1,round(0.08*Fs)));
accepted=zeros(0,1); levelUsed=zeros(0,1);
rejectedLocs=zeros(0,1); rejectedPks=zeros(0,1); rrHistory=zeros(0,1);
lastPos=1;

for k=1:numel(locs)
    pk=pks(k); loc=locs(k);
    if loc>lastPos
        THhighHist(lastPos:loc-1)=THhigh;
        THnormalHist(lastPos:loc-1)=THnormal;
        THSBHist(lastPos:loc-1)=THSB;
    end

    acceptedThis=false;
    if pk>=THhigh
        if isempty(accepted) || loc-accepted(end)>=refractory
            accepted(end+1,1)=loc;
            levelUsed(end+1,1)=1;
            acceptedThis=true;
        end
    elseif pk>=THnormal
        rrOK=isempty(accepted) || loc-accepted(end)>=refractory;
        if ~isempty(accepted) && numel(rrHistory)>=2
            rrOK=rrOK && (loc-accepted(end)<=2*median(rrHistory));
        end
        if rrOK
            accepted(end+1,1)=loc;
            levelUsed(end+1,1)=2;
            acceptedThis=true;
        end
    end

    if acceptedThis
        if numel(accepted)>=2
            rrHistory(end+1,1)=accepted(end)-accepted(end-1);
            if numel(rrHistory)>8, rrHistory=rrHistory(end-7:end); end
        end
        SPKI=alpha*pk+(1-alpha)*SPKI;
    else
        rejectedLocs(end+1,1)=loc;
        rejectedPks(end+1,1)=pk;
        NPKI=alpha*pk+(1-alpha)*NPKI;
    end

    if SPKI<=NPKI, SPKI=NPKI+eps; end
    THhigh=NPKI+highFrac*(SPKI-NPKI);
    THnormal=NPKI+normalFrac*(SPKI-NPKI);
    THSB=NPKI+searchFrac*(SPKI-NPKI);
    lastPos=loc;
end

if lastPos<=N
    THhighHist(lastPos:end)=THhigh;
    THnormalHist(lastPos:end)=THnormal;
    THSBHist(lastPos:end)=THSB;
end

if numel(accepted)>=2 && ~isempty(rejectedLocs)
    changed=true;
    while changed
        changed=false;
        accepted=sort(accepted);
        rrNow=diff(accepted);
        if isempty(rrNow), break; end
        medRR=median(rrNow);
        for k=2:numel(accepted)
            gap=accepted(k)-accepted(k-1);
            if gap<=searchBackRatio*medRR, continue; end
            mask=rejectedLocs>accepted(k-1) & rejectedLocs<accepted(k);
            idx=rejectedLocs(mask); vals=rejectedPks(mask);
            keep=vals>=THSB; idx=idx(keep); vals=vals(keep);
            if isempty(idx), continue; end
            expected=accepted(k-1)+medRR;
            [bestVal,j]=max(vals); bestLoc=idx(j);
            if abs(bestLoc-expected)<=0.35*medRR && all(abs(bestLoc-accepted)>=refractory)
                accepted(end+1,1)=bestLoc;
                levelUsed(end+1,1)=3;
                rm=rejectedLocs==bestLoc;
                rejectedLocs(rm)=[]; rejectedPks(rm)=[];
                SPKI=alpha*bestVal+(1-alpha)*SPKI;
                if SPKI<=NPKI, SPKI=NPKI+eps; end
                THhigh=NPKI+highFrac*(SPKI-NPKI);
                THnormal=NPKI+normalFrac*(SPKI-NPKI);
                THSB=NPKI+searchFrac*(SPKI-NPKI);
                changed=true;
                break;
            end
        end
    end
end

[accepted,idx]=sort(accepted); levelUsed=levelUsed(idx);
[accepted,idx]=unique(accepted,'stable'); levelUsed=levelUsed(idx);
end

%% ================= SINGLE-LEVEL ADAPTIVE =================
function [accepted,thresholdHist]=singleThresholdDetector(x,Fs,alpha,refractorySec)

N=numel(x); refractory=max(1,round(refractorySec*Fs));
thresholdHist=zeros(N,1);

base=x(1:min(N,max(1,round(2*Fs))));
noise=median(base);
signal=localPercentile(base,95);
if signal<=noise, signal=max(base); end
if signal<=noise, signal=noise+eps; end

threshold=noise+0.65*(signal-noise);

[pks,locs]=findpeaks(x,'MinPeakDistance',max(1,round(0.08*Fs)));
accepted=zeros(0,1); lastPos=1;

for k=1:numel(locs)
    pk=pks(k); loc=locs(k);
    if loc>lastPos, thresholdHist(lastPos:loc-1)=threshold; end

    if pk>=threshold && (isempty(accepted) || loc-accepted(end)>=refractory)
        accepted(end+1,1)=loc;
        signal=alpha*pk+(1-alpha)*signal;
    else
        noise=alpha*pk+(1-alpha)*noise;
    end

    if signal<=noise, signal=noise+eps; end
    threshold=noise+0.65*(signal-noise);
    lastPos=loc;
end

if lastPos<=N, thresholdHist(lastPos:end)=threshold; end
accepted=sort(unique(accepted));
end


%% ================= WAVELET + HILBERT QRS FEATURE =================
function [detailQRS,hilbertEnvelope,fusedFeature]=waveletHilbertFeature(x,Fs)

x=double(x(:));
N=numel(x);
lev=4;

if exist('swt','file')~=2
    error(['Wavelet + Hilbert mode requires Wavelet Toolbox (swt). ',...
        'Install Wavelet Toolbox or select Classical derivative.']);
end

block=2^lev;
Np=ceil(N/block)*block;
xp=zeros(Np,1);
xp(1:N)=x;

[~,cD]=swt(xp,lev,'sym2');
detailQRS=double(cD(lev,:)).';
detailQRS=detailQRS(1:N);

detailQRS=detailQRS-mean(detailQRS);
hilbertEnvelope=abs(hilbert(detailQRS));
hilbertEnvelope=movmean(hilbertEnvelope,max(1,round(0.025*Fs)));

waveletEnergy=movmean(detailQRS.^2,max(1,round(0.030*Fs)));

a=robustNormalize(waveletEnergy);
b=robustNormalize(hilbertEnvelope);
fusedFeature=0.5*a+0.5*b;

fusedFeature=movmean(fusedFeature,max(1,round(0.080*Fs)));
end

function y=robustNormalize(x)
x=double(x(:));
med=median(x,'omitnan');
q1=localPercentile(x,25);
q99=localPercentile(x,99);
scale=q99-q1;

if ~isfinite(scale) || scale<=eps
    scale=std(x,'omitnan');
end
if ~isfinite(scale) || scale<=eps
    scale=1;
end

y=(x-med)/scale;
y(y<0)=0;

mx=max(y,[],'omitnan');
if isempty(mx) || ~isfinite(mx) || mx<=eps
    y=zeros(size(x));
else
    y=y/mx;
end
end


%% ================= R PEAK LOCALIZATION =================
function rPeaks=localizeRPeaks(filteredECG,qrsCandidates,Fs,searchRadiusSec)

rPeaks=zeros(size(qrsCandidates));

searchRadius=round(searchRadiusSec*Fs);

for k=1:numel(qrsCandidates)

    c=qrsCandidates(k);

    a=max(1,c-searchRadius);
    b=min(length(filteredECG),c+searchRadius);

    [~,idx]=max(abs(filteredECG(a:b)));

    rPeaks(k)=a+idx-1;
end

rPeaks=unique(rPeaks(:));
end

%% ================= REFRACTORY =================
function r=enforceRefractory(r,signal,minDist)

if isempty(r)
    return;
end

r=sort(r(:));
keep=r(1);

for k=2:numel(r)

    if r(k)-keep(end)>=minDist

        keep(end+1,1)=r(k);

    else

        if abs(signal(r(k)))>abs(signal(keep(end)))
            keep(end)=r(k);
        end
    end
end

r=keep;
end

%% ================= HEART RATE =================
function [rr,bpm,meanBPM]=calculateHR(rPeaks,Fs)

if numel(rPeaks)<2

    rr=[];
    bpm=[];
    meanBPM=NaN;
    return;
end

rr=diff(rPeaks)/Fs;

valid=rr>=0.25 & rr<=2.0;

bpm=60./rr;
bpm(~valid)=NaN;

meanRR=mean(rr(valid),'omitnan');

if isempty(meanRR) || isnan(meanRR)
    meanBPM=NaN;
else
    meanBPM=60/meanRR;
end
end


%% ================= METRICS =================
function [TP,FN,FP,Se,PPV,Acc,F1]=...
    evaluateDetection(det,ref,tol)

det=sort(unique(det(:)));
ref=sort(unique(ref(:)));

matchedRef=false(size(ref));
matchedDet=false(size(det));

for i=1:numel(det)

    d=det(i);

    [dist,j]=min(abs(ref-d));

    if ~isempty(dist) && dist<=tol && ~matchedRef(j)

        matchedDet(i)=true;
        matchedRef(j)=true;
    end
end

TP=sum(matchedDet);
FP=sum(~matchedDet);
FN=sum(~matchedRef);

Se=TP/(TP+FN+eps);
PPV=TP/(TP+FP+eps);
Acc=TP/(TP+FP+FN+eps);
F1=2*Se*PPV/(Se+PPV+eps);
end

%% ================= LOCAL PERCENTILE =================
function q=localPercentile(x,p)

x=double(x(:));
x=x(isfinite(x));

if isempty(x)
    q=NaN;
    return;
end

if p<=0
    q=min(x);
    return;
elseif p>=100
    q=max(x);
    return;
end

x=sort(x);
idx=1+(numel(x)-1)*(p/100);
lo=floor(idx);
hi=ceil(idx);

if lo==hi
    q=x(lo);
else
    q=x(lo)+(idx-lo)*(x(hi)-x(lo));
end
end
