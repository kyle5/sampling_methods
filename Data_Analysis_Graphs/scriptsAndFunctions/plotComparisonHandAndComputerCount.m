function plotComparisonHandAndComputerCount( all_hand_mean_errors_four_d,...
   all_computer_mean_errors_four_d, percentages_to_check, type_of_apple, type_of_error_to_show_computer, type_of_error_to_show_hand  )

    % Include the computer errors in the plotting of the max_y

    global area_in_orchard_for_error_calculation;
    global names_of_orchard_areas;
    
    str_orchard_area_sampled = names_of_orchard_areas{area_in_orchard_for_error_calculation};
    
    all_hand_mean_errors = all_hand_mean_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
    all_computer_mean_errors = all_computer_mean_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
    
    number_of_percentages = size(percentages_to_check, 2);

    one_type_of_computer_mean_errors = all_computer_mean_errors( :, :, type_of_error_to_show_computer);
    one_type_of_hand_mean_errors = all_hand_mean_errors( :, :, type_of_error_to_show_hand);
    
    if type_of_error_to_show_hand <= 2
        string_type_of_count = 'Continuous Blocks';
    else
        string_type_of_count = 'Discontinuous Blocks';
    end
    
    index_error_calc = mod(type_of_error_to_show_computer-1, 3) + 1;
    
    global names_of_error_calcs
    cur_error_calc = names_of_error_calcs{index_error_calc};
    
    global loop_iterations;
    string_of_loop_iterations = num2str(loop_iterations);
    
    total_sections = size(one_type_of_computer_mean_errors, 2);
    all_sections = linspace(1, 100, total_sections);

    %cur_percentage = number_of_percentages(number_of_percentages);
    
    title_one = [type_of_apple, ' : Hand Count and Computer Count Error'];
    h = figure('Name', title_one, 'position', [100, 100, 800, 600]);
    
    hold all
    
    for i = 1:number_of_percentages
        cur_hand_count_error = one_type_of_hand_mean_errors(i, 1);
        cur_percentage_hand_count_error = cur_hand_count_error * 100;
        cur_hand_count_error_plot = ones(1, total_sections) * cur_percentage_hand_count_error;
        plot( all_sections, cur_hand_count_error_plot );
    end
    
    for i = 1:number_of_percentages
        cur_type_of_computer_errors = one_type_of_computer_mean_errors(i,:);
        cur_type_of_computer_errors_percentages = cur_type_of_computer_errors * 100;
        plot( all_sections,  cur_type_of_computer_errors_percentages);
    end
    
    title_font_size = 16;
    axis_font_size = 16;
    
    inner_title = [type_of_apple, ' : ', 'Comparison of Hand and Computer Count Error: Sections in ', string_type_of_count];
    title(inner_title, 'fontsize', title_font_size, 'fontweight', 'bold');
    xlabel('Percentage of Total Sections Computer Counted', 'fontsize',axis_font_size,'fontweight','normal');
    ylabel('Error (Percent)', 'fontsize',axis_font_size,'fontweight','normal');
    
    
    legend_positions = number_of_percentages*2;
    cell_array_titles = cell(1, legend_positions);
    
    for i = 1:number_of_percentages
        cur_percentage = percentages_to_check(1, i);
        cur_string = ['Hand Count Error Extrapolation : ' num2str(cur_percentage) '% of Sections Hand Counted'];
        cell_array_titles{1, i} = cur_string;
    end
    
    offset = number_of_percentages;
    for i = 1:number_of_percentages
        cur_percentage = percentages_to_check(1, i);
        cur_string = [ cur_error_calc ' : ' num2str(cur_percentage) '% of Sections Hand Counted'];
        cell_array_titles{1, i+offset} = cur_string;
    end

    
    idx_over_ten_percent = find(all_sections > 5);
    first_idx_over_ten = idx_over_ten_percent(1);
    
    max_y = getMaxYForPlotting([one_type_of_computer_mean_errors(:, first_idx_over_ten:end) * 100, one_type_of_hand_mean_errors(:) * 100], 10);
    axis( [0 100 0 max_y ] );
    
    legend(cell_array_titles);
    hold off
    
    graph_directory_name = 'Comparison Hand and Computer : One Error Type';
    
    appleType_orchardArea_countType_graphType_dir = makeDirectory({'PNGs'; type_of_apple; str_orchard_area_sampled;...
        string_type_of_count; graph_directory_name; 'NotLineFitted'});
    
    filename = [appleType_orchardArea_countType_graphType_dir, '/computer_and_hand_count_error_comparison_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
end