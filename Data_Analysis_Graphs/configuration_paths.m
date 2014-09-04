% This is the configuration file
robocrop_source = '/home/kyle/grape_code_git_primary/robocrop/';

mapping_parameters.grid_step = 0.00002; % ! Hardcoded
mapping_parameters.measurement_smoothing_radius = 0.00002; % ! Hardcoded
mapping_parameters.threshold_too_few_measurements = 0.5; % ! Hardcoded
mapping_parameters.dataset_name='ImageDataMap';
mapping_parameters.map_name = 'Fruit_per_meter';

% These are the percentages of the orchard that are sampled by hand for
% calibration

percentages_to_check = [ 2, 5, 10 ];
num_percentages = size(percentages_to_check, 2);

names_of_error_calcs = cell(3);

%% Types of error calculations
names_of_error_calcs{1} = 'Unscaled Computer Counts';
names_of_error_calcs{2} = 'Direct Extrapolation of Computer Counts';
names_of_error_calcs{3} = 'Kriging of Computer Counts';

plot_standard_deviation = 1;

names_of_orchard_areas = cell(3);
names_of_orchard_areas{1} = 'Error of Estimated Apples Counted in Individual Sections';
names_of_orchard_areas{2} = 'Error of Estimated Apples Counted in Individual Rows';
names_of_orchard_areas{3} = 'Error of Total Estimated Apples Counted in Orchard';

area_in_orchard_for_error_calculation = 3;

num_sampling_strategies = 17;

comp_error_scaled_simulated = num_sampling_strategies + 17;
comp_error_y_intercept_simulated = num_sampling_strategies + 16;
comp_error_extrapolate_hand_sections_simulated = num_sampling_strategies + 15;
comp_error_y_intercept_sections_spatial_discontinuous = num_sampling_strategies + 14;
comp_error_y_intercept_sections_stratified_discontinuous = num_sampling_strategies + 13;
comp_error_y_intercept_sections_random_discontinuous = num_sampling_strategies + 12;
comp_error_extrapolate_hand_sections_spatial_discontinuous = num_sampling_strategies + 11;
comp_error_extrapolate_hand_stratified_discontinuous = num_sampling_strategies + 10;
comp_error_extrapolate_hand_random_discontinuous = num_sampling_strategies + 9;
comp_error_baysian_process_discontinuous = num_sampling_strategies + 7;
comp_error_standard_deviation_calibration_discontinuous = num_sampling_strategies + 6;
comp_error_spatial_discontinuous = num_sampling_strategies + 5;
comp_error_selected_calibration_discontinuous = num_sampling_strategies + 4;
comp_error_kriging_comp_discontinuous = num_sampling_strategies + 3;
comp_error_direct_extrapolation_discontinuous = num_sampling_strategies + 2;
comp_error_unscaled_discontinuous = num_sampling_strategies + 1;

comp_error_standard_deviation_calibration_continuous = 6;
comp_error_spatial_continuous = 5;
comp_error_selected_calibration_continuous = 4;
comp_error_kriging_comp_continuous = 3;
comp_error_direct_extrapolation_continuous = 2;
comp_error_unscaled_continuous = 1;

sampling_strategy_operations = false( [1, num_sampling_strategies] );
% Uscaled                             % Scaled                            % Kriging   
sampling_strategy_operations(1) = 1; sampling_strategy_operations(2) = 1; sampling_strategy_operations(3) = 0;
% Yield Distribution Representative        % Spatial                         %  Std Dev. 
sampling_strategy_operations(4) = 1; sampling_strategy_operations(5) = 1; sampling_strategy_operations(6) = 0;
% spatial/yd iterative process      % gaussian process            
sampling_strategy_operations(7) = 0; sampling_strategy_operations(8) = 0;
% random: extrapolate the hand sampled    % stratified: extrapolate the hand sampled        % spatial: extrapolate the hand sampled
sampling_strategy_operations(9) = 1;      sampling_strategy_operations(10) = 1;             sampling_strategy_operations(11) = 1;
%  random: y-intercept scaling method    %  stratified: y-intercept scaling method   % spatial: y-intercept scaling method  
sampling_strategy_operations(12) = 1;    sampling_strategy_operations(13) = 1;       sampling_strategy_operations(14) = 1;
%  extrapolate: hand only: simulated    % simulated: y-intercept: hand+image    % simulated: scaled counts: hand+image   
sampling_strategy_operations(15) = 1;   sampling_strategy_operations(16) = 1;   sampling_strategy_operations(17) = 1;

% Number of times that random samples are taken from the orchard sections
% before averaging
loop_iterations = 100;

% The increment of sampling by the computer algorithm
increment = 5;

loop_iterations_string = num2str(loop_iterations);

[p, n, e] = fileparts(pwd);
directory_of_all_data_analysis = [p, '/'];
path_paper_results = sprintf( '%s/samping_strategies_results_paper/', directory_of_all_data_analysis );
path_individual_results_simulated = { sprintf('%s/apple/Red_Delicious_Simulated/', path_paper_results), sprintf('%s/apple/Granny_Smith_Simulated/', path_paper_results), sprintf('%s/grape/PS_Simulated/', path_paper_results), sprintf('%s/grape/PN_Simulated/', path_paper_results), sprintf('%s/grape/Chardonnay_2013_Simulated/', path_paper_results) };

directory_of_helper_functions = [ directory_of_all_data_analysis, 'DataAnalysisHelperFunctions/'];
directory_of_graphing = [directory_of_all_data_analysis, 'Data_Analysis_Graphs/'];
directory_data_root = '/home/kyle/Dropbox/PastWorkProjects/2014_09_sampling_methods_data/';

comp_error_directory_string = [directory_of_graphing, '/allComputerErrors/'];
hand_error_directory_string = [directory_of_graphing, '/allHandErrors/'];

mkdir( comp_error_directory_string );
mkdir( hand_error_directory_string );

fruit_dataset_ids = {'Red Delicious Thinned'; 'Granny Smith'; 'Petite Syrah'; 'Pinot Noir'; 'Chardonnay 2013'};
starting_point = 5;
optimal_sampling_locations_directory_path = sprintf( '%s/data/optimal_sampling_locations/', directory_of_all_data_analysis );

% Variables that can change:
r_squared_values = [ 0.72; 0.56; 0.33; 0.36; 0.5 ];
std_dev_error = [ 0.12, 0.12, 0.2, 0.2, 0.2 ];
boolean_analyze_dataset = [0; 0; 0; 1; 1];
compute_optimal_hand_count_locations = 1;
compute_optimal_alg_count_locations = 1;
compute_spatial_and_stratified_hand = 0;
compute_spatial_and_stratified_alg = 0;
save_graphs = 1;
experiment_names = {'red_thinned_new_types', 'greens_new_types', 'ps_1000_samples_2_meter_step_new_types', 'pn_1000_samples_2_meter_step_new_types', 'chard_2013_1000_samples_2_meter_step_new_types' };
hand_counts_are_dependent_variable = 1;
visualize_std_dev_map = 0;
computeKriging = sampling_strategy_operations(3);
computeStdDev = 1;
calculate_error_computer = 1;
