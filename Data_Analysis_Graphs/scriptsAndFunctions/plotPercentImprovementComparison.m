function plotPercentImprovementComparison( all_hand_mean_errors_four_d, all_computer_mean_errors_four_d, percentages_to_check, type_of_apple, ...
    Show_Continuous_Blocks_Data, percentage_to_use )
    
    global loop_iterations;
    global area_in_orchard_for_error_calculation;
    global names_of_orchard_areas;
    
    str_orchard_area_sampled = names_of_orchard_areas{area_in_orchard_for_error_calculation};
    
    all_hand_mean_errors = all_hand_mean_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
    all_computer_mean_errors = all_computer_mean_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
    
    string_of_loop_iterations = num2str(loop_iterations);

    cur_percentage = percentages_to_check(percentage_to_use);
    total_sections = size( all_computer_mean_errors, 2 );
    
    num_trees_sampled = floor( cur_percentage * total_sections );
    all_sections = linspace( 1, 100, total_sections );
    
    if Show_Continuous_Blocks_Data == 1
        offset_type_of_error_comp = 0;
        offset_type_of_error_hand = 0;
        string_type_of_count = 'Continuous Blocks';
    else
        offset_type_of_error_comp = 3;
        offset_type_of_error_hand = 2;
        string_type_of_count = 'Discontinuous Blocks';
    end
    
    all_percent_improvement = zeros( 1, total_sections, 3 );
    
    cur_hand_error = all_hand_mean_errors( percentage_to_use, :, offset_type_of_error_hand + 1 );
    
    title_one = [type_of_apple, ': Percentage Improvement : Hand to Computer Aided Counting from ', string_type_of_count];
    
    h = figure('Name', title_one, 'Position', [100 100 960 480]);
    
    hold all;
    
    % We do not want to show the percent improvement of the unscaled
    % counts, which is index number 3
    for j = 2:3
        cur_percent_improvement_plot = ones(1, total_sections, 1);
        computer_mean_errors_one_percentage = all_computer_mean_errors( percentage_to_use, :, j+offset_type_of_error_comp );
        
        %type_of_apple
        %computer_mean_errors_one_percentage
        %cur_hand_error
        
        for num_sections = 1:total_sections
            cur_computer_error = computer_mean_errors_one_percentage(1, num_sections);
            cur_percent_improvement = 100 * ( cur_hand_error - cur_computer_error ) / cur_hand_error;
            cur_percent_improvement_plot(1, num_sections, 1) = cur_percent_improvement;
        end
        
        %cur_percent_improvement_plot
        
        plot( all_sections, cur_percent_improvement_plot );
    end
    
    title(title_one);
    xlabel( 'Percentage of Total Sections Computer Counted', 'fontsize',12,'fontweight','normal');    
    ylabel( 'Improvement from Hand to Computer Counting (Percent)', 'fontsize',12,'fontweight','normal');
    
    cell_array_titles = cell(1, 2);
    
    cur_string_extrapolation = ['Direct Extrapolation: ' num2str(cur_percentage) '% Hand Counted'];
    cur_string_kriging = ['Kriging of Computer Counts: ' num2str(cur_percentage) '% Hand Counted'];
    
    cell_array_titles{1, 1} = cur_string_extrapolation;
    cell_array_titles{1, 2} = cur_string_kriging;

    hleg = legend(cell_array_titles);
    set(hleg, 'String', cell_array_titles);
    
    axis([0 100 -50 100]);
    hold off;
    
    graph_directory_name = 'Percent Improvement : Multiple Error Types';
    appleType_orchardArea_countType_graphType_dir = makeDirectory({'PNGs'; type_of_apple;...
        str_orchard_area_sampled; string_type_of_count; graph_directory_name; 'NotLineFitted'});
    
    filename = [ appleType_orchardArea_countType_graphType_dir,  '/percent_improvement_error_types_comparison_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
end