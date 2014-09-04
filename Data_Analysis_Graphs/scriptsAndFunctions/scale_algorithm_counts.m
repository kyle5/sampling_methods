function [selected_scaled_algorithm_counts] = scale_algorithm_counts( algorithm_counts, ground_counts, cur_scaling_factor, locations_for_scaling_factor, cur_algorithm_count_indices, b, scaling_method )
  % 
  [rows_cur_map, columns_cur_map] = size(algorithm_counts);
  scaling_factor_individual_plots = ones( rows_cur_map, columns_cur_map );
  if scaling_method == 1
    % Past years yield monitor data will reflect present years yield data
    limits_on_scaling_factors = 0;
    if limits_on_scaling_factors == 1
      all_scaling_factors = algorithm_counts ./ ground_counts;
      all_scaling_factors_mean = mean(all_scaling_factors(:));
      all_scaling_factors_std = std(all_scaling_factors(:));
      min_scaling_factor = all_scaling_factors_mean-all_scaling_factors_std;
      max_scaling_factor = all_scaling_factors_mean+all_scaling_factors_std;
    end
    % Interpolate the 'locations_for_scaling_factor' variable
    if b == 1
      scaling_factor_individual_plots = ones( rows_cur_map, columns_cur_map );
    elseif b == 2
      scaling_factor_individual_plots = cur_scaling_factor * ones( rows_cur_map, columns_cur_map );
    else
      locations_for_scaling_factor_b = false( size(algorithm_counts) );
      locations_for_scaling_factor_b(locations_for_scaling_factor(:)) = true;
      locations_for_scaling_factor_b = locations_for_scaling_factor_b(:);
      predict = 0;
      if predict == 1
        scaling_factor_individual_plots = predict_all_scaling_factors( locations_for_scaling_factor, algorithm_counts, ground_counts );
      else
        scaling_factor_individual_plots = -1*ones(size(algorithm_counts));
        scaling_factor_individual_plots(locations_for_scaling_factor_b) = algorithm_counts(locations_for_scaling_factor_b) ./ ground_counts(locations_for_scaling_factor_b);
        scaling_factor_individual_plots(~locations_for_scaling_factor_b) = sum(algorithm_counts(locations_for_scaling_factor_b)) / sum(ground_counts(locations_for_scaling_factor_b));
      end
%       [locations_for_scaling_factor_y, locations_for_scaling_factor_x] = ind2sub( size(algorithm_counts), locations_for_scaling_factor );
%       input_z = algorithm_counts( locations_for_scaling_factor ) ./ ground_counts( locations_for_scaling_factor );
%       variogram_output = variogram( [ locations_for_scaling_factor_x locations_for_scaling_factor_y ], input_z, 'plotit', false );
%       [ ~, ~, ~, vstruct ] = variogramfit( variogram_output.distance,variogram_output.val,[],[],[],'model','exponential', 'plotit', false );
%       [ scaling_factor_individual_plots ] = kriging( vstruct, locations_for_scaling_factor_x, locations_for_scaling_factor_y, input_z, X, Y );
      if limits_on_scaling_factors == 1
        scaling_factor_individual_plots( scaling_factor_individual_plots > max_scaling_factor ) = max_scaling_factor;
        scaling_factor_individual_plots( scaling_factor_individual_plots < min_scaling_factor ) = min_scaling_factor;
      end
    end
    algorithm_counts_scaled_individually = algorithm_counts(:) ./ scaling_factor_individual_plots(:);
    selected_scaled_algorithm_counts = algorithm_counts_scaled_individually( cur_algorithm_count_indices );
  elseif scaling_method == 2
    % Scale with a common scaling factor
    algorithm_counts_scaled_together = algorithm_counts(:) / cur_scaling_factor;
    selected_scaled_algorithm_counts = algorithm_counts_scaled_together( cur_algorithm_count_indices );
  elseif scaling_method == 3
    % Scale with an interpolated function
    p = polyfit( algorithm_counts(locations_for_scaling_factor), ground_counts(locations_for_scaling_factor), 1 );
    algorithm_counts_scaled = p(1) * algorithm_counts(:) + p(2);
    selected_scaled_algorithm_counts = algorithm_counts_scaled( cur_algorithm_count_indices );
  else
    disp('unknown scaling method');
    keyboard;
  end
end

function [scaling_factor_individual_plots] = predict_all_scaling_factors( locations_for_scaling_factor, algorithm_counts, ground_counts )
  %
  other_locations = 1:numel(algorithm_counts);
  other_locations(locations_for_scaling_factor) = [];
  
  scaling_factor_individual_plots = -1*ones( size( algorithm_counts ) );
  scaling_factor_individual_plots(locations_for_scaling_factor) = algorithm_counts(locations_for_scaling_factor) ./ ground_counts(locations_for_scaling_factor);
  
  % find closest index for other_locations indices ...
  [ other_locations_y, other_locations_x ] = ind2sub( size(algorithm_counts), other_locations );
  [ locations_y, locations_x ] = sub2ind( size(algorithm_counts), locations_for_scaling_factor );
  for i = 1:numel(other_locations)
    other_point_repeated = repmat( [other_locations_x(i), other_locations_y(i)], [numel(locations_y), 1] );
    locations = [locations_x(:), locations_y(:)];
    err = other_point_repeated-locations;
    [~,min_idx] = min(sum(err.*err).^.5);
    cur_best_idx = other_locations(min_idx);
    scaling_factor_individual_plots(i) = scaling_factor_individual_plots(cur_best_idx);
  end
end