function stats=ssrt_compute(datafile)
%% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 21);
 
% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
 
% Specify column names and types
opts.VariableNames = ["instrument", "study", "participant", "screen", "event", "ssrthand", "ssrtversion", "ssrtdate", "ssrttime", "ssrttrial", "ssrtblocktype", "ssrtblock", "ssrtsignaltype", "ssrtstimulus", "ssrtresponse", "ssrtfixTime", "ssrtStimulusTime", "ssrtSignalTime", "ssrtResponseTime", "ssrtGoAccuracy", "ssrtStopAccuracy"];
opts.VariableTypes = ["categorical", "double", "string", "double", "categorical", "categorical", "double", "datetime", "categorical", "double", "categorical", "double", "categorical", "categorical", "categorical", "double", "double", "double", "double", "double", "double"];
 
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
 
% Specify variable properties
opts = setvaropts(opts, "participant", "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["instrument", "participant", "event", "ssrthand", "ssrttime", "ssrtblocktype", "ssrtsignaltype", "ssrtstimulus", "ssrtresponse"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "ssrtdate", "InputFormat", "MM/dd/yy");
opts = setvaropts(opts, "study", "TrimNonNumeric", true);
opts = setvaropts(opts, "study", "ThousandsSeparator", ",");
 
% Import the data
ssrttrials = readtable(datafile, opts);

%% Clear temporary variables
clear opts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make an array for each trial & block type
%Practice trials
prac_idx = ssrttrials.ssrtblocktype == 'practice';
practice_only = ssrttrials(prac_idx,:);

%All task trials
trial_idx = ssrttrials.ssrtblocktype == 'trial';
trials = ssrttrials(trial_idx,:);

% Task block1
block1_idx = find(trials.ssrtblock==1);
block1 = trials(block1_idx,:);   

%Task block2
block2_idx = find(trials.ssrtblock==2);
block2 = trials(block2_idx,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Go trials, accuracy (proportion correct) and mean reaction time. 

%Practice
correct=length(find(practice_only.ssrtGoAccuracy==1));
incorrect=length(find(practice_only.ssrtGoAccuracy==0));
prac_go_acc = correct/sum(practice_only.ssrtsignaltype=='go');
prac_error_com = incorrect/sum(practice_only.ssrtsignaltype=='go');
prac_go_RT = nanmean(practice_only.ssrtResponseTime(find(practice_only.ssrtGoAccuracy==1)));
prac_go_SD_RT = nanstd(practice_only.ssrtResponseTime(find(practice_only.ssrtGoAccuracy==1)));

%block1
correct=length(find(block1.ssrtGoAccuracy==1));
incorrect=length(find(block1.ssrtGoAccuracy==0));
b1_go_acc =correct/sum(block1.ssrtsignaltype=='go');
b1_error_com =incorrect/sum(block1.ssrtsignaltype=='go');
b1_go_RT = nanmean(block1.ssrtResponseTime(find(block1.ssrtGoAccuracy==1)));
b1_go_SD_RT = nanstd(block1.ssrtResponseTime(find(block1.ssrtGoAccuracy==1)));

%block2
correct=length(find(block2.ssrtGoAccuracy==1));
incorrect=length(find(block2.ssrtGoAccuracy==0));
b2_go_acc = correct/sum(block2.ssrtsignaltype=='go');
b2_error_com = incorrect/sum(block2.ssrtsignaltype=='go');
b2_go_RT = nanmean(block2.ssrtResponseTime(find(block2.ssrtGoAccuracy==1)));
b2_go_SD_RT = nanstd(block2.ssrtResponseTime(find(block2.ssrtGoAccuracy==1)));

%allblocks
correct=length(find(trials.ssrtGoAccuracy==1));
incorrect=length(find(trials.ssrtGoAccuracy==0));
all_go_acc = correct/sum(trials.ssrtsignaltype=='go');
all_error_com = incorrect/sum(trials.ssrtsignaltype=='go');
all_go_RT = nanmean(trials.ssrtResponseTime(find(trials.ssrtGoAccuracy==1)));
all_go_SD_RT = nanstd(trials.ssrtResponseTime(find(trials.ssrtGoAccuracy==1)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Stop trials; proportion successful inhibition, inhibition failure 

%Practice
correct=length(find(practice_only.ssrtStopAccuracy==1));
incorrect=length(find(practice_only.ssrtStopAccuracy==0));
prac_stop_acc = correct/sum(practice_only.ssrtsignaltype~='go');
prac_stop_fail = incorrect/sum(practice_only.ssrtsignaltype~='go');

%block1
correct=length(find(block1.ssrtStopAccuracy==1));
incorrect=length(find(block1.ssrtStopAccuracy==0));
b1_stop_acc =correct/sum(block1.ssrtsignaltype~='go');
b1_stop_error =incorrect/sum(block1.ssrtsignaltype~='go');

%block2
correct=length(find(block2.ssrtStopAccuracy==1));
incorrect=length(find(block2.ssrtStopAccuracy==0));
b2_stop_acc = correct/sum(block2.ssrtsignaltype~='go');
b2_stop_error = incorrect/sum(block2.ssrtsignaltype~='go');

%allblocks
correct=length(find(trials.ssrtStopAccuracy==1));
incorrect=length(find(trials.ssrtStopAccuracy==0));
all_stop_acc = correct/sum(trials.ssrtsignaltype~='go');
all_stop_error = incorrect/sum(trials.ssrtsignaltype~='go');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extract correct go RTs and ss delay for the SSD analysis & Average SSD
%block1
b1_go_correct_rt=block1.ssrtResponseTime(find(block1.ssrtGoAccuracy==1));
b1_ss_delay=block1.ssrtSignalTime(block1.ssrtsignaltype~='go');
b1_mean_ss = nanmean(b1_ss_delay);

%block2
b2_go_correct_rt=block2.ssrtResponseTime(find(block2.ssrtGoAccuracy==1));
b2_ss_delay=block2.ssrtSignalTime(block2.ssrtsignaltype~='go');
b2_mean_ss = nanmean(b2_ss_delay);

%allblocks
all_go_correct_rt=trials.ssrtResponseTime(find(trials.ssrtGoAccuracy==1));
all_ss_delay=trials.ssrtSignalTime(trials.ssrtsignaltype~='go');
all_mean_ss = nanmean(all_ss_delay);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sort go RTs for each block.
b1_go_correct_rt = sort(b1_go_correct_rt);
b2_go_correct_rt = sort(b2_go_correct_rt);
all_go_correct_rt = sort(all_go_correct_rt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Quantile Method for deriving the stop signal reaction time.
% Find the index of the Go RT corresponding to the proportion of stop failures
% Extract the RT for the indexed value
% Then estimate SSRT by subtracting mean SSD from the extracted RT

%block1
quantileInd_b1 = round((1-b1_stop_acc)*numel(b1_go_correct_rt));
quantileRT_b1 = b1_go_correct_rt(quantileInd_b1);
subjectSSRTs_b1 = quantileRT_b1 - b1_mean_ss;

%block2
quantileInd_b2 = round((1-b2_stop_acc)*numel(b2_go_correct_rt));
quantileRT_b2 = b2_go_correct_rt(quantileInd_b2);
subjectSSRTs_b2 = quantileRT_b2 - b2_mean_ss;

%allblocks
quantileInd_all = round((1-all_stop_acc)*numel(all_go_correct_rt));
quantileRT_all = all_go_correct_rt(quantileInd_all);
subjectSSRTs_all = quantileRT_all - all_mean_ss;


%% Export stats for ANOVA. Put descriptive statistics into a vector that 
stats = [all_go_acc,all_go_RT,all_go_SD_RT,subjectSSRTs_all,b1_go_acc,b1_go_RT,b1_go_SD_RT,subjectSSRTs_b1,b2_go_acc,b2_go_RT,b2_go_SD_RT,subjectSSRTs_b2,prac_go_acc,prac_go_RT,prac_go_SD_RT];

end
