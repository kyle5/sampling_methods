function kriging_algorithm_counts( selected_scaled_algorithm_counts, cur_algorithm_count_indices, algorithm_counts, X, Y )
  [rows_cur_map, columns_cur_map] = size( algorithm_counts );
  try
    % Special operation: Kriging
    if computeKriging == 1
      max_selected_scaled_algorithm_counts = max( selected_scaled_algorithm_counts(:) );
      min_selected_scaled_algorithm_counts = min( selected_scaled_algorithm_counts(:) );
      [cur_algorithm_counts_y, cur_algorithm_counts_x] = ind2sub( [rows_cur_map, columns_cur_map], cur_algorithm_count_indices );
      try
        variogram_output = variogram( [ cur_algorithm_counts_x(:) cur_algorithm_counts_y(:) ], selected_scaled_algorithm_counts(:), 'plotit', false );
      catch
        keyboard;
      end
      [ ~, ~, ~, vstruct ] = variogramfit( variogram_output.distance,variogram_output.val,[],[],[],'model','exponential', 'plotit', false );
      try
        [ comp_kriging_z_values_unorganized, ~ ] = kriging( vstruct, cur_algorithm_counts_x(:), cur_algorithm_counts_y(:), selected_scaled_algorithm_counts(:), X(:), Y(:) );
      catch
        keyboard;
      end
      comp_kriging_z_values_unorganized( comp_kriging_z_values_unorganized > max_selected_scaled_algorithm_counts ) = max_selected_scaled_algorithm_counts;
      comp_kriging_z_values_unorganized( comp_kriging_z_values_unorganized < min_selected_scaled_algorithm_counts ) = min_selected_scaled_algorithm_counts;
      comp_kriging_z_values_organized = comp_kriging_z_values_unorganized;
      cur_computer_counts_matrix = reshape( comp_kriging_z_values_organized, size(algorithm_counts) );
    else
      cur_computer_counts_matrix = ones( size(algorithm_counts) );
    end
  catch
    cur_computer_counts_matrix = zeros( size(algorithm_counts) );
    cur_computer_counts_matrix(cur_algorithm_count_indices) = selected_scaled_algorithm_counts;
    boolean_cur_computer_counts_matrix = zeros(size(algorithm_counts));
    boolean_cur_computer_counts_matrix(cur_algorithm_count_indices) = 1;
    cur_computer_counts_matrix(~boolean_cur_computer_counts_matrix) = sum( selected_scaled_algorithm_counts ) / numel(cur_algorithm_count_indices);
  end
end