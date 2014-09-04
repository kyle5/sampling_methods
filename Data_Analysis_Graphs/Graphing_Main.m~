% This script plots error values for the discrepency between counts taken
% by hand and counts taken by the algorithm. All error values are computed
% as abs(counted by algorithm - groundTruth)/groundTruth

% This is the directory which contains the graphing and the yield map
% programs
configuration_paths
addpath( fullfile( directory_of_graphing, 'cpp/build/' ) );

% This directory contains the .mat files containing the matrices of apples that 
% were counted by hand and by the computer algorithm
directory_for_green_apple_count_matrices = [directory_of_all_data_analysis, '/data/preprocessed_measurement_data/2011_granny_smith/'];
directory_for_red_apple_count_matrices = [directory_of_all_data_analysis, '/data/preprocessed_measurement_data/2011_red_thinned/'];

addpath( directory_of_helper_functions );
addpath( directory_for_green_apple_count_matrices );
addpath( directory_for_red_apple_count_matrices );

graphing_scripts_and_functions = [directory_of_graphing, 'scriptsAndFunctions/'];
graphing_data_directory = [directory_of_graphing, 'data/'];
graphing_results = [directory_of_graphing, 'results/'];
addpath( graphing_scripts_and_functions );
addpath( graphing_data_directory );

%% Loading Apple Count Variables
% Hand count and computer count matrices that are loaded
% need to be setup so that size() = [number of sections per row, number of rows]
% with section 1, row 1 located at index (1, 1)
load([directory_for_red_apple_count_matrices, 'greenAppleVariables.mat']);
load([directory_for_green_apple_count_matrices, 'redAppleVariables.mat']);

addpath( [robocrop_source, '/matlab/src/'] );
addpath( [robocrop_source, '/matlab/src/mapping/'] );

preprocessed_measurement_data_path = sprintf( '%s/preprocessed_measurement_data/', directory_data_root);
raw_measurement_data_path = sprintf( '%s/raw_measurement_data/', directory_data_root );
harvest_monitor_data_path = sprintf( '%s/', directory_data_root );

local_parameters = load_local_parameters();
%% PS
processed_ps_grid_measurement_data_path = [preprocessed_measurement_data_path, '/2013_06_17_Colony_Petite_Syrah/'];
measurements_file = [ processed_ps_grid_measurement_data_path, '/ps_2013_smoothed_grid_measurements.mat' ];
use_previous_grid_ps = 1;
if use_previous_grid_ps == 1
  load( measurements_file, 'grid_measurements_groundtruth_ps', 'grid_measurements_image_results_ps' );
else
  data_file_csv_ps = sprintf( '%s/grape/2013_06_17_Colony_Petite_Syrah/ground_truth_data/2013_harvest_monitor.csv', raw_measurement_data_path );
  all_res_dirs = { '%s/grape/2013_06_17_Colony_Petite_Syrah/image_results/20140727_1635_2013_06_17_Colony_Petite_Syrah_optimal_parameters/', raw_measurement_data_path };
  all_dataset_names = { '2013_06_17_Colony_Petite_Syrah' };
  lat_lon_grid = [];
  [ grid_measurements_groundtruth_ps, lat_lon_grid ] = read_and_preprocess_groundtruth_map( data_file_csv_ps, mapping_parameters, lat_lon_grid );
  [all_results] = readImageEstimates(all_res_dirs, all_dataset_names);
  [ grid_measurements_image_results_ps, lat_lon_grid ] = read_and_preprocess_detections_map( all_results, mapping_parameters, lat_lon_grid );
  save( measurements_file, 'grid_measurements_groundtruth_ps', 'grid_measurements_image_results_ps' );
end

%% PN
processed_pn_grid_measurement_data_path = [preprocessed_measurement_data_path, '/2013_06_18_Colony_Pinot_Noir/'];
measurements_file = [ processed_pn_grid_measurement_data_path, 'pn_2013_smoothed_grid_measurements.mat' ];
use_previous_grid_pn = 1;
if use_previous_grid_pn == 1
  load( measurements_file, 'grid_measurements_groundtruth_pn', 'grid_measurements_image_results_pn' );
else
  data_file_csv_pn = sprintf( '%/grape/2013_06_18_Colony_Pinot_Noir/ground_truth_data/2013_harvest_monitor.csv', raw_measurement_data_path);
  %% Read Groundtruth data
  all_res_dirs = { sprintf( '%s/grape/2013_06_18_Colony_Pinot_Noir/image_results/20140803_2048_2013_06_18_Colony_Pinot_Noir_optimal_parameters/', raw_measurement_data_path ) };
  all_dataset_names = { '2013_06_18_Colony_Pinot_Noir' };
  lat_lon_grid = [];
  [ grid_measurements_groundtruth_pn, lat_lon_grid ] = read_and_preprocess_groundtruth_map( data_file_csv_pn, mapping_parameters, lat_lon_grid );
  [all_results] = readImageEstimates(all_res_dirs, all_dataset_names);
  [ grid_measurements_image_results_pn, lat_lon_grid ] = read_and_preprocess_detections_map( all_results, mapping_parameters, lat_lon_grid );
  save( measurements_file, 'grid_measurements_groundtruth_pn', 'grid_measurements_image_results_pn' );
end

%% Chard 2013
processed_chard_2013_grid_measurement_data_path = [preprocessed_measurement_data_path, '/2013_06_19_Dusty_Lane/'];
measurements_file = [ processed_chard_2013_grid_measurement_data_path, 'chard_2013_smoothed_grid_measurements.mat' ];
use_previous_grid_chard_2013 = 1;
if use_previous_grid_chard_2013 == 1
  load( measurements_file, 'grid_measurements_groundtruth_chard_2013', 'grid_measurements_image_results_chard_2013' );
else
  data_file_csv_chard_2013 = sprintf( '%s/grape/2013_06_19_Dusty_Lane/ground_truth_data/2013_harvest_monitor.csv', raw_measurement_data_path );
  %% Read Groundtruth data
  all_res_dirs = { sprintf( '%s/grape/2013_06_19_Dusty_Lane/image_results/20140803_2217_2013_06_19_Dusty_Lane_optimal_parameters/', raw_measurement_data_path ) };
  all_dataset_names = { '2013_06_19_Dusty_Lane' };
  lat_lon_grid = [];
  [ grid_measurements_groundtruth_chard_2013, lat_lon_grid ] = read_and_preprocess_groundtruth_map( data_file_csv_chard_2013, mapping_parameters, lat_lon_grid );
  [all_results] = readImageEstimates(all_res_dirs, all_dataset_names);
  [ grid_measurements_image_results_chard_2013, lat_lon_grid ] = read_and_preprocess_detections_map( all_results, mapping_parameters, lat_lon_grid );
  save( measurements_file, 'grid_measurements_groundtruth_chard_2013', 'grid_measurements_image_results_chard_2013' );
end

valid_red = double( red_thinned_ground_counts ~= -1 & red_thinned_pc_counts ~= -1 );
valid_green = double( green_ground_counts ~= -1 & green_pc_counts ~= -1 );
valid_ps = double( grid_measurements_groundtruth_ps ~= -1 & grid_measurements_image_results_ps ~= -1 );
valid_pn = double( grid_measurements_groundtruth_pn ~= -1 & grid_measurements_image_results_pn ~= -1 );
valid_chard_2013 = double( grid_measurements_groundtruth_chard_2013 ~= -1 & grid_measurements_image_results_chard_2013 ~= -1 );

ground_counts = { red_thinned_ground_counts; green_ground_counts; grid_measurements_groundtruth_ps; grid_measurements_groundtruth_pn; grid_measurements_groundtruth_chard_2013 };
pc_counts = { red_thinned_pc_counts; green_pc_counts; grid_measurements_image_results_ps; grid_measurements_image_results_pn; grid_measurements_image_results_chard_2013 };
valid_counts = { valid_red; valid_green; valid_ps; valid_pn; valid_chard_2013 };
total_hand_counts = { sum(red_thinned_ground_counts); sum(green_ground_counts); sum(grid_measurements_groundtruth_ps); sum(grid_measurements_groundtruth_pn); sum(grid_measurements_groundtruth_chard_2013) };

visualize_correlation = 0;
if visualize_correlation == 1
  figure;
  valid = logical(valid_counts{5});
  ground_valid = ground_counts{5}( valid );
  pc_valid = pc_counts{5}( valid );
  scatter( ground_valid, pc_valid );
  hold on;
  p = polyfit( ground_valid, pc_valid, 1 );
  x_values = [min(ground_valid(:)), max(ground_valid(:))];
  y_values = p(1)*x_values + p(2);
  plot( x_values, y_values, '-' );
  title( 'Correlation between Ground Counts and Algorithm Counts', 'FontSize', 15, 'FontWeight', 'Bold' );
  xlabel( 'Ground Counts', 'FontSize', 15, 'FontWeight', 'Bold' );
  ylabel( 'Algorithm Counts', 'FontSize', 15, 'FontWeight', 'Bold' );
  keyboard;
end

parameters.loop_iterations = loop_iterations;
parameters.percentages_to_check = percentages_to_check;
parameters.names_of_orchard_areas = names_of_orchard_areas;
parameters.area_in_orchard_for_error_calculation = area_in_orchard_for_error_calculation;
parameters.save_graphs = save_graphs;
parameters.increment_input = increment;
parameters.computeKriging_input = computeKriging;
parameters.computeStdDev_input = computeStdDev;
parameters.plot_standard_deviation_input = plot_standard_deviation;
parameters.hand_counts_are_dependent_variable = hand_counts_are_dependent_variable;
parameters.num_sampling_strategies = num_sampling_strategies;
parameters.sampling_strategy_operations = sampling_strategy_operations;
parameters.graphing_data_directory = graphing_data_directory;
parameters.num_sampling_strategies = num_sampling_strategies;
parameters.names_of_error_calcs = names_of_error_calcs;
for i = 1:size( boolean_analyze_dataset, 1 )
  if boolean_analyze_dataset( i, 1 ) == 0
    continue;
  end
  cur_dataset_id = fruit_dataset_ids{i};
  cur_dataset_id_no_spaces = cur_dataset_id;
  cur_dataset_id_no_spaces(cur_dataset_id_no_spaces == ' ') = '_';
  cur_ground_counts = ground_counts{i};
  cur_total_hand_count = total_hand_counts{i};
  cur_pc_counts = pc_counts{i};
  cur_valid_counts = valid_counts{i};
  total_sections = sum(cur_valid_counts(:));
  cur_std_dev_error = std_dev_error(i);
  cur_r_squared_value = r_squared_values(i);
  
  if hand_counts_are_dependent_variable == 1
    sampling_hand_counted_numbers_list = [ 5, 10, 15, 20, 25, 30, 35, 40, 45, 50];
    sampling_algorithm_counted_numbers_list = floor( [100] / 100 * total_sections );
  else
    sampling_hand_counted_numbers_list = floor( percentages_to_check(1, :) / 100 * total_sections );
    sampling_algorithm_counted_numbers_list = starting_point:increment:total_sections;
  end
  
  mkdir(optimal_sampling_locations_directory_path);
  optimal_hand_sample_locations_path = sprintf( '%s/optimal_spatial_hand_count_locations_step_%d_iterations_%d_type_%s.mat', optimal_sampling_locations_directory_path, increment, loop_iterations, cur_dataset_id_no_spaces );
  optimal_algorithm_sample_locations_path = sprintf( '%s/optimal_spatial_alg_count_locations_step_%d_iterations_%d_type_%s.mat', optimal_sampling_locations_directory_path, increment, loop_iterations, cur_dataset_id_no_spaces );
  
  experiment_name = experiment_names{ i };
  
  graph_results_root_dir = graphing_results;
  mkdir( graph_results_root_dir );
  current_time = now();
  current_time_vector = datevec( current_time );
  year = current_time_vector(1);
  month = current_time_vector(2);
  day = current_time_vector(3);
  hour = current_time_vector(4);
  minute = current_time_vector(5);
  cur_experiment_graphs_root_name = sprintf( '%s/%d%02d%02d_%02d%02d_%s/', graph_results_root_dir, year, month, day, hour, minute, experiment_name );
  
  parameters.sampling_hand_counted_numbers_list_input = sampling_hand_counted_numbers_list;
  parameters.sampling_algorithm_counted_numbers_list_input = sampling_algorithm_counted_numbers_list;
  parameters.compute_optimal_hand_count_locations = compute_optimal_hand_count_locations;
  parameters.compute_optimal_alg_count_locations = compute_optimal_alg_count_locations;
  parameters.optimal_hand_sample_locations_path = optimal_hand_sample_locations_path;
  parameters.optimal_algorithm_sample_locations_path = optimal_algorithm_sample_locations_path;
  parameters.cur_dataset_id = cur_dataset_id;
  parameters.cur_dataset_id_no_spaces = cur_dataset_id_no_spaces;
  parameters.cur_experiment_graphs_root_name = cur_experiment_graphs_root_name;
  parameters.total_valid_sections = sum( logical( cur_valid_counts(:) ) );
  parameters.cur_r_squared_value = cur_r_squared_value;
  parameters.compute_spatial_and_stratified_alg = compute_spatial_and_stratified_alg;
  parameters.compute_spatial_and_stratified_hand = compute_spatial_and_stratified_hand;
  
  indices_data = setup_optimal_sampling_indices( cur_pc_counts, cur_ground_counts, loop_iterations, parameters, cur_valid_counts );
  cur_valid_counts = logical( cur_valid_counts );
  
  cur_dataset_id_for_saving = cur_dataset_id;
  cur_dataset_id_for_saving(ismember(cur_dataset_id,' ')) = [];
  
  mat_file_name_computer = [comp_error_directory_string, 'all_computer_mean_errors_', cur_dataset_id_for_saving, '_', loop_iterations_string , '.mat'];
  mat_file_name_hand = [hand_error_directory_string, 'all_hand_mean_errors_mean_errors_', cur_dataset_id_for_saving, '_', loop_iterations_string , '.mat'];
  mat_file_name_hand_smoothed = [hand_error_directory_string, 'all_hand_mean_errors_mean_errors_smoothed_', cur_dataset_id_for_saving, '_', loop_iterations_string , '.mat'];
  
  if calculate_error_computer == 1
    addpath( fullfile( directory_of_graphing, 'cpp/build/' ) );
    row_data_dimension_cpp = 0;
    [cur_all_computer_mean_errors, cur_std_dev_computer_errors ] = getMeanErrorsComputerCount( cur_pc_counts, cur_ground_counts, parameters, indices_data, cur_valid_counts, cur_r_squared_value, cur_std_dev_error, i );
    save(mat_file_name_computer, 'cur_all_computer_mean_errors', 'cur_std_dev_computer_errors');
  else
    load(mat_file_name_computer);
  end
  
  % Kyle: TODO: Test tomorrow
  if visualize_std_dev_map == 1
    sections_to_view_std_dev_map = 1:total_sections;
    [corresponding_valid_std_dev, original_valid_idx] = get_std_dev_map( cur_pc_counts, sections_to_view_std_dev_map );
    std_dev_map = zeros( size( cur_pc_counts ) );
    std_dev_map(original_valid_idx) = corresponding_valid_std_dev;
    figure, imagesc( std_dev_map );
  end
  plotComputerError( cur_all_computer_mean_errors, cur_dataset_id, comp_error_direct_extrapolation_discontinuous, parameters );
  
  % Steve: Below are the methods to display the graphs that are in the
  % Latex document
  plotComputerErrorComparison( cur_all_computer_mean_errors, cur_std_dev_computer_errors, cur_dataset_id, { comp_error_direct_extrapolation_discontinuous, comp_error_selected_calibration_discontinuous },  'Stratified (Hand + Image)', parameters, path_individual_results_simulated{i}, i <= 2 && true );
  plotComputerErrorComparison( cur_all_computer_mean_errors, cur_std_dev_computer_errors, cur_dataset_id, { comp_error_direct_extrapolation_discontinuous, comp_error_spatial_discontinuous },  'Spatial (Hand + Image)', parameters, path_individual_results_simulated{i}, i <= 2 && true );
  plotComputerErrorComparison( cur_all_computer_mean_errors, cur_std_dev_computer_errors, cur_dataset_id, { comp_error_direct_extrapolation_discontinuous, comp_error_extrapolate_hand_random_discontinuous },  'Random (Hand Only)', parameters, path_individual_results_simulated{i}, i <= 2 && false );
  plotComputerErrorComparison( cur_all_computer_mean_errors, cur_std_dev_computer_errors, cur_dataset_id, { comp_error_direct_extrapolation_discontinuous, comp_error_extrapolate_hand_stratified_discontinuous },  'Stratified (Hand Only)', parameters, path_individual_results_simulated{i}, i <= 2 && false );
  plotComputerErrorComparison( cur_all_computer_mean_errors, cur_std_dev_computer_errors, cur_dataset_id, { comp_error_direct_extrapolation_discontinuous, comp_error_extrapolate_hand_sections_spatial_discontinuous },  'Spatial (Hand Only)', parameters, path_individual_results_simulated{i}, i <= 2 && false );
  plotComputerErrorComparison( cur_all_computer_mean_errors, cur_std_dev_computer_errors, cur_dataset_id, { comp_error_direct_extrapolation_discontinuous, comp_error_extrapolate_hand_sections_simulated },  'Simulated (Hand Only)', parameters, path_individual_results_simulated{i}, i <= 2 && false );

  plotComputerErrorComparison( cur_all_computer_mean_errors, cur_std_dev_computer_errors, cur_dataset_id, { comp_error_direct_extrapolation_discontinuous, comp_error_y_intercept_sections_random_discontinuous },  'Random: Regression (Hand + Image)', parameters, path_individual_results_simulated{i}, i <= 2 && false );
  plotComputerErrorComparison( cur_all_computer_mean_errors, cur_std_dev_computer_errors, cur_dataset_id, { comp_error_direct_extrapolation_discontinuous, comp_error_y_intercept_sections_stratified_discontinuous },  'Stratified: Regression (Hand + Image)', parameters, path_individual_results_simulated{i}, i <= 2 && false );
  plotComputerErrorComparison( cur_all_computer_mean_errors, cur_std_dev_computer_errors, cur_dataset_id, { comp_error_direct_extrapolation_discontinuous, comp_error_y_intercept_sections_spatial_discontinuous },  'Spatial: Regression (Hand + Image)', parameters, path_individual_results_simulated{i}, i <= 2 && false );
  plotComputerErrorComparison( cur_all_computer_mean_errors, cur_std_dev_computer_errors, cur_dataset_id, { comp_error_direct_extrapolation_discontinuous, comp_error_y_intercept_simulated },  'Simulated: Regression (Hand + Image)', parameters, path_individual_results_simulated{i}, i <= 2 && false );
  plotComputerErrorComparison( cur_all_computer_mean_errors, cur_std_dev_computer_errors, cur_dataset_id, { comp_error_direct_extrapolation_discontinuous, comp_error_scaled_simulated },  'Simulated: Scaling Factor: (Hand + Image)', parameters, path_individual_results_simulated{i}, i <= 2 && false );
end
