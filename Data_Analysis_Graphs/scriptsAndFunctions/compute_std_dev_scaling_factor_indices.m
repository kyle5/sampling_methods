function [ rand_sections_to_count_scaling_std_dev, scaling_factor_std_dev ] = compute_std_dev_scaling_factor_indices( algorithm_counts, ground_counts, distribution_lower, distribution_higher, num_sections_to_compute_scaling_factor, rand_sections_to_count_scaling, original_valid_idx, valid_counts )
  % Seperate function to compute standard deviation
  invalid = false( size(algorithm_counts) );
  invalid( original_valid_idx ) = true;
  invalid( valid_counts ) = true;
  
  if numel(rand_sections_to_count_scaling) > numel(original_valid_idx)
    rand_sections_to_count_scaling_std_dev = rand_sections_to_count_scaling;
  elseif numel(rand_sections_to_count_scaling) == numel(original_valid_idx)
    rand_sections_to_count_scaling_std_dev = rand_sections_to_count_scaling;
  else
    extreme_indices = ceil( ( [distribution_higher(1), distribution_higher(end), distribution_lower(1), distribution_lower(end)] ) * numel( original_valid_idx(:) ) );
    bad_indices = sum(extreme_indices == numel(original_valid_idx(:))) == 0 || sum(extreme_indices == 1) == 0 || sum(extreme_indices < 1) || sum(extreme_indices > numel(original_valid_idx(:)));
    if sum(bad_indices(:)) > 0; keyboard; end
    unique_distribution_lower_indices = unique( distribution_lower * 1:numel( original_valid_idx(:) ) );
    unique_distribution_higher_indices = unique( distribution_higher * 1:numel( original_valid_idx(:) ) );
    numel_unique_distribution_lower = numel(unique_distribution_lower_indices);
    numel_unique_distribution_higher = numel(unique_distribution_higher_indices);
    if numel_unique_distribution_lower < numel(original_valid_idx); keyboard; end
    if numel_unique_distribution_higher < numel(original_valid_idx); keyboard; end
    sections_needed = num_sections_to_compute_scaling_factor;
    all_actual_indices = [];
    invalid = false( size(algorithm_counts) );
    invalid(~valid_counts) = true;
    if sections_needed > sum(invalid); keyboard; end
    while sections_needed > 0
      cur_random_numbers = ceil( rand(1, sections_needed) * numel(distribution_lower) );
      lower_std = 1;
      if lower_std == 1
        idx_ratio = distribution_lower(cur_random_numbers);
      else
        idx_ratio = distribution_higher(cur_random_numbers);
      end
      cur_actual_indices = unique( ceil( numel( original_valid_idx ) * idx_ratio ) );
      % Find the unique indices
      invalid(all_actual_indices) = true;
      invalid_locations = invalid(cur_actual_indices);
      cur_actual_indices_valid = cur_actual_indices( ~invalid_locations );
      all_actual_indices = [ all_actual_indices(:); cur_actual_indices_valid(:) ];
      sections_needed = num_sections_to_compute_scaling_factor - numel(all_actual_indices);
    end
    rand_sections_to_count_scaling_std_dev = original_valid_idx( all_actual_indices );
  end
  scaling_factor_std_dev = sum( algorithm_counts( rand_sections_to_count_scaling_std_dev(:) ) ) / sum( ground_counts( rand_sections_to_count_scaling_std_dev(:) ) );
end