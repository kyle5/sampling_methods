function [ all_varied_levels_sections, varied_levels_scaling_factor ] = get_varied_levels_scaling_data( algorithm_counts, ground_counts, rand_sections_to_count, cur_spatial_algorithm_count_indices, num_sections_to_compute_scaling_factor, valid_counts )
  varied_sections_step = numel(rand_sections_to_count(:)) / (num_sections_to_compute_scaling_factor+1);
  unscaled_sampled = algorithm_counts( rand_sections_to_count(:) );
  [ ~, ascending_count_indices ] = sort( unscaled_sampled(:) );
  systematic = 0;
  if systematic == 1
    median_indices = varied_sections_step:varied_sections_step:(varied_sections_step*num_sections_to_compute_scaling_factor);
    if sum( median_indices > numel( ascending_count_indices(:) ) ) > 0; keyboard; end
    rounded_median_indices = unique( round( median_indices ) );
  else
    % stratified random
    % keep cur start and end indices in variable
    rounded_median_indices = zeros(num_sections_to_compute_scaling_factor, 1);
    cur_start = 1;
    for i = 1:num_sections_to_compute_scaling_factor
      cur_end = cur_start + varied_sections_step;
      % get a random location from the current location
      cur_start_rounded = round( cur_start );
      cur_end_rounded = round( cur_end );
      cur_middle = round(cur_start_rounded + (cur_end_rounded - cur_start_rounded)/2);
      if cur_end_rounded > numel(ascending_count_indices); keyboard; end
      sigma = varied_sections_step/5;
      err = (cur_start_rounded:cur_end_rounded) - cur_middle;
      gaussian_weights = (1/(sigma*(2*pi)^(0.5))).*exp(-0.5*((err./(sigma)).^2));
      gaussian_weights = gaussian_weights/sum(gaussian_weights);
      rand_cur = rand(1);
      cdf_start = 0;
      rand_between = -1;
      for j = 1:numel(gaussian_weights)
        cdf_end = cdf_start+gaussian_weights(j);
        if rand_cur > cdf_start && rand_cur < cdf_end
          rand_between = j;
          break;
        end
        cdf_start = cdf_end;
      end
      rounded_median_indices(i, 1) = ((cur_start_rounded-1)+rand_between);
      cur_start = cur_end;
    end
  end
  rounded_median_indices = unique(rounded_median_indices);
  sel_sections_to_sample = ascending_count_indices( rounded_median_indices );
  all_varied_levels_sections = rand_sections_to_count( sel_sections_to_sample );
  random_sections_needed = num_sections_to_compute_scaling_factor - numel(all_varied_levels_sections);
  if random_sections_needed > 0
    [all_varied_levels_sections] = create_additional_random_indices( algorithm_counts, all_varied_levels_sections, random_sections_needed, valid_counts );
  end
  if numel(unique(all_varied_levels_sections)) < num_sections_to_compute_scaling_factor
    keyboard;
  end
  varied_levels_scaling_factor = sum( algorithm_counts( all_varied_levels_sections ) ) / sum( ground_counts( all_varied_levels_sections ) );
end