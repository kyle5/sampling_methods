function plotScalingFactorsHandToComputerCounts( cur_type_of_apple, computer_counts, hand_counts )
    % This program plots the scaling factors from hand to computer counts
    
    computer_counts
    hand_counts
    scaling_factors_across_block = computeRatioBetweenMatrices( computer_counts, hand_counts )
    
    [ rows_cur_map, columns_cur_map ] = size( scaling_factors_across_block );
    
    %max_hand_count = max(hand_counts(:));
    %max_computer_count = max(computer_counts(:));
    max_count = max(scaling_factors_across_block(:));
    
    scaling_factor_applied_to_image = 1;
    
    title = 'Scaling Factors for Every Section';
    colorBarTitle = 'Scaling Factor';
    filename = 'PNGs/Green_Test/Scaling_Factor_Every_Section';
    
    plotOneMap( cur_type_of_apple, max_count, scaling_factors_across_block, ...
        rows_cur_map, columns_cur_map, scaling_factor_applied_to_image, title, colorBarTitle, filename );
end