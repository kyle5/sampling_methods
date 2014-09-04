function [ all_hand_mean_errors, std_dev_hand_errors ] = getMeanErrorsHandCountPercentages( ground_counts, computeKriging, computeStdDev, valid_counts, parameters )
    
    loop_iterations = parameters.loop_iterations_input;
    percentages_to_check = parameters.percentages_to_check;
    names_of_orchard_areas = parameters.names_of_orchard_areas;
    [ rows_cur_map, columns_cur_map ] = size( ground_counts );
    
    scaling_factor_to_apply_to_image = 1;
    
    [ tree_locations_x, tree_locations_y ] = getTreeLocationsInExpandedImage( columns_cur_map, rows_cur_map, scaling_factor_to_apply_to_image );
    [ X, Y ] = getAllXAndYValuesInExpandedImage( rows_cur_map, columns_cur_map, scaling_factor_to_apply_to_image );
    larger_image_template = X;
    
    total_sections = numel(ground_counts);
    total_percentages = numel(percentages_to_check);
    
    types_of_error_calcs = 4;
    areas_of_orchard = numel(names_of_orchard_areas);
    
    all_hand_mean_errors = ones( total_percentages, 1, types_of_error_calcs, areas_of_orchard );
    std_dev_hand_errors = ones(total_percentages, 1, types_of_error_calcs, areas_of_orchard );
    
    % Instead of looping through and getting the error for each level of
    % sections that were counted, what I need to do here is:
    
    for k = 1:total_percentages
        % The Hand count for extrapolation is setup to be a percentage of the
        % total orchard sections (100, 50, 25, or 10 percent of all sections)
        cur_percentage = percentages_to_check(k);
        ratio_hand_count_to_total_sections = cur_percentage/100;
        num_sections_to_hand_count = floor( ratio_hand_count_to_total_sections * total_sections);
        
        % Only used in the calculation of the scaling factor
        
        all_hand_count_errors_cur_num_sections = ones( loop_iterations, types_of_error_calcs );
        
        hand_count_errors_sections = ones( loop_iterations, types_of_error_calcs );
        hand_count_errors_rows = ones( loop_iterations, types_of_error_calcs ) ;
        hand_count_errors_overall = ones( loop_iterations, types_of_error_calcs );
        
        for i = 1:loop_iterations
            counter_var = 0;
            for j = 1:2
                if j == 1
                    group_size = 4;
                    rand_sections_to_count = randomlySelectContinuousSections( num_sections_to_hand_count, group_size, total_sections, rows_cur_map );
                else
                    rand_sections_to_count = randomlySelectDiscontinuousSections( total_sections, num_sections_to_hand_count, valid_counts );
                end
                
                % For loop through the types of error calculation that can
                % be completed
                for b = 1:2
                    if b == 1
                        cur_hand_counts_matrix = zeros(size(ground_counts));
                        boolean_cur_hand_counts_matrix = zeros(size(ground_counts));
                        
                        cur_hand_counts_matrix(rand_sections_to_count) = ground_counts(rand_sections_to_count);
                        boolean_cur_hand_counts_matrix(rand_sections_to_count) = 1;
                        
                        other_sections = ~boolean_cur_hand_counts_matrix;

                        total_sampled_count = addSpecifiedMatrixValues( ground_counts, rand_sections_to_count );
                        average_computer_count = total_sampled_count ./ num_sections_to_hand_count;
                        cur_hand_counts_matrix(other_sections) = average_computer_count;
                    else
                        if computeKriging == 1

                            hand_kriging_z_values = getKrigingValues( ground_counts, rand_sections_to_count, X, Y, scaling_factor_to_apply_to_image);
                            values_at_tree_locations = getValuesAtLocations( hand_kriging_z_values, tree_locations_x, tree_locations_y );
                            cur_hand_counts_matrix = vec2mat( values_at_tree_locations, columns_cur_map );
                        else
                            cur_hand_counts_matrix = ground_counts;
                        end
                    end                    
                    % Need to do this through the matrix method that I was
                    % doing earlier

                    % In order for standard deviation to be a correct
                    % calculation, we need to get only one error for the
                    % errors of:
                    % Rows
                    % Sections
                    
                    rand_section = randi(total_sections, 1, 1);
                    rand_row = randi( columns_cur_map, 1, 1 );
                    
                    error_by_section = computeAverageErrorBetweenMatrices( cur_hand_counts_matrix, ground_counts, rand_section, 1);
                    
                    hand_counts_by_row = sum( cur_hand_counts_matrix );
                    ground_truth_by_row = sum( ground_counts );
                    error_by_row = computeAverageErrorBetweenMatrices(hand_counts_by_row, ground_truth_by_row, rand_row, 1);

                    hand_counts_overall = sum( hand_counts_by_row(:) );
                    ground_truth_overall = sum( ground_truth_by_row(:) );
                    error_overall = computeAverageErrorBetweenMatrices( hand_counts_overall, ground_truth_overall, 1, 1 );

                    counter_var = counter_var + 1;
                    hand_count_errors_sections(i, counter_var) = error_by_section;
                    hand_count_errors_rows(i, counter_var) = error_by_row;
                    hand_count_errors_overall(i, counter_var) = error_overall;
                end
            end
        end
        
        mean_errors_sections = mean(hand_count_errors_sections);
        mean_errors_rows = mean(hand_count_errors_rows);
        mean_errors_overall = mean(hand_count_errors_overall);
        
        all_hand_mean_errors( k, 1, :, 1 ) = mean_errors_sections;
        all_hand_mean_errors( k, 1, :, 2 ) = mean_errors_rows;
        all_hand_mean_errors( k, 1, :, 3 ) = mean_errors_overall;
        
        if computeStdDev == 1
            std_dev_sections = std(hand_count_errors_sections);
            std_dev_rows = std(hand_count_errors_rows);
            std_dev_overall = std(hand_count_errors_overall);

            std_dev_hand_errors(k, 1, :, 1) = std_dev_sections;
            std_dev_hand_errors(k, 1, :, 2) = std_dev_rows;
            std_dev_hand_errors(k, 1, :, 3) = std_dev_overall;
        end        
    end
end
