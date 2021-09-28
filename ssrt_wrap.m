datadir = '/Users/BNRF/Desktop/PTK_ProjectHOPE/Data/';
% use wildcards and the 'dir' command to read the names of .csv files stored in the subject's
% data directory into a cell array called subjects
files = dir(fullfile(datadir, '/*.csv'));
subjects = {files(:).name};

% create an array for subject-level stats
group = [];

% loop through subjects
for i=1:length(subjects(1,:))
    datafile = [datadir,subjects{i}]
    group(i,:)=ssrt_compute(datafile);   
end

t = table(group(:,1),group(:,2),group(:,4),group(:,5),group(:,6),group(:,8),...
    group(:,9),group(:,10),group(:,12),group(:,13),group(:,14),...
    'VariableNames', {'Overall ACC', 'Overall RT', 'Overall SSRT','Block1 ACC',...
    'Block1 RT', 'Block1 SSRT','Block2 ACC', 'Block2 RT', 'Block2 SSRT',...
    'Practice ACC', 'Practice RT'});