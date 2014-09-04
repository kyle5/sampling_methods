function plotErrorMap( cur_type_of_apple, pc_image_used, hand_image_used, scaling_factor_computer_to_hand_count )
    
    pc_image_used_scaled = pc_image_used./scaling_factor_computer_to_hand_count;

    dif_matrix = (pc_image_used_scaled - hand_image_used);
    error_matrix = dif_matrix ./ hand_image_used;
    error_matrix = error_matrix .* 100;
    
    % Need to show the plain error values and the error values after they
    % have undergone Kriging
    [ rows_cur_map, columns_cur_map ] = size( error_matrix );
    total_sections = rows_cur_map * columns_cur_map;
    
    scaling_factor_to_smooth_image = 10;
    [ X, Y ] = getAllXAndYValuesInExpandedImage( columns_cur_map, rows_cur_map, scaling_factor_to_smooth_image );
    
    scale_color_bar_max = 50;
    scale_color_bar_min = -50;
    
    title_input = {cur_type_of_apple, 'Algorithm Error'};
    colorBarTitle = 'Error (Percent)';
    filename = ['PNGs/', cur_type_of_apple,'/errorValuesNotSmoothed'];
    
    indices_x = 1:columns_cur_map;
    indices_y = 1:rows_cur_map;
    plotOneMap( cur_type_of_apple, scale_color_bar_min, scale_color_bar_max, error_matrix, ...
        rows_cur_map, columns_cur_map, indices_x, indices_y, title_input, colorBarTitle, filename );
    
    [ normalized_scaled_indicies_x, normalized_scaled_indicies_y ] = expandIndiciesForPlottingMaps(columns_cur_map, rows_cur_map, scaling_factor_to_smooth_image);
    
    [ error_kriging_z_values ] = getKrigingValues( error_matrix, 1:total_sections, X, Y, scaling_factor_to_smooth_image );
    filename = ['PNGs/', cur_type_of_apple,'/errorValuesSmoothed'];
    plotOneMap( cur_type_of_apple, scale_color_bar_min, scale_color_bar_max, error_kriging_z_values, ...
        rows_cur_map, columns_cur_map, normalized_scaled_indicies_x, normalized_scaled_indicies_y, title_input, colorBarTitle, filename );
end