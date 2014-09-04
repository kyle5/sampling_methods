function plotScalingFactorsHandToComputerCountsEachSection( cur_type_of_apple, computer_counts, hand_counts )
    % This program plots the scaling factors from hand to computer counts
    
    total_sections = numel(computer_counts);
    
    apple_type_dir = ['PNGs/', cur_type_of_apple];
    
    percentage_to_use = 25;
    str_percentage_to_use = num2str(percentage_to_use);
    
    scaling_factors_across_block = computeRatioBetweenMatrices( computer_counts, hand_counts );
    scaling_factors_across_block = scaling_factors_across_block .* 100;
    
    [ rows_cur_map, columns_cur_map ] = size( scaling_factors_across_block );
    
    scaling_factor_to_smooth_image = 10;
    [ X, Y ] = getAllXAndYValuesInExpandedImage( columns_cur_map, rows_cur_map, scaling_factor_to_smooth_image );
    
    max_count = max(scaling_factors_across_block(:));
    min_count = min(scaling_factors_across_block(:));
    
    scale_color_bar_min = min_count - abs(min_count) * 0.1;
    scale_color_bar_max = max_count + abs(max_count) *0.1;    
    
    title_input = 'Scaling Factors for Every Section';
    colorBarTitle = 'Scaling Factor';
    filename = [apple_type_dir, '/Scaling_Factor_Every_Section'];
    
    indices_x = 1:columns_cur_map;
    indices_y = 1:rows_cur_map;
    plotOneMap( cur_type_of_apple, scale_color_bar_min, scale_color_bar_max, scaling_factors_across_block, ...
        rows_cur_map, columns_cur_map, indices_x, indices_y, title_input, colorBarTitle, filename );

    [ scaling_kriging_z_values ] = getKrigingValues( scaling_factors_across_block, 1:total_sections, X, Y, scaling_factor_to_smooth_image );

    [ normalized_scaled_indicies_x, normalized_scaled_indicies_y ] = expandIndiciesForPlottingMaps(columns_cur_map, rows_cur_map, scaling_factor_to_smooth_image);
    
    title_input = 'Scaling Factors for Every Section';
    colorBarTitle = 'Scaling Factor (Percent)';
    filename = [apple_type_dir, '/Scaling_Factor_Every_Section_Smoothed'];
    plotOneMap( cur_type_of_apple, scale_color_bar_min, scale_color_bar_max, scaling_kriging_z_values, ...
        rows_cur_map, columns_cur_map, normalized_scaled_indicies_x, normalized_scaled_indicies_y, title_input, colorBarTitle, filename );
    
    num_rand_sections = floor(percentage_to_use*total_sections/100);
    rand_sections_to_count = randomlySelectDiscontinuousSections(total_sections, num_rand_sections);
    
    [ scaling_kriging_z_values ] = getKrigingValues( scaling_factors_across_block, rand_sections_to_count, X, Y, scaling_factor_to_smooth_image );

    title_input = ['Scaling Factors for ', str_percentage_to_use, '% of Sections : ', cur_type_of_apple];
    colorBarTitle = 'Scaling Factor';
    filename = [apple_type_dir, '/Scaling_Factor_Rand_Sections_Smoothed'];
    plotOneMap( cur_type_of_apple, scale_color_bar_min, scale_color_bar_max, scaling_kriging_z_values, ...
        rows_cur_map, columns_cur_map, normalized_scaled_indicies_x, normalized_scaled_indicies_y, title_input, colorBarTitle, filename );
end