function [ scaling_factor_uncertainty_modelling] = kriging_point_evaluation_code()
  [ X, Y ] = getAllXAndYValuesInExpandedImage( columns_cur_map, rows_cur_map, scaling_factor_to_apply_to_image );
  [ tree_locations_x, tree_locations_y ] = getTreeLocationsInExpandedImage( columns_cur_map, rows_cur_map, scaling_factor_to_apply_to_image );

  [y_orig_points, x_orig_points] = ind2sub( size(ground_counts), 1:numel(ground_counts) );
  if max(x_orig_points(:)) > size(ground_counts, 2) || max(y_orig_points(:)) > size(ground_counts, 1); keyboard; end
%   z_orig_points = algorithm_counts( 1:numel(ground_counts) ) ./ ground_counts( 1:numel(ground_counts) );
  z_orig_points = (x_orig_points(:)'.^2+y_orig_points(:)'.^2).^(0.5);
  indices_stated = [size(x_orig_points); size(y_orig_points); size(z_orig_points)]
  variogram_output = variogram( [ x_orig_points, y_orig_points ], z_orig_points, 'plotit', false, 'maxdist', maxdist, 'nrbins', nrbins );
  [ ~, ~, ~, vstruct_scaling_factor ] = variogramfit( variogram_output.distance, variogram_output.val, [], [], [], 'model', 'exponential', 'plotit', false );
  %
  
  
  z_orig_points = 1:numel(algorithm_counts);
  variogram_output = variogram( [ x_orig_points, y_orig_points ], z_orig_points, 'plotit', false, 'maxdist', maxdist, 'nrbins', nrbins );
  [ ~, ~, ~, vstruct_algorithm_counts ] = variogramfit( variogram_output.distance, variogram_output.val, [], [], [], 'model', 'exponential', 'plotit', false );


  indices_scaling_factor_uncertainty = [];
  while numel( indices_scaling_factor_uncertainty ) < 3
    rand_x_y = floor( rand([1, 2]) .* reshape( size(algorithm_counts), [1, 2]) ) + 1;
    if sum(rand_x_y(:, 1) > size(algorithm_counts, 1)) > 0 || sum(rand_x_y(:, 2) > size(algorithm_counts, 2)) > 0
      keyboard;
    end
    cur_idx = sub2ind( size(algorithm_counts), rand_x_y(:, 1), rand_x_y(:, 2) );
    if sum(cur_idx == indices_scaling_factor_uncertainty ) > 0
      continue;
    else
      indices_scaling_factor_uncertainty = [indices_scaling_factor_uncertainty; cur_idx];
    end
  end
  for ii = 1:num_sections_to_compute_scaling_factor
    if k == 1 || ii < 5
      visualize_maps = 0;
    else
      visualize_maps = 0;
    end
%             if number of points < 3:
%             Pick random points from each of the 3 strata
%               Or even better could have a probability distribution that is strongly skewwed toward the center of the current strata
%             Will need to improve this in the future
    if ii <= numel(indices_scaling_factor_uncertainty)
      % Already setup these points
      continue;
%           else:
    else

%             compute the scaling factors between algorithm and hand counts
%             kriging operation
%             compute the 2D uncertainty for the scaling factors
%               This is the 2D distribution for spatial and standard deviation
%               How to obtain this map of values?
%                 It is just the second output argument from Kriging
      [ orig_y, orig_x ] = ind2sub( size(algorithm_counts), indices_scaling_factor_uncertainty );
      orig_y = orig_y(:);
      orig_x = orig_x(:);
      % Set the z values to be a known function:
      % Just the distance from the "origin"
      alg_counts_scaling_factor_uncertainty = algorithm_counts( indices_scaling_factor_uncertainty );
      hand_counts_scaling_factor_uncertainty = ground_counts( indices_scaling_factor_uncertainty );
      orig_z = alg_counts_scaling_factor_uncertainty ./ hand_counts_scaling_factor_uncertainty;
%               orig_z = (orig_x(:).^2+orig_y(:).^2).^(0.5);
      %
      variogram_output = variogram( [ orig_x, orig_y ], orig_z(:), 'plotit', false );
      [ ~, ~, ~, vstruct_scaling_factor ] = variogramfit( variogram_output.distance, variogram_output.val, [], [], [], 'model', 'exponential', 'plotit', false );
      %%%
      [ scaling_factor_Z, scaling_factor_Z_error ] = kriging( vstruct_scaling_factor, orig_x(:), orig_y(:), orig_z(:), X(:), Y(:) );

      % Nomalize the scaling factor error estimates
      if sum(scaling_factor_Z_error(:)) == 0
        scaling_factor_Z_error = rand(size(scaling_factor_Z_error(:)));
        if ii > 5; keyboard; end
      end
%             Scaling factor probabilities increased
      scaling_factor_Z_error = scaling_factor_Z_error .^ 2;
      scaling_factor_Z_error_normalized = scaling_factor_Z_error / sum( scaling_factor_Z_error(:) );
      if visualize_maps == 1
        figure, imagesc( reshape( scaling_factor_Z, size(algorithm_counts) ) );
        figure, imagesc( reshape( scaling_factor_Z_error_normalized, size(algorithm_counts) ) );
        keyboard;
      end
      %             compute 1D distribution of stratified counts
      % Find sorted indices: These will be set in stratified space
      if visualize_maps == 1
        indices_view = zeros( size( ground_counts ) );
        indices_view( indices_scaling_factor_uncertainty ) = 1;
        figure('Position', [200, 500, 400, 400]), imagesc( indices_view );
        keyboard;
      end
      cur_actual_sorted_indices = original_indices_to_actual_sorted_indices( indices_scaling_factor_uncertainty );
      if visualize_maps == 1
        starting_stratified_visualize = zeros( [1, numel(algorithm_counts)] );
        starting_stratified_visualize( 1, cur_actual_sorted_indices ) = 1;
        figure('Position', [1200, 500, 400, 400]), imagesc( starting_stratified_visualize );
        keyboard;
      end
      cur_x_cords_stratified = cur_actual_sorted_indices;
      cur_y_cords_stratified = ones( [ numel(cur_actual_sorted_indices), 1 ] );
      variogram_output = variogram( [ cur_x_cords_stratified, cur_y_cords_stratified ], algorithm_counts(indices_scaling_factor_uncertainty), 'plotit', false );
      [ ~, ~, ~, vstruct_algorithm_counts ] = variogramfit( variogram_output.distance, variogram_output.val, [], [], [], 'model', 'exponential', 'plotit', false );
      [ ~, Z_error_stratified ] = kriging( vstruct_algorithm_counts, cur_x_cords_stratified, cur_y_cords_stratified, cur_x_cords_stratified, [1:numel(algorithm_counts)]', ones([numel(algorithm_counts), 1]) );
%               [ ~, Z_error_stratified ] = kriging( vstruct_algorithm_counts, cur_x_cords_stratified, cur_y_cords_stratified, algorithm_counts(indices_scaling_factor_uncertainty), [1:numel(algorithm_counts)]', ones([numel(algorithm_counts), 1]) );

      % Normalize and Transfer stratified indices back to original indices
      if sum(Z_error_stratified(:)) == 0
        Z_error_stratified = rand( size(Z_error_stratified(:)) );
        if ii > 5
          keyboard;
        end
      end
      Z_error_stratified = Z_error_stratified .^ 2;
      if visualize_maps == 1
        figure, imagesc( reshape(Z_error_stratified, [1, numel(Z_error_stratified)]) );
        keyboard;
      end
      Z_error_stratified_normalized = Z_error_stratified(:) / sum(Z_error_stratified(:));
      stratified_error_values_normalized_original_indices = Z_error_stratified_normalized( sorted_algorithm_indices );

      % combine both error samples
      weight_scaling_factor = 0.5;
      weight_stratified = 0.5;

      %
%           Now, to obtain the current sample point to be added:
%             Weigh and combine the 2 distributions
%             Linearize the 2D distribution to one distribution
%               Keep track of whether it is indexed by row major order or column major order
      combined_distribution = weight_stratified * stratified_error_values_normalized_original_indices + weight_scaling_factor * scaling_factor_Z_error_normalized;
      if abs( sum( combined_distribution(:) ) - 1) > 0.05
        keyboard;
      end
      combined_distribution_zeroed = combined_distribution;
      combined_distribution_zeroed( indices_scaling_factor_uncertainty ) = 0;
      combined_distribution_zeroed_normalized = combined_distribution_zeroed/sum(combined_distribution_zeroed(:));

%             Pick a random number
      cur_rand_number = rand( 1 );

%               Find which index this is along the linearized 2D joint distribution
%               Get the X and Y coordinates of this linear index
      [combined_distribution_sorted, combined_distribution_indices] = sort(combined_distribution_zeroed_normalized);
      start_interval = 0;
      end_interval = 0;
      cur_sorted_cdf_index = -1;
      for jj = 1:numel(combined_distribution_sorted)
        end_interval = end_interval + combined_distribution_sorted(jj);
        if start_interval < cur_rand_number && cur_rand_number < end_interval
          cur_sorted_cdf_index = jj;
          break;
        end
        start_interval = end_interval;
      end
      if cur_sorted_cdf_index < 1
        keyboard;
      end
      original_cdf_index = combined_distribution_indices( cur_sorted_cdf_index );
      indices_scaling_factor_uncertainty = [ indices_scaling_factor_uncertainty(:); original_cdf_index ];
%           Add the point to the list of points that are known
%             X and Y coordinates too
%               [cur_row_to_add, cur_col_to_add] = ind2sub( size(algorithm_counts), original_cdf_index );

      % Can visualize the additions of indices in both the spatial
      % and the stratified space
    end
  end

  cur_indices_saved_path = sprintf( '/home/kyle/temp_indices/k_%.0f_m_%.0f_i_%.0f_a_%.0f.mat', k, m, i, a );
  save_indices = 1;
  if save_indices == 1
    save( cur_indices_saved_path, 'indices_scaling_factor_uncertainty' );
  else
    load( cur_indices_saved_path, 'indices_scaling_factor_uncertainty' );
  end

  spatial_indices_chosen_visualize = zeros(size(algorithm_counts));
  stratified_indices_chosen_visualize = zeros([1, numel(algorithm_counts)]);

  spatial_indices_chosen_visualize(indices_scaling_factor_uncertainty) = 1;
  indices_chosen_in_stratified_space = original_indices_to_actual_sorted_indices( indices_scaling_factor_uncertainty(:) );
  stratified_indices_chosen_visualize(indices_chosen_in_stratified_space) = 1;

  if visualize_maps == 1
    figure, imagesc( spatial_indices_chosen_visualize );
    figure, imagesc( stratified_indices_chosen_visualize );
    keyboard;
  end

%           scaling_factor_uncertainty_modelling = sum( algorithm_counts(indices_scaling_factor_uncertainty) ) / sum( ground_counts(indices_scaling_factor_uncertainty) );
  [indices_sfu_y, indices_sfu_x] = ind2sub( size(algorithm_counts), indices_scaling_factor_uncertainty );
  indices_sfu_z = algorithm_counts(indices_scaling_factor_uncertainty)./ground_counts(indices_scaling_factor_uncertainty);
  variogram_output = variogram( [ indices_sfu_x, indices_sfu_y ], indices_sfu_z, 'plotit', false );
  [ ~, ~, ~, vstruct_sf ] = variogramfit( variogram_output.distance, variogram_output.val, [], [], [], 'model', 'exponential', 'plotit', false );
  [ Z_sfu, Z_sfu_error ] = kriging( vstruct_sf, indices_sfu_x, indices_sfu_y, indices_sfu_z, X(:), Y(:) );
  median_Z_sfu = median(Z_sfu(:));
  mean_Z_sfu = mean(Z_sfu(:));
  sum_isnan_Z_sfu = sum(isnan(Z_sfu(:)));

  scaling_factor_uncertainty_modelling = median(Z_sfu);

end