function plotComparisonOfHandCountError( all_hand_mean_errors_four_d, type_of_apple, percentages_to_check,...
    total_sections, Show_Continuous_Blocks_Data, percentage_to_use )

    % Turn into bar graphs to be displayed
    % Add in the new directories

    global loop_iterations;
    global area_in_orchard_for_error_calculation;
    global names_of_orchard_areas;
    
    str_orchard_area_sampled = names_of_orchard_areas{area_in_orchard_for_error_calculation};
    
    all_hand_mean_errors = all_hand_mean_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
    
    if Show_Continuous_Blocks_Data == 1
        offset_type_of_error_hand = 0;
        string_type_of_count = 'Continuous Blocks';
    else
        offset_type_of_error_hand = 2;
        string_type_of_count = 'Discontinuous Blocks';
    end
    
    cur_hand_count_error_direct_extrapolation = all_hand_mean_errors(percentage_to_use, 1, offset_type_of_error_hand + 1 );
    cur_hand_count_error_kriging = all_hand_mean_errors(percentage_to_use, 1, offset_type_of_error_hand + 2 );
    cur_percentage = percentages_to_check(percentage_to_use);
    
    string_of_loop_iterations = num2str( loop_iterations );
    
    all_sections = linspace(1, 100, total_sections);

    % There has got to be a for loop here, for each level of hand counts
    % that are possible
    title_one = [ type_of_apple, ' : ', 'Hand Count Error Comparison : Sections Sampled in ', string_type_of_count, ' : ', str_orchard_area_sampled ];
    
    h = figure('Name', 'yes', 'position', [100, 100, 600, 500]);
    
    title_two = { title_one, [num2str(cur_percentage) '% of Sections Hand Counted']};
    hold all;
    
    cur_percentage_hand_count_error_direct_extrapolation = cur_hand_count_error_direct_extrapolation * 100;
    cur_percentage_hand_count_error_kriging = cur_hand_count_error_kriging * 100;
    
    cur_hand_count_error_plot_direct_extrapolation = ones( 1, total_sections ) .* cur_percentage_hand_count_error_direct_extrapolation;
    cur_hand_count_error_plot_kriging = ones(1, total_sections) * cur_percentage_hand_count_error_kriging;

    
    bar( 1:2, [cur_percentage_hand_count_error_direct_extrapolation, cur_percentage_hand_count_error_kriging], 'stacked');
    
    %plot( all_sections, cur_hand_count_error_plot_direct_extrapolation );
    %plot( all_sections, cur_hand_count_error_plot_kriging );

    title_font_size = 18;
    axis_font_size = 16;
    
    ylabel('Error (Percent)', 'fontsize',axis_font_size,'fontweight','normal');
    
    title(title_two, 'fontsize', title_font_size, 'fontweight', 'bold');
    
    set(gca,'XTick', 1:2)
    set(gca,'XTickLabel', {'Direct Extrapolation', 'Kriging'} )
    
    idx_over_ten_percent = find(all_sections > 5);
    first_idx_over_ten = idx_over_ten_percent(1);
    
    max_y = getMaxYForPlotting([cur_percentage_hand_count_error_direct_extrapolation(first_idx_over_ten:end, 1); cur_percentage_hand_count_error_kriging(:, 1)], 10);
    axis([0 3 0 max_y ]);
    hold off;
    
    graph_directory_name = 'Hand Count Errors : Multiple Types';
    appleType_orchardArea_countType_graphType_dir = makeDirectory({'PNGs'; type_of_apple;...
        str_orchard_area_sampled; string_type_of_count; graph_directory_name; 'NotLineFitted'});
    
    filename = [ appleType_orchardArea_countType_graphType_dir,  '/hand_count_error_comparison_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
end

