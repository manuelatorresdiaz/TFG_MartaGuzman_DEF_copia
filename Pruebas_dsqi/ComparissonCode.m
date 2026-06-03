% =========================================================================
% 2 TOPS COMPARISON (8 HOURS - RAW SIGNAL - CROPPED)
% =========================================================================

% 1. FILE NAMES
file_Top1 = 'PF2_TOP1.txt';
file_Top2 = 'PF3_TOP1.txt';

files = {file_Top1, file_Top2};
names = {'Top 1', 'Top 2'};
data_column = 3;

% 2. TEST MODE 
TEST = 0;
if (TEST)
    time_vector = 1:((7*60 + 59)*60); 
else
    time_vector = 1:(((7*60 + 59)*60)*1000 - 360000); 
end

% 3. ALGORITHM SETUP
global samplingFreq windowSize showDebugData showPlots;
samplingFreq = 1000; windowSize = 10; showDebugData = false; showPlots = false;
fs = 1000;

quality_vectors = cell(1, 2);
means = zeros(1, 2);
std_devs = zeros(1, 2);

% -------------------------------------------------------------------------
% PHASE 1: PROCESSING
% -------------------------------------------------------------------------
clc;
fprintf('=== COMPARING TOPS (8 HOURS) ===\n\n');

for i = 1:2
    fprintf('Processing: %s...\n', names{i});
    
    % Load and crop data
    full_data = ImportPluxData(files{i}, data_column);
    final_time = min(length(full_data), max(time_vector));
    raw_data = full_data(1:final_time);
    
    % Direct mSQI calculation
    [~,~,~,~,~,~,~, qual_vec, qual_mean] = mSQI(raw_data, fs);
    
    % Save results
    quality_vectors{i} = qual_vec;
    means(i) = qual_mean;
    std_devs(i) = std(qual_vec);
    
    fprintf('  -> Mean: %.4f | Std Dev: %.4f\n\n', means(i), std_devs(i));
end

% -------------------------------------------------------------------------
% PHASE 2: STATISTICS (CONFIDENCE INTERVALS)
% -------------------------------------------------------------------------
fprintf('Calculating Confidence Intervals (Bootstrap iter=1000)...\n');
alph = 0.01; 
iter = 1000; 

CIMean = estimateCIMean(quality_vectors{1}, quality_vectors{2}, alph, iter);
CIMed  = estimateCIMedian(quality_vectors{1}, quality_vectors{2}, alph, iter);

fprintf('\n=== STATISTICAL RESULTS (Top 1 vs Top 2) ===\n');
fprintf('CI Difference of Means:   [%.4f, %.4f]\n', CIMean(1), CIMean(2));
fprintf('CI Difference of Medians: [%.4f, %.4f]\n', CIMed(1), CIMed(2));

% -------------------------------------------------------------------------
% PLOTS
% -------------------------------------------------------------------------
figure('Name', 'Tops Comparison (8 Hours)', 'NumberTitle', 'off');

% Top 1 Histogram
subplot(2,1,1);
histogram(quality_vectors{1}, 30, 'FaceColor', '#0072BD'); % Blue
title(['Raw Signal Quality - ', names{1}]);
xlabel('Quality Index'); ylabel('Frequency'); xlim([0 1]); grid on;

% Top 2 Histogram
subplot(2,1,2);
histogram(quality_vectors{2}, 30, 'FaceColor', '#7E2F8E'); % Purple
title(['Raw Signal Quality - ', names{2}]);
xlabel('Quality Index'); ylabel('Frequency'); xlim([0 1]); grid on;