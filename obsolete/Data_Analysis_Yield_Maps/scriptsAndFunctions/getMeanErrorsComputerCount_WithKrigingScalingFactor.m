function [ all_computer_mean_errors, std_dev_computer_errors ] = ...
    getMeanErrorsComputerCount( pc_counts, ground_counts, actually_counted, increment)
    
    global loop_iterations;
    global percentages_to_check;
    
    [ rows_cur_map, columns_cur_map ] = size( pc_counts );
    
    total_sections = numel(ground_counts);
    spaces_total_sections = ceil(total_sections/increment);
    
    total_percentages = numel(percentages_to_check);
    types_of_error_calcs = 8;
    
    all_computer_mean_errors = ones(total_percentages, spaces_total_sections, types_of_error_calcs);
    std_dev_computer_errors = ones(total_percentages, spaces_total_sections, types_of_error_calcs);
    
    scaling_factor_to_apply_to_image = 1;
    
    [ X, Y ] = getAllXAndYValuesInExpandedImage( rows_cur_map, columns_cur_map, scaling_factor_to_apply_to_image );
    larger_image_template = X;
    [ tree_locations_x, tree_locations_y ] = getTreeLocationsInExpandedImage( rows_cur_map, columns_cur_map, scaling_factor_to_apply_to_image );

    scaling_factor_map = computeRatioBetweenMatrices( pc_counts, ground_counts );
    
    % Kriging results in failure with only one point, so we need to start
    % with at least 2 sections
    starting_point = max(2, increment);
    
    for k = 1:total_percentages
        % The Hand count for extrapolation is setup to be a percentage of the
        % total orchard sections (100, 50, 25, or 10 percent of all sections)
        cur_percentage_of_sections_hand_counted = percentages_to_check(1, k);
        
        ratio_sections_hand_counted = cur_percentage_of_sections_hand_counted/100;
        num_sections_to_compute_scaling_factor = floor(ratio_sections_hand_counted * total_sections);
        
        computer_mean_errors_one_percentage = ones( 1, spaces_total_sections, types_of_error_calcs );
        
        sections_sampled_counter = 0;
        % Loop through the different amounts of sections that could be
        % computer sampled
        % Because it takes so long for the kriging processes to complete,
        % we need to evaluate only a portion of the total counts
        for num_sections_for_computer_to_count = starting_point:increment:total_sections
            
            % For each number of sections we find the mean error of the
            % computer count by comparing against the actual count
            
            ratio_computer_count_to_total_sections = num_sections_for_computer_to_count/total_sections;
            
            computer_errors_all_types = ones(loop_iterations, types_of_error_calcs);
            
            for i = 1:loop_iterations
                errors_one_iteration = ones(1, 6);
                counting_var = 0;
                for a = 1:2
                    % This is where I can have the two different kinds of
                    % random section selection options
                    if a == 1
                        group_size = 4;
                        rand_sections_to_count = randomlySelectContinuousSections( num_sections_for_computer_to_count, group_size, total_sections, rows_cur_map );
                        rand_sections_to_count_scaling = randomlySelectContinuousSections( num_sections_to_compute_scaling_factor, group_size, total_sections, rows_cur_map );
                    else
                        rand_sections_to_count = randomlySelectDiscontinuousSections( total_sections, num_sections_for_computer_to_count );
                        rand_sections_to_count_scaling = randomlySelectDiscontinuousSections( total_sections, num_sections_to_compute_scaling_factor );
                    end
                    
                    remove = setdiff(rand_sections_to_count_scaling, rand_sections_to_count);
                    keep = setdiff(rand_sections_to_count_scaling, remove);
                    pos_add_on = setdiff(rand_sections_to_count, rand_sections_to_count_scaling);
                    number_to_complete_1 = num_sections_to_compute_scaling_factor - length(keep);
                    % The number to add on might be larger than the number
                    % of elements in add on before
                    add_on_before = pos_add_on(randperm(length(pos_add_on)));
                    add_on_1 = min(number_to_complete_1, length(add_on_before));
                    array_to_add_on = add_on_before(1:add_on_1);
                    keep_and_rand_sections = [ keep, array_to_add_on ];
                    number_to_complete_2 = num_sections_to_compute_scaling_factor - length(keep_and_rand_sections);
                    long_array_to_complete = remove(randperm(length(remove)));
                    array_to_complete = long_array_to_complete( 1:number_to_complete_2 );
                    
                    rand_sections_to_count_scaling_same = [keep_and_rand_sections, array_to_complete];
                    
                    if length(rand_sections_to_count_scaling_same) ~= length(rand_sections_to_count_scaling)
                        error('arrarys are not of the same length');
                    end
                    
                    total_scaling = addSpecifiedMatrixValues( scaling_factor_map, rand_sections_to_count_scaling );
                    scaling_factor_different_locations = total_scaling / num_sections_to_compute_scaling_factor;
                    
                    total_scaling_same = addSpecifiedMatrixValues( scaling_factor_map, rand_sections_to_count_scaling_same );
                    scaling_factor_same_locations = total_scaling_same / num_sections_to_compute_scaling_factor;
                    
                    for b = 1:2
                        if b == 1
                            % Kriging on the computer counts to estimate
                            % the unknown computer count values
                            comp_kriging_z_values = krigingMatrixValuesInExpandedImage(pc_counts, ...
                                rand_sections_to_count, scaling_factor_to_apply_to_image, X, Y);
                            comp_counts_at_tree_locations = getValuesAtLocations( comp_kriging_z_values, tree_locations_x, tree_locations_y, larger_image_template );
                            matrix_values_at_tree_locations = vec2mat( comp_counts_at_tree_locations, columns_cur_map );

                            
                            % Don't need this part for the scaling factor
                            % anymore
                            
                            % Kriging on the known scaling factors to
                            % estimate the unknown scaling factors
                            scaling_factor_kriging_z_values = krigingMatrixValuesInExpandedImage(scaling_factor_map, ...
                                rand_sections_to_count_scaling_same, scaling_factor_to_apply_to_image, X, Y);
                            scaling_factor_values_at_tree_locations = getValuesAtLocations( scaling_factor_kriging_z_values, tree_locations_x, tree_locations_y, larger_image_template );
                            scaling_factor_matrix_same_locations = vec2mat( scaling_factor_values_at_tree_locations, columns_cur_map );
                            
                            % Use the individual scaling factors to scale
                            % the computer counts at each location
                            tree_values_same_locations_varied_scaling = matrix_values_at_tree_locations ./ scaling_factor_matrix_same_locations;
                            
                            estimated_apples_orchard_kriging = addSpecifiedMatrixValues( tree_values_same_locations_varied_scaling, 1:total_sections );
                            cur_error_varied_scaling_factor = computeError( estimated_apples_orchard_kriging, actually_counted );
                            
                            counting_var = counting_var + 1;
                            errors_one_iteration( 1, counting_var ) = cur_error_varied_scaling_factor;
                            
                            % Add up the total computer counts without
                            % scaling to be used with a uniform scaling
                            % factor
                            total_for_uniform_scaling_factor = sum( comp_counts_at_tree_locations(:) );
                        else
                            % Total Computer Count is computed through
                            % extrapolation
                            total_subsampled_count = addSpecifiedMatrixValues( pc_counts, rand_sections_to_count );
                            total_for_uniform_scaling_factor = total_subsampled_count / ratio_computer_count_to_total_sections;
                            
                            cur_error_unscaled = computeError( total_for_uniform_scaling_factor, actually_counted );
                            counting_var = counting_var + 1;
                            errors_one_iteration(1, counting_var) = cur_error_unscaled;
                        end
                        
                        total_count_scaled = total_for_uniform_scaling_factor / scaling_factor_different_locations;
                        
                        cur_error_uniform_scaling_factor = computeError( total_count_scaled, actually_counted );
                        counting_var = counting_var + 1;
                        errors_one_iteration( 1, counting_var ) = cur_error_uniform_scaling_factor;
                    end
                end
                computer_errors_all_types(i, :) = errors_one_iteration(1, :);
            end
            
            mean_error_all_types = mean(computer_errors_all_types);
            cur_std_dev = std(computer_errors_all_types);
            
            sections_sampled_counter = sections_sampled_counter + 1;
            computer_mean_errors_one_percentage(1, sections_sampled_counter, :) = mean_error_all_types;
            std_dev_computer_errors(k, sections_sampled_counter, :) = cur_std_dev;
        end
        all_computer_mean_errors( k, :, : ) = computer_mean_errors_one_percentage;
    end
end