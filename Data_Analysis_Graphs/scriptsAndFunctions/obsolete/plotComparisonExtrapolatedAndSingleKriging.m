function plotComparisonExtrapolatedAndSingleKriging( all_computer_mean_errors_four_d, type_of_apple, percentages_to_check, Show_Continuous_Blocks_Data, percentage_to_use )

    % Flexible max
    
    global loop_iterations;
    global area_in_orchard_for_error_calculation;
    global names_of_orchard_areas;
    
    str_orchard_area_sampled = names_of_orchard_areas{area_in_orchard_for_error_calculation};
    
    all_computer_mean_errors = all_computer_mean_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
    
    cur_percentage = percentages_to_check(percentage_to_use);
    all_computer_mean_errors_percentage = all_computer_mean_errors * 100;
    
    if Show_Continuous_Blocks_Data == 1
        offset_type_of_error_comp = 0;
        offset_type_of_error_hand = 0;
        string_type_of_count = 'Continuous Blocks';
    else
        offset_type_of_error_comp = 3;
        offset_type_of_error_hand = 2;
        string_type_of_count = 'Discontinuous Blocks';
    end
    
    computer_mean_errors_extrapolation = all_computer_mean_errors_percentage(percentage_to_use, :, offset_type_of_error_comp + 2);
    computer_mean_errors_kriging = all_computer_mean_errors_percentage(percentage_to_use, :, offset_type_of_error_comp + 3);
    
    string_of_loop_iterations = num2str(loop_iterations);
    
    total_sections = size(all_computer_mean_errors, 2);
    
    all_sections = linspace(1, 100, total_sections);
    
    title_one = [type_of_apple, ' : Computer Count Error : Sections Sampled in ', string_type_of_count, ' : ', str_orchard_area_sampled];
    h = figure('Name', title_one, 'position', [100, 100, 600, 500]);
    
    hold all;

    [ fh, P ] = findExponentiallyDecreasingFunction(all_sections, computer_mean_errors_extrapolation);
    plot(all_sections, fh(all_sections,P))

    [ fh, P ] = findExponentiallyDecreasingFunction(all_sections, computer_mean_errors_kriging);
    plot(all_sections, fh(all_sections,P))
    
    
    title_font_size = 16;    
    axis_font_size = 16;
    
    xlabel('Percentage of Total Sections Computer Counted', 'fontsize',axis_font_size,'fontweight','normal');
    ylabel('Error (Percent)', 'fontsize',axis_font_size,'fontweight','normal');
    
    title(title_one, 'fontsize', title_font_size, 'fontweight', 'bold');
    
    legend_positions = 2;
    cell_array_titles = cell( 1, legend_positions );
    
    cur_string_extrapolation = ['Extrapolation of Computer Counts : ' num2str(cur_percentage) '% of Sections Hand Counted'];
    cur_string_kriging = ['Kriging of Computer Counts : ' num2str(cur_percentage) '% of Sections Hand Counted'];
    
    cell_array_titles{1, 1} = cur_string_extrapolation;
    cell_array_titles{1, 2} = cur_string_kriging;
    
    legend( cell_array_titles );
    
    idx_over_ten_percent = find(all_sections > 5);
    first_idx_over_ten = idx_over_ten_percent(1);
    
    max_y = getMaxYForPlotting([computer_mean_errors_extrapolation(:, first_idx_over_ten:end); computer_mean_errors_kriging(:, first_idx_over_ten:end) ], 15);
    
    axis( [0 50 0 max_y] );
    hold off;
    
    % I could put in two different directories here
    
    graph_directory_name = 'Comparison Computer Counts : Extrapolated and Kriging';
    appleType_orchardArea_countType_graphType_dir = makeDirectory({'PNGs'; type_of_apple;...
        str_orchard_area_sampled; string_type_of_count; graph_directory_name; 'LineFitted'});

    filename = [appleType_orchardArea_countType_graphType_dir, '/extrapolated_and_kriging_comp_counts_errors_curve_fitting_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);

    cla(h);
    hold all;
    plot(all_sections, computer_mean_errors_extrapolation)
    plot(all_sections, computer_mean_errors_kriging)
    
    legend( cell_array_titles );
    
    appleType_orchardArea_countType_graphType_dir = makeDirectory({'PNGs'; type_of_apple;...
    str_orchard_area_sampled; string_type_of_count; graph_directory_name; 'NotLineFitted'});

    filename = [appleType_orchardArea_countType_graphType_dir, '/extrapolated_and_kriging_comp_counts_errors_no_curve_fitting_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
end