function analyze_apple_data( green_pc_counts, green_ground_counts, red_thinned_pc_counts, red_thinned_ground_counts )
  scaling_factors_green = green_pc_counts./green_ground_counts;
  scaling_factors_red = red_thinned_pc_counts./red_thinned_ground_counts;
  avg_scaling_factor_green = sum(green_pc_counts(:))/sum(green_ground_counts(:));
  avg_scaling_factor_red = sum(red_thinned_pc_counts(:))/sum(red_thinned_ground_counts(:));
  
  scaling_factor_error_green = abs(scaling_factors_green-avg_scaling_factor_green)/avg_scaling_factor_green;
  scaling_factor_error_red = abs(scaling_factors_red-avg_scaling_factor_red)/avg_scaling_factor_red;
  
  green_valid_counts = green_pc_counts ~= -1 & green_ground_counts ~= -1;
  red_valid_counts = red_thinned_pc_counts ~= -1 & red_thinned_ground_counts ~= -1;
  
  [ std_dev_green, original_valid_idx_green ] = get_std_dev_map( green_pc_counts, 1:numel(green_pc_counts) );
  [ std_dev_red, original_valid_idx_red ] = get_std_dev_map( red_thinned_pc_counts, 1:numel(red_thinned_pc_counts) );
  
  visualize = 0;
  if visualize == 1
    figure, imagesc( green_pc_counts );
    figure, imagesc( scaling_factor_error_green );
    figure, imagesc( reshape( std_dev_green, size(green_pc_counts) ) );

    figure, imagesc( red_thinned_pc_counts );
    figure, imagesc( scaling_factor_error_red );
    figure, imagesc( reshape( std_dev_red, size(red_thinned_pc_counts) ) );
  end
  total_sections = numel( red_thinned_ground_counts );
  
  times_to_test = 100;
  
  num_intervals = 20;
  starting_point = 3;
  increment = floor( (total_sections-starting_point) / num_intervals );
%   counts = starting_point:increment:total_sections;
  counts = [50];
  
  avg_error_values_entire_set = [];
  avg_error_values_editted = [];

  errors_overall = [];
  metric_values = [];
  
  % cur_ground_counts = red_thinned_ground_counts;
  cur_ground_counts = green_ground_counts;
  % cur_algorithm_counts = red_thinned_pc_counts;
  cur_algorithm_counts = green_pc_counts;
%   cur_valid_counts = red_valid_counts;
  cur_valid_counts = green_valid_counts;
  % cur_scaling_factor = avg_scaling_factor_red;
  cur_scaling_factor = avg_scaling_factor_green;
  cur_total_groundtruth = sum(cur_ground_counts(:));
  cur_total_detected = sum(cur_algorithm_counts(:));
  
  only_use_low_std_dev_indices = false;
  use_high_counts = false;
  use_medium_counts = false;
  use_low_counts = false;
  only_use_high_metric_score_points = true;
  spatial_metric = true;
  stratified_metric = false;
  combined_metric = false;
  
  for j = 1:numel(counts)
    random_indices_to_obtain = counts( j );
    error_values_entire_set = cell( times_to_test, 1 );
    error_values_editted_set = cell( times_to_test, 1 );
    for i = 1:times_to_test
      random_indices_possible = randperm( total_sections );
      random_indices = random_indices_possible( 1:random_indices_to_obtain );
      cur_algorithm_counts_sel = cur_algorithm_counts( random_indices );
      cur_ground_counts_sel = cur_ground_counts( random_indices );

      if use_high_counts || use_medium_counts || use_low_counts
        [cur_algorithm_counts_sorted, cur_algorithm_counts_sorted_idx] = sort( cur_algorithm_counts(:) );
        step_increment = floor( numel(cur_algorithm_counts_sorted_idx) / 3 );
        if use_low_counts
          index_temp = 1;
        elseif use_medium_counts
          index_temp = 2;
        elseif use_high_counts
          index_temp = 3;
        end
        idx_temp_start = ( index_temp - 1 ) * step_increment + 1;
        idx_temp_end = ( index_temp ) * step_increment;
        possible_editted_indices = cur_algorithm_counts_sorted_idx( idx_temp_start:idx_temp_end );
        temp = randperm(numel(possible_editted_indices));
        possible_editted_indices_mixed = possible_editted_indices(temp);
        num_needed = numel(random_indices) - numel(possible_editted_indices_mixed);
        add_ons = 1:total_sections;
        add_ons( ismember( add_ons, possible_editted_indices_mixed ) ) = [];
        add_ons_mixed = add_ons( randperm( numel(add_ons) ) );
        last_idx = min( numel( possible_editted_indices_mixed), numel(random_indices) );
        good = possible_editted_indices_mixed(1:last_idx);
        bad = add_ons_mixed(1:num_needed);
        editted_indices = [ good(:); bad(:) ];
      elseif only_use_low_std_dev_indices
        scaling_factors_entire_set = cur_algorithm_counts_sel ./ cur_ground_counts_sel;
        scaling_factors_mean = mean( scaling_factors_entire_set );
        scaling_factors_std = std( scaling_factors_entire_set ) / scaling_factors_mean;
        scaling_factors_std_rel = scaling_factors_std / scaling_factors_mean;
        delta_scaling_factors = abs( scaling_factors_entire_set - scaling_factors_mean );
        invalid = delta_scaling_factors > scaling_factors_std_rel;
        random_indices_valid = random_indices(~invalid);
        random_indices_valid = random_indices_valid(:);
        num_to_add_on = sum(invalid);
        % Replace with other indices that have not been sampled yet
        random_indices_possible_next_addition = random_indices_possible;
        random_indices_possible_next_addition( ismember( random_indices_possible_next_addition, random_indices ) ) = [];
        second_addition_number = min( num_to_add_on, numel(random_indices_possible_next_addition) );
        random_indices_second_addition = random_indices_possible_next_addition( 1:second_addition_number );
        editted_indices = [random_indices_valid; random_indices_second_addition(:)];
      elseif only_use_high_metric_score_points
        % For the current set get the top 10% of points by spatial metric,
        % stratified metric, and combined metric

        cur_scaling_factor = sum(cur_algorithm_counts(random_indices))/sum(cur_ground_counts(random_indices));
        cur_computer_counts_matrix = cur_algorithm_counts/cur_scaling_factor;
        ground_counts = cur_ground_counts;
        % Get the error values of the set
        [mean_error_each_section, error_by_row, error_overall_cur] = compute_errors( cur_computer_counts_matrix, ground_counts, cur_valid_counts );
        
        score_spatial_cur = evaluate_locations_spatially( random_indices, cur_algorithm_counts );
        score_stratified_cur = evaluate_locations_stratification( random_indices, cur_algorithm_counts );
        num_indices = numel(score_spatial_cur);
        if spatial_metric
          metric_values = [metric_values; score_spatial_cur];
        elseif stratified_metric
          metric_values = [metric_values; score_stratified_cur];
        elseif combined_metric
          weight_spatial = 0.8;
          weight_stratified = 1-weight_spatial;
          score_combined_cur = score_spatial_cur*weight_spatial+score_stratified_cur*weight_stratified;
          metric_values = [metric_values; score_combined_cur];
        end
        
        errors_overall = [errors_overall; error_overall_cur];
        editted_indices = [random_indices];
      end
      if numel(editted_indices) ~= numel( unique( editted_indices ) ); keyboard; end
      if numel(random_indices) ~= numel( unique( random_indices ) ); keyboard; end
      if numel(editted_indices) > numel(random_indices); keyboard; end
      scaling_factor_entire_set = sum(cur_algorithm_counts_sel)/sum(cur_ground_counts_sel);
      estimated_entire_set = cur_total_detected/scaling_factor_entire_set;
      error_entire_set = abs( estimated_entire_set - cur_total_groundtruth )/ cur_total_groundtruth;
      error_values_entire_set{i} = error_entire_set;

      scaling_factor_editted_set = sum(cur_algorithm_counts(editted_indices))/sum(cur_ground_counts(editted_indices));
      estimated_editted_set = cur_total_detected/scaling_factor_editted_set;
      error_editted_set = abs( estimated_editted_set - cur_total_groundtruth )/ cur_total_groundtruth;
      error_values_editted_set{i} = error_editted_set;
    end

    entire_set_error = mean([error_values_entire_set{:}]);
    editted_set_error = mean([error_values_editted_set{:}]);
    if isnan( editted_set_error ); editted_set_error = entire_set_error; end
    avg_error_values_entire_set = [avg_error_values_entire_set; entire_set_error];
    avg_error_values_editted = [avg_error_values_editted; editted_set_error];
  end
  figure;
  plot( counts, avg_error_values_entire_set, 'r-' );
  hold on;
  plot( counts, avg_error_values_editted, 'g-' );
  axis( [0, max(counts), 0, 0.4] );
  [~, errors_idx_sorted] = sort( errors_overall );
  total = numel(errors_idx_sorted);
  half_way = ceil(total/2);
  figure, plot( errors_overall(errors_idx_sorted(1:half_way)), metric_values(errors_idx_sorted(1:half_way)), 'g*' );
  hold on;
  plot( errors_overall(errors_idx_sorted(half_way:total)), metric_values(errors_idx_sorted(half_way:total)), 'r*' );
  axis( [0, max(errors_overall), 0, max(metric_values) ] );
%   keyboard;
end