function [ all_computer_mean_errors, std_dev_computer_errors ] = ...
    getMeanErrorsComputerCount( algorithm_counts, ground_counts, parameters, indices_data, valid_counts, cur_r_squared_value, cur_std_dev_error, graphing_main_iteration )
  %
  p = polyfit( ground_counts(valid_counts(:)), algorithm_counts(valid_counts(:)), 1 );
  all_computer_mean_errors = [];
  std_dev_computer_errors = [];
  variance_groundtruth = std( ground_counts(valid_counts(:)) ) ^ 2;
  variance_algorithm_counts = std( algorithm_counts(valid_counts(:)) ) ^ 2;
  estimated_error_value = sqrt( ( 1 - cur_r_squared_value ) * variance_groundtruth );
  estimated_algorithm_count_and_r_squared_error_value = sqrt( ( 1 - cur_r_squared_value ) * variance_algorithm_counts );
  
  mean_ground_counts_data = mean( ground_counts(valid_counts(:)) );
  std_ground_counts_data = std( ground_counts(valid_counts(:)) );
  mean_algorithm_counts = mean( algorithm_counts( valid_counts(:) ) );
  std_algorithm_counts = std( algorithm_counts( valid_counts(:) ) );
  
  % map ground counts to algorithm counts "level"
  algorithm_count_estimate_directly_from_ground_counts = p(1) * ground_counts(valid_counts(:)) + p(2);
  algorithm_counts_delta = algorithm_counts(valid_counts(:)) - algorithm_count_estimate_directly_from_ground_counts(:);
  algorithm_counts_errors = algorithm_counts_delta ./ algorithm_count_estimate_directly_from_ground_counts(:);
  mean_algorithm_counts_delta = mean(algorithm_counts_delta(:))
%   std_algorithm_counts_delta = std( algorithm_counts_delta(:) )
  std_algorithm_counts_delta = estimated_algorithm_count_and_r_squared_error_value
  
  scaling_factor_overall = sum( ground_counts(valid_counts(:)) ) / sum( algorithm_counts(valid_counts(:)) );
  algorithm_count_estimate_directly_from_ground_counts_sf = ground_counts(valid_counts(:)) / scaling_factor_overall;
  algorithm_counts_delta_sf = algorithm_counts(valid_counts(:)) - algorithm_count_estimate_directly_from_ground_counts_sf(:);
  algorithm_counts_errors_sf = algorithm_counts_delta_sf(:) ./ algorithm_count_estimate_directly_from_ground_counts_sf(:);
  mean_algorithm_counts_delta_sf = mean( algorithm_counts_delta_sf(:) )
%   std_algorithm_counts_delta_sf = std( algorithm_counts_delta_sf(:) )
  std_algorithm_counts_delta_sf = estimated_algorithm_count_and_r_squared_error_value
  
  total_sections = numel( ground_counts );
  total_valid_sections = sum( valid_counts(:) );
  total_hand_count_valid = sum(ground_counts(valid_counts(:)));
  total_algorithm_count_valid = sum(algorithm_counts(valid_counts(:)));
  average_scaling_factor = total_algorithm_count_valid / total_hand_count_valid;
  graphing_data_directory = parameters.graphing_data_directory;
  loop_iterations = parameters.loop_iterations;
  sampling_hand_counted_numbers_list = parameters.sampling_hand_counted_numbers_list_input;
  sampling_algorithm_counted_numbers_list = parameters.sampling_algorithm_counted_numbers_list_input;
  increment = parameters.increment_input;
  computeKriging = parameters.computeKriging_input;
  computeStdDev = parameters.computeStdDev_input;
  num_sampling_strategies = parameters.num_sampling_strategies;
  sampling_strategy_operations = parameters.sampling_strategy_operations;
  cur_dataset_id_no_spaces = parameters.cur_dataset_id_no_spaces;
  
  % Final indices names
  % Original indices
  optimal_hand_sampling_indices_true = indices_data.optimal_hand_sampling_indices_true;
  optimal_algorithm_sampling_indices_true = indices_data.optimal_algorithm_sampling_indices_true;
  optimal_yield_dist_spatial_algorithm_sampling_indices_true = indices_data.optimal_yield_dist_spatial_algorithm_sampling_indices_true;
  optimal_yield_dist_spatial_hand_sampling_indices_true = indices_data.optimal_yield_dist_spatial_hand_sampling_indices_true;
  
  rng('shuffle')
  
  [ rows_cur_map, columns_cur_map ] = size( algorithm_counts );
  
  total_algorithm_counted_numbers_list = numel(sampling_algorithm_counted_numbers_list);
  total_hand_counted_numbers_list = numel(sampling_hand_counted_numbers_list);
  
  num_types_sample_spacing = 2; % Continuous vs. discontinuous
  types_of_error_calcs = num_types_sample_spacing * num_sampling_strategies;
  areas_of_orchard = 3;
  
  all_computer_mean_errors = ones( total_hand_counted_numbers_list, total_algorithm_counted_numbers_list, types_of_error_calcs, areas_of_orchard );
  std_dev_computer_errors = ones( total_hand_counted_numbers_list, total_algorithm_counted_numbers_list, types_of_error_calcs, areas_of_orchard );
  
  [ X, Y ] = meshgrid( 1:columns_cur_map, 1:rows_cur_map );
  X = X(:);
  Y = Y(:);
  
  x_cur = 0:0.01:1;
  y_cur = exppdf( x_cur, 0.4 );
  max_y = max(y_cur(:));
  ratio_to_one = 1/max_y;
  distribution_lower = y_cur .* ratio_to_one;
  distribution_higher = distribution_lower * -1 + 1.0001;
  
  computer_errors_section = ones(loop_iterations, types_of_error_calcs);
  computer_errors_rows = ones(loop_iterations, types_of_error_calcs);
  computer_errors_overall = ones(loop_iterations, types_of_error_calcs);
  
  errors_one_iteration_sections = ones(1, types_of_error_calcs);
  errors_one_iteration_rows = ones(1, types_of_error_calcs);
  errors_one_iteration_overall = ones(1, types_of_error_calcs);
  
  s_optimal_hand_sampling_indices_true = size(optimal_hand_sampling_indices_true);
  s_optimal_yield_dist_spatial_algorithm_sampling_indices_true = size( optimal_yield_dist_spatial_algorithm_sampling_indices_true );
  s_optimal_yield_dist_spatial_hand_sampling_indices_true = size( optimal_yield_dist_spatial_hand_sampling_indices_true );
  visualize = 0;
  valid_counts = logical(valid_counts);
  
  [~, sorted_idx] = sort(algorithm_counts(:));
  sorted_idx_in_org_space = 1:numel(sorted_idx);
  sorted_idx_in_org_space(sorted_idx) = sorted_idx_in_org_space;
  min_valid_count_hand = min(ground_counts(valid_counts));
  max_valid_count_hand = max(ground_counts(valid_counts));
  min_valid_count_alg = min(algorithm_counts(valid_counts));
  max_valid_count_alg = max(algorithm_counts(valid_counts));
  % to do: below is based off hand counts
  for k = 1:total_hand_counted_numbers_list
    
    disp('This is the start of hand sampling loop');
    num_sections_to_compute_scaling_factor = sampling_hand_counted_numbers_list(k);
    ratio_hand_sampled = num_sections_to_compute_scaling_factor / total_valid_sections;
    for m = 1:numel(sampling_algorithm_counted_numbers_list)
      num_sections_for_computer_to_count = sampling_algorithm_counted_numbers_list(m);
      
      hand_sample_simulated = normrnd( mean_ground_counts_data, std_ground_counts_data, [loop_iterations, sum(valid_counts(:)), 1] );
      if graphing_main_iteration <= 2
        algorithm_counts_perfect_from_model = hand_sample_simulated * (average_scaling_factor);
      else
        algorithm_counts_perfect_from_model = p(1) * hand_sample_simulated + p(2);
      end
      
      perfected_check = 0;
      % compute average error for each iteration
      algorithm_to_hand_count_offset_simulated = normrnd( 0, std_algorithm_counts_delta, [loop_iterations, sum(valid_counts(:)), 1] );
      if perfected_check == 1
        algorithm_counts_simulated_perturbed = algorithm_counts_perfect_from_model;
      else
        algorithm_counts_simulated_perturbed = algorithm_counts_perfect_from_model + algorithm_to_hand_count_offset_simulated;
      end
      
      % compute average error for each iteration
      algorithm_to_hand_count_offset_simulated_sf = normrnd( 0, std_algorithm_counts_delta_sf, [loop_iterations, sum(valid_counts(:)), 1] );
      % simulate positive and negative offsets
      if perfected_check == 1
        algorithm_counts_simulated_perturbed_sf = algorithm_counts_perfect_from_model;
      else
        algorithm_counts_simulated_perturbed_sf = algorithm_counts_perfect_from_model + algorithm_to_hand_count_offset_simulated_sf;
      end
      
      gc_valid = ground_counts( valid_counts(:) );
      alg_valid = algorithm_counts( valid_counts(:) );
      use_original_optimal_indices = 1;
      algorithm_count_totals_original_list = zeros( loop_iterations, 1 );
      algorithm_count_totals_new_list = zeros( loop_iterations, 1 );
      for i = 1:loop_iterations
        indices_scaling_factor = randperm( sum(valid_counts(:)) );
        indices_scaling_factor = indices_scaling_factor( 1:num_sections_to_compute_scaling_factor );
        cur_hand_sample_scaling_factor = hand_sample_simulated(i, indices_scaling_factor, :);
        cur_hand_sample_estimate = hand_sample_simulated(i, :, :);
        
        cur_algorithm_counts_perturbed_linear_offset_scaling = algorithm_counts_simulated_perturbed(i, indices_scaling_factor, :);
        cur_algorithm_counts_perturbed_sf_scaling = algorithm_counts_simulated_perturbed_sf(i, indices_scaling_factor, :);
        cur_algorithm_counts_perturbed_linear_offset_estimate = algorithm_counts_simulated_perturbed(i, :, :);
        cur_algorithm_counts_perturbed_sf_estimate = algorithm_counts_simulated_perturbed_sf(i, :, :);
        
        % Add one to all values to convert from CPP to MATLAB
        cur_idx_yield_dist_spatial = mod(i, s_optimal_yield_dist_spatial_hand_sampling_indices_true(2))+1;
        cur_idx_spatial = mod(i, s_optimal_hand_sampling_indices_true(2))+1;
        cur_yield_dist_spatial_hand_count_indices = optimal_yield_dist_spatial_hand_sampling_indices_true{ k, cur_idx_yield_dist_spatial };
        cur_spatial_hand_count_indices = optimal_hand_sampling_indices_true{ k, cur_idx_spatial };
        
        % check that these are all valid
        valid_cur = sum(valid_counts(cur_spatial_hand_count_indices));
        entries_cur = numel(cur_spatial_hand_count_indices);
        cur_spatial_algorithm_count_indices = find( valid_counts(:) == 1 );
        
        if visualize == 1
          if i <= s_optimal_yield_dist_spatial_hand_sampling_indices_true(2)
            plot_optimal_sampling_indices( algorithm_counts, cur_spatial_hand_count_indices, cur_yield_dist_spatial_hand_count_indices, 'Comparison just before' );
            keyboard;
          end
        end
        
        for a = 1:2
          % 1, 2, 3: Setup for scaled and unscaled algorithm counts
          if a == 1; continue; end
          if a == 1
            group_size = 4;
            rand_sections_to_count = randomlySelectContinuousSections( num_sections_for_computer_to_count, group_size, total_sections, rows_cur_map, valid_counts );
            rand_sections_to_count_scaling = randomlySelectContinuousSections( num_sections_to_compute_scaling_factor, group_size, total_sections, rows_cur_map, valid_counts );
          else
            rand_sections_to_count = randomlySelectDiscontinuousSections( total_sections, num_sections_for_computer_to_count, valid_counts );
            rand_sections_to_count_scaling = randomlySelectDiscontinuousSections( total_sections, num_sections_to_compute_scaling_factor, valid_counts );
          end
          scaling_factor_rand_sections = sum( algorithm_counts(rand_sections_to_count_scaling) ) / sum( ground_counts(rand_sections_to_count_scaling) );
          
          % 4: Spatially spread out
          spatially_spread_out_scaling_factor = sum( algorithm_counts( cur_spatial_hand_count_indices(:) ) ) / sum( ground_counts( cur_spatial_hand_count_indices(:) ) );
          % 5: Representative of yield distribution
          [all_varied_levels_sections, varied_levels_scaling_factor] = get_varied_levels_scaling_data( algorithm_counts, ground_counts, rand_sections_to_count, cur_spatial_algorithm_count_indices, num_sections_to_compute_scaling_factor, valid_counts );
          
          % 6: standard deviation dependent
          if sampling_strategy_operations(6) == 1
            [ ~, original_valid_idx ] = get_std_dev_map( algorithm_counts, rand_sections_to_count );
            [rand_sections_to_count_scaling_std_dev, scaling_factor_std_dev] = compute_std_dev_scaling_factor_indices( algorithm_counts, ground_counts, distribution_lower, distribution_higher, num_sections_to_compute_scaling_factor, rand_sections_to_count_scaling, original_valid_idx, valid_counts );
          else
            rand_sections_to_count_scaling_std_dev = rand_sections_to_count_scaling;
            scaling_factor_std_dev = scaling_factor_rand_sections;
          end
          
          % 7: Use kriging of the spatial and stratified locations
          scaling_factor_spatial_and_stratified_locations = sum( algorithm_counts( cur_yield_dist_spatial_hand_count_indices ) ) / sum( ground_counts( cur_yield_dist_spatial_hand_count_indices ) );
          
          % check for invalid locations
          if sum(valid_counts(rand_sections_to_count_scaling) == 0) > 0 || sum(valid_counts(cur_spatial_hand_count_indices) == 0) > 0 || sum(valid_counts(all_varied_levels_sections) == 0) > 0
            keyboard;
          elseif numel( rand_sections_to_count_scaling ) ~= numel( cur_spatial_hand_count_indices ) || numel(all_varied_levels_sections) ~= numel(rand_sections_to_count_scaling)
            keyboard;
          end
          
          for b = 1:num_sampling_strategies
            if sampling_strategy_operations(b) == false; continue; end
            if b == 1
              % Unscaled
              locations_for_scaling_factor = [];
              cur_scaling_factor = 1;
              cur_algorithm_count_indices = rand_sections_to_count;
            elseif b == 2
              % Scaled
              locations_for_scaling_factor = rand_sections_to_count_scaling;
              cur_scaling_factor = scaling_factor_rand_sections;
              cur_algorithm_count_indices = rand_sections_to_count;
            elseif b == 3
              % Kriging
              locations_for_scaling_factor = rand_sections_to_count_scaling;
              cur_scaling_factor = scaling_factor_rand_sections;
              cur_algorithm_count_indices = rand_sections_to_count;
            elseif b == 4
              % stratified
              locations_for_scaling_factor = all_varied_levels_sections;
              cur_scaling_factor = varied_levels_scaling_factor;
              cur_algorithm_count_indices = rand_sections_to_count;
            elseif b == 5
              % spatial
              locations_for_scaling_factor = cur_spatial_hand_count_indices;
              cur_scaling_factor = spatially_spread_out_scaling_factor;
              cur_algorithm_count_indices = rand_sections_to_count;
            elseif b == 6
              % std dev
              locations_for_scaling_factor = rand_sections_to_count_scaling_std_dev;
              cur_scaling_factor = scaling_factor_std_dev;
              cur_algorithm_count_indices = rand_sections_to_count;
            elseif b == 7
              % Spatial and Yield Distribution Iterative Process
              locations_for_scaling_factor = cur_yield_dist_spatial_hand_count_indices;
              cur_scaling_factor = scaling_factor_spatial_and_stratified_locations;
              cur_algorithm_count_indices = rand_sections_to_count;
            elseif b == 8
              % Kriging/(uncertainty modelling code)
              [ scaling_factor_uncertainty_modelling] = kriging_point_evaluation_code();
              cur_scaling_factor = scaling_factor_uncertainty_modelling;
              locations_for_scaling_factor = rand_sections_to_count_scaling;
              cur_algorithm_count_indices = rand_sections_to_count;
            elseif b == 9
              % extrapolate: hand sampled locations: random
              locations_for_scaling_factor = rand_sections_to_count_scaling;
              cur_scaling_factor = -1;
              cur_algorithm_count_indices = -1;
            elseif b == 10
              % extrapolate: hand sampled locations: stratified
              locations_for_scaling_factor = all_varied_levels_sections;
              cur_scaling_factor = -1;
              cur_algorithm_count_indices = -1;
            elseif b == 11
              % extrapolate: hand sampled locations: spatial
              locations_for_scaling_factor = cur_spatial_hand_count_indices;
              cur_scaling_factor = -1;
              cur_algorithm_count_indices = -1;
            elseif b == 12
              % Y-intercept: random
              locations_for_scaling_factor = rand_sections_to_count_scaling;
              cur_scaling_factor = scaling_factor_rand_sections;
              cur_algorithm_count_indices = rand_sections_to_count;
            elseif b == 13
              % Y-intercept: stratified
              locations_for_scaling_factor = all_varied_levels_sections;
              cur_scaling_factor = scaling_factor_rand_sections;
              cur_algorithm_count_indices = rand_sections_to_count;
            elseif b == 14
              % Y-intercept: spatial
              locations_for_scaling_factor = cur_spatial_hand_count_indices;
              cur_scaling_factor = scaling_factor_rand_sections;
              cur_algorithm_count_indices = rand_sections_to_count;
            elseif b == 14
              % simulated groundtruth extrapolation
              locations_for_scaling_factor = [];
              cur_scaling_factor = -1;
              cur_algorithm_count_indices = [];
              keyboard;
            end
            locations_for_scaling_factor = locations_for_scaling_factor(:);
            if b == 9 || b == 10 || b == 11
              yield_estimation_location_counts = ground_counts(locations_for_scaling_factor);
              extrapolate_counts = 1;
              if extrapolate_counts == 1
                ratio_not_sampled = sum(valid_counts(:)) / numel(locations_for_scaling_factor);
                total_estimate = sum( yield_estimation_location_counts(:) ) * ratio_not_sampled;
              else
                all_indices = 1:numel(ground_counts);
                all_indices( ismember( all_indices, locations_for_scaling_factor) ) = [];
                
                y_indices = mod( (all_indices-1), size( ground_counts, 1 ) ) + 1;
                x_indices = floor( (all_indices-1) / size( ground_counts, 1 ) ) + 1;
                y_indices = y_indices(:);
                x_indices = x_indices(:);
                y_indices_scaling = mod( (locations_for_scaling_factor - 1), size( ground_counts, 1 ) ) + 1;
                x_indices_scaling = floor( (locations_for_scaling_factor - 1) / size( ground_counts, 1 ) ) + 1;
                
                total_estimate = sum( yield_estimation_location_counts(:) );
                for ii = 1:numel(all_indices)
                  if valid_counts(ii) ~= 1
                    continue;
                  end
                  sigma = size(ground_counts, 1);
                  y_deltas = repmat(y_indices(ii), [numel(y_indices_scaling), 1] ) - y_indices_scaling;
                  x_deltas = repmat(x_indices(ii), [numel(x_indices_scaling), 1] ) - x_indices_scaling;
                  err = ( y_deltas .^ 2 + x_deltas .^ 2 ) .^ 0.5;
                  gaussian_weights = (1/(sigma*(2*pi)^(0.5))).*exp(-0.5*((err./(sigma)).^2));
                  gaussian_weights = gaussian_weights/sum(gaussian_weights);
                  
                  cur_estimate = sum( gaussian_weights(:) .* yield_estimation_location_counts );
                  total_estimate = total_estimate + cur_estimate;
                end
              end
              total_actual = sum(ground_counts(valid_counts(:)));
              error_overall = abs( total_estimate - total_actual ) / total_actual;
              mean_error_each_section = -1;
              error_by_row = -1;
            elseif (b >= 0 && b <= 8) || (b >= 12 && b <= 14)
              % Interpolate scaling factor w/ Y-intercept
              if b == 12 || b == 13 || b == 14
                scaling_method = 3;
              elseif b < 12
                scaling_method = 2;
              else
                % could do prediction/interpolation of scaling factor here
                keyboard;
              end
              [yield_estimation_location_counts] = scale_algorithm_counts( algorithm_counts, ground_counts, cur_scaling_factor, locations_for_scaling_factor, cur_algorithm_count_indices, b, scaling_method );
              if b == 3 && num_sections_for_computer_to_count > 3
                cur_computer_counts_matrix = kriging_algorithm_counts( yield_estimation_location_counts, cur_algorithm_count_indices, algorithm_counts, X, Y );
              else
                cur_computer_counts_matrix = zeros( size(algorithm_counts) );
                cur_computer_counts_matrix(cur_algorithm_count_indices) = yield_estimation_location_counts;
                boolean_cur_computer_counts_matrix = zeros(size(algorithm_counts));
                boolean_cur_computer_counts_matrix(cur_algorithm_count_indices) = 1;
                cur_computer_counts_matrix(~boolean_cur_computer_counts_matrix) = sum( yield_estimation_location_counts ) / numel( yield_estimation_location_counts );
              end
              [mean_error_each_section, error_by_row, error_overall] = compute_errors( cur_computer_counts_matrix, ground_counts, valid_counts );
            elseif b == 15
              estimated_value = sum(cur_hand_sample_scaling_factor(:)) / ratio_hand_sampled;
              error_overall = abs( ( estimated_value - sum(cur_hand_sample_estimate(:)) ) / sum(cur_hand_sample_estimate(:)) );
              mean_error_each_section = -1;
              error_by_row = -1;
            elseif b == 16
              % linear offset function estimate
              p_cur = polyfit( cur_algorithm_counts_perturbed_linear_offset_scaling(:), cur_hand_sample_scaling_factor(:), 1 );
              cur_yield_estimate = p_cur(1) * cur_algorithm_counts_perturbed_linear_offset_estimate + p_cur(2);
              cur_total_yield_estimate = sum( cur_yield_estimate(:) );
              error_overall = abs( ( cur_total_yield_estimate - total_hand_count_valid ) / total_hand_count_valid );
              mean_error_each_section = -1;
              error_by_row = -1;
            elseif b == 17
              % scaling factor estimate
              scaling_factor = sum( cur_algorithm_counts_perturbed_sf_scaling(:) ) / sum( cur_hand_sample_scaling_factor(:) );
              cur_total_yield_estimate = sum( cur_algorithm_counts_perturbed_sf_estimate(:) ) / scaling_factor;
              error_overall = abs( ( cur_total_yield_estimate - total_hand_count_valid ) / total_hand_count_valid );
              mean_error_each_section = -1;
              error_by_row = -1;
            else
              keyboard;
            end
            counting_var = ( ( a-1 ) * num_sampling_strategies ) + b;
            errors_one_iteration_sections( 1, counting_var ) = mean_error_each_section;
            errors_one_iteration_rows( 1, counting_var ) = error_by_row;
            errors_one_iteration_overall( 1, counting_var ) = error_overall;
          end
        end
        computer_errors_section(i, :) = errors_one_iteration_sections(1, :);
        computer_errors_rows(i, :) = errors_one_iteration_rows(1, :);
        computer_errors_overall(i, :) = errors_one_iteration_overall(1, :);
      end
      
      mean_error_all_types_sections = mean(computer_errors_section, 1);
      all_computer_mean_errors( k, m, :, 1 ) = mean_error_all_types_sections(:);
      
      mean_error_all_types_rows = mean(computer_errors_rows, 1);
      all_computer_mean_errors( k, m, :, 2 ) = mean_error_all_types_rows(:);
      
      mean_error_all_types_overall = mean(computer_errors_overall, 1);
      all_computer_mean_errors( k, m, :, 3 ) = mean_error_all_types_overall(:);
      
      if computeStdDev == 1
        std_dev_sections = std(computer_errors_section);
        std_dev_computer_errors(k, m, :, 1) = std_dev_sections;

        std_dev_rows = std(computer_errors_rows);
        std_dev_computer_errors(k, m, :, 2) = std_dev_rows;

        std_dev_overall = std(computer_errors_overall);
        std_dev_computer_errors(k, m, :, 3) = std_dev_overall;
      end
    end
  end
end