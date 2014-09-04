% baysian_hand_count_indices: the hand count indices calculated by a method  
% algorithm_count_indices_before_repetition: random
% times_algorithm_counts_repeated: The number of times to repeat the algorithm counts call
% percent_original: percent of the hand indices that were calculated by a method   
% algorithm_counts: the algorithm counts registered
% ground_counts: the hand counts taken from the ground

% To use augmented hand counts just pass in as baysian_hand_count_indices
% % Will iterate through the baysian indices for both original and calibrated
function [final_hand_count_indices, final_algorithm_count_indices] = perfect_algorithm_and_hand_indices_set( baysian_hand_count_indices, algorithm_count_indices_before_repetition, times_algorithm_counts_repeated, percent_original, algorithm_counts, ground_counts, valid_counts )
  %
  total_sections = numel(algorithm_counts);
  
  if percent_original > 1
    percent_original = percent_original / 100;
  end
  
  all_error_values = -1 * ones( size( baysian_hand_count_indices, 1 ), size( algorithm_count_indices_before_repetition, 2 ) );
  final_hand_count_indices = cell( size( baysian_hand_count_indices, 1 ), size( algorithm_count_indices_before_repetition, 2 ) );
  baysian_index_count = 1;
  for i = 1:size( baysian_hand_count_indices, 1 )
    num_sections_hand_counted = numel( baysian_hand_count_indices{ i, 1 } );
    mod_baysian_index_count = mod( baysian_index_count-1, size(baysian_hand_count_indices, 2) )+1;
    for j = 1:size( algorithm_count_indices_before_repetition, 2 )
      cur_random_num = rand(1);
      use_original = true;
      if cur_random_num < percent_original
        use_original = true;
      end
      % if : use the original indices
      if use_original
        baysian_index_count = baysian_index_count + 1;
        cur_hand_count_indices = baysian_hand_count_indices{i, mod_baysian_index_count};
      else
        if baysian_index_count > size(baysian_hand_count_indices, 2) && rand(1) > 0.5
          cur_hand_count_indices = randomlySelectDiscontinuousSections( total_sections, num_sections_hand_counted, valid_counts );
        else
          baysian_index_count = baysian_index_count + 1;
          cur_hand_count_indices = baysian_hand_count_indices{i, mod_baysian_index_count};
        end
        cur_algorithm_indices = algorithm_count_indices_before_repetition{ end, j };
        [cur_hand_count_indices, percent_error_ending] = perfect_indices( cur_hand_count_indices, cur_algorithm_indices, algorithm_counts, ground_counts );
        all_error_values(i, j) = percent_error_ending;
      end
      final_hand_count_indices{i, j} = cur_hand_count_indices;
    end
  end
  
  average_error_values = -1* size( all_error_values, 1 );
  for i = 1:size( all_error_values, 1 );
    cur_error_values = all_error_values( i, : );
    cur_avg = mean( cur_error_values( cur_error_values ~= -1 ) );
    average_error_values(i) = cur_avg;
  end
  figure, plot( 1:numel(average_error_values), average_error_values );
  % augment the algorithm indices
  % need to have a special case for when 100% algorithm counts
  % % Because augmented algorithm indices would be the same as the original algorithm indices 
  [final_algorithm_count_indices] = extend_algorithm_counts_through_augmentation( algorithm_count_indices_before_repetition, times_algorithm_counts_repeated, algorithm_counts );
end

function [ cur_algorithm_indices, percent_error_ending_abs ] = perfect_indices( cur_hand_count_indices, cur_algorithm_indices, algorithm_counts, ground_counts )
  %
  % areas uncovered in stratified space:
  % look at random points
  % if improves stratified seperation and algorithm counts
  % % then change indices

  if numel( cur_hand_count_indices ) > 40;
    keyboard;
  end
  
  scaling_factors = algorithm_counts(:) ./ ground_counts(:);
  percent_error = 0.03;
  [scaling_factor_is_off, total_estimated_is_too_high, scaling_factor, percent_error_starting] = is_scaling_factor_off( ground_counts, algorithm_counts, cur_hand_count_indices, cur_algorithm_indices, percent_error );
  
  last_estimate = total_estimated_is_too_high;
  best_indices = cur_hand_count_indices;
  percent_error_last = percent_error_starting;
  while scaling_factor_is_off
    if scaling_factor_is_off
      [is_currently_in_use] = ismember( 1:numel(ground_counts), cur_hand_count_indices );
      is_currently_in_use = is_currently_in_use(:);
      if total_estimated_is_too_high
        disp('total_estimated_is_too_high');
        % Need to lower the count 
        % Need to raise the scaling factor : since: 
        % % <scaling factor> = sum(algorithm_counts(locations_for_scaling_factor_b)) / sum(ground_counts(locations_for_scaling_factor_b));
        % Find index were algorithm_count(idx)/ground_count(idx) is higher than the average 
        possible_indices_to_add = scaling_factors > scaling_factor & ~is_currently_in_use;
        possible_indices_to_remove = scaling_factors <= scaling_factor & is_currently_in_use;
      else
        disp('total estimated is not too high');
        % Need to raise the count 
        % Need to lower the scaling factor : since: 
        % % <scaling factor> = sum(algorithm_counts(locations_for_scaling_factor_b)) / sum(ground_counts(locations_for_scaling_factor_b));
        % Find index were algorithm_count(idx)/ground_count(idx) is lower than the average 
        possible_indices_to_add = scaling_factors < scaling_factor & ~is_currently_in_use;
        possible_indices_to_remove = scaling_factors >= scaling_factor & is_currently_in_use;
      end
      if sum( possible_indices_to_add & possible_indices_to_remove ) ~= 0; keyboard; end
      try
        % Find the scaling factor that is the minimum distance away from the current scaling factor 
        scaling_factors_wo_cur = scaling_factors;
        scaling_factors_wo_cur(scaling_factors_wo_cur==scaling_factor) = [];
        [~, min_add_idx] = min( abs( scaling_factors(possible_indices_to_add) - scaling_factor ) );
        possible_indices_to_add_valid = find( possible_indices_to_add );
        index_to_add = possible_indices_to_add_valid(min_add_idx);
        
        [~, min_remove_idx] = min( abs( scaling_factors(possible_indices_to_remove) - scaling_factor ) );
        possible_indices_to_remove_valid = find( possible_indices_to_remove );
        index_to_remove = possible_indices_to_remove_valid(min_remove_idx);
        
        if sum( cur_hand_count_indices == index_to_add ) ~= 0 || sum( cur_hand_count_indices == index_to_remove ) == 0; keyboard; end
        cur_hand_count_indices( cur_hand_count_indices == index_to_remove ) = [];
        cur_hand_count_indices = [ cur_hand_count_indices(:); index_to_add ];
      catch
        scaling_factor_is_off = false;
        keyboard;
      end
    end
    if scaling_factor_is_off == true
      [scaling_factor_is_off, total_estimated_is_too_high, scaling_factor, percent_error_cur] = is_scaling_factor_off( ground_counts, algorithm_counts, cur_hand_count_indices, cur_algorithm_indices, percent_error );
      if last_estimate ~= total_estimated_is_too_high;
        if abs(percent_error_cur) > abs(percent_error_last); cur_hand_count_indices = best_indices; end
        break;
      end
      best_indices = cur_hand_count_indices;
    end
  end
  [~, ~, ~, percent_error_ending] = is_scaling_factor_off( ground_counts, algorithm_counts, cur_hand_count_indices, cur_algorithm_indices, percent_error );
  fprintf( 'Optimization finished\nEnding error: %.2f\n', percent_error_ending );
  if abs( percent_error_ending ) > abs( percent_error_starting )
    keyboard;
  end
  percent_error_ending_abs = abs(percent_error_ending);
  
  if numel( cur_hand_count_indices ) > 40;
    keyboard;
  end
end

function [scaling_factor_is_off, total_estimated_is_too_high, cur_scaling_factor, error] = is_scaling_factor_off( ground_counts, algorithm_counts, cur_hand_count_indices, cur_algorithm_indices, percent_error )
  %
  scaling_factor_is_off = false;
  cur_scaling_factor = sum(algorithm_counts(cur_hand_count_indices))/sum(ground_counts(cur_hand_count_indices));
  unscaled_counts = sum(algorithm_counts(cur_algorithm_indices));
  scaled_counts = unscaled_counts / cur_scaling_factor;
  percent_sampled = numel(cur_algorithm_indices)/numel(ground_counts);
  total_estimated = scaled_counts/percent_sampled;
  total_ground = sum(ground_counts(:));
  error = (total_estimated-total_ground)/total_ground;
  if abs(error) > 1; keyboard; end
  if abs(error) > percent_error; scaling_factor_is_off = true; end
  total_estimated_is_too_high = false;
  if total_estimated > total_ground; total_estimated_is_too_high = true; end
%   keyboard;
end

function [ extended_indices ] = extend_algorithm_counts_through_augmentation( algorithm_count_indices_before_repetition, times_algorithm_counts_repeated, algorithm_counts )
  % 
  extended_indices = cell( [1, times_algorithm_counts_repeated] .* size( algorithm_count_indices_before_repetition) );
  s_org = size(algorithm_count_indices_before_repetition);
  [extended_indices{ 1:s_org(1), 1:s_org(2) }] = algorithm_count_indices_before_repetition{:};
  for i = 1:( times_algorithm_counts_repeated - 1 )
    randomize_these_indices = 0;
    if randomize_these_indices == 1
      algorithm_count_indices_after_repetition = randomize_indices( algorithm_count_indices_before_repetition, algorithm_counts );
    else
      algorithm_count_indices_after_repetition = algorithm_count_indices_before_repetition;
    end
    
    start_x = (i-1)*s_org(2)+1;
    end_x = i*s_org(2);
    start_y = 1;
    end_y = s_org(1);
    [extended_indices{ start_y:end_y, start_x:end_x }] = algorithm_count_indices_after_repetition{:};
  end
  
end

function [algorithm_count_indices] = randomize_indices( algorithm_count_indices, algorithm_counts )
  %
%   This will be necessary when not all algorithm count indices are used
  
%   for i = size( algorithm_count_indices, 1 )
%     for j = size( algorithm_count_indices, 2 )
%       %
%       
%     end
%   end
end