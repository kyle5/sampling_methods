function [indices_data] = setup_optimal_sampling_indices( algorithm_counts, ground_counts, loop_iterations, parameters, valid_counts )
  % 
  % Kyle: TODO: Move below to the main function: Have an option to compute
  % the optimal indices or not
  compute_optimal_hand_count_locations = parameters.compute_optimal_hand_count_locations;
  compute_optimal_alg_count_locations = parameters.compute_optimal_alg_count_locations;
  optimal_hand_sample_locations_path = parameters.optimal_hand_sample_locations_path;
  optimal_algorithm_sample_locations_path = parameters.optimal_algorithm_sample_locations_path;
  sampling_algorithm_counted_numbers_list = parameters.sampling_algorithm_counted_numbers_list_input;
  sampling_hand_counted_numbers_list = parameters.sampling_hand_counted_numbers_list_input;
  
  %   Inputs: mat of size indices, the actual optimal indices (cell array), number of adjusted indices to make, distance to alter indices by, percentage of indices to alter
  %   Outputs: Cell array of Cell array of optimal indices
  if compute_optimal_hand_count_locations == 1
    [ optimal_hand_sampling_indices_true, ~ ] = get_optimal_sampling_locations( algorithm_counts, ground_counts, sampling_hand_counted_numbers_list, parameters.compute_spatial_and_stratified_hand, valid_counts, loop_iterations );
    optimal_yield_dist_spatial_hand_sampling_indices_true = optimal_hand_sampling_indices_true;
    save( optimal_hand_sample_locations_path, 'optimal_hand_sampling_indices_true', 'optimal_yield_dist_spatial_hand_sampling_indices_true' );
  else
    load( optimal_hand_sample_locations_path, 'optimal_hand_sampling_indices_true', 'optimal_yield_dist_spatial_hand_sampling_indices_true' );
  end
  
  if compute_optimal_alg_count_locations == 1
    disp('MATLAB aaad');
    [optimal_algorithm_sampling_indices_true, ~ ] = get_optimal_sampling_locations( algorithm_counts, ground_counts, sampling_algorithm_counted_numbers_list, parameters.compute_spatial_and_stratified_alg, valid_counts, loop_iterations );
    optimal_yield_dist_spatial_algorithm_sampling_indices_true = optimal_algorithm_sampling_indices_true;
    save( optimal_algorithm_sample_locations_path, 'optimal_algorithm_sampling_indices_true', 'optimal_yield_dist_spatial_algorithm_sampling_indices_true' );
  else
    load( optimal_algorithm_sample_locations_path, 'optimal_algorithm_sampling_indices_true', 'optimal_yield_dist_spatial_algorithm_sampling_indices_true' );
  end
  
  indices_data.optimal_yield_dist_spatial_hand_sampling_indices_true = optimal_yield_dist_spatial_hand_sampling_indices_true;
  indices_data.optimal_yield_dist_spatial_algorithm_sampling_indices_true = optimal_yield_dist_spatial_algorithm_sampling_indices_true;
  indices_data.optimal_hand_sampling_indices_true = optimal_hand_sampling_indices_true;
  indices_data.optimal_algorithm_sampling_indices_true = optimal_algorithm_sampling_indices_true;
end