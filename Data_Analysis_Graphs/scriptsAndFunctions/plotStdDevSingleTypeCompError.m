function plotStdDevSingleTypeCompError( std_dev_computer_errors_four_d, type_of_apple, percentages_to_check, type_of_error_to_show_computer )

    % Get the correct directory structure
    % Use makeDirectory()
    
    global area_in_orchard_for_error_calculation;
    global names_of_orchard_areas;
    
    str_orchard_area_sampled = names_of_orchard_areas(area_in_orchard_for_error_calculation);
    
    std_dev_computer_errors = std_dev_computer_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
    
    number_of_percentages = size(percentages_to_check, 2);

    one_type_std_dev_comp_errors = std_dev_computer_errors( :, :, type_of_error_to_show_computer);
    
    total_sections = size(one_type_std_dev_comp_errors, 2);

    index_error_calc = mod(type_of_error_to_show_computer-1, 4) + 1;
    global names_of_error_calcs
    cur_error_calc = names_of_error_calcs{index_error_calc};
    
    if type_of_error_to_show_computer <= 4
        string_type_of_count = 'Continuous Blocks';
    else
        string_type_of_count = 'Discontinuous Blocks';
    end
    
    global loop_iterations;
    string_of_loop_iterations = num2str(loop_iterations);
    
    all_sections = linspace(1, 100, total_sections);

    %cur_percentage = number_of_percentages(number_of_percentages);
    
    title_one = [type_of_apple, ' : Hand Count Error Standard Deviation'];
    h = figure( 'Name', title_one, 'position', [100, 100, 800, 600] );
    
    hold all
    
    for i = 1:number_of_percentages
        cur_comp_count_error = one_type_std_dev_comp_errors(i, :);
        cur_percentage_comp_count_error = cur_comp_count_error * 100;
        cur_comp_count_error_plot = cur_percentage_comp_count_error;
        
        plot( all_sections, cur_comp_count_error_plot );
    end

    title_font_size = 18;
    axis_font_size = 16;

    inner_title = [type_of_apple, ' : ', 'Comparison of Comp Count Error Standard Deviation : Sections in ', string_type_of_count];
    title(inner_title, 'fontsize', title_font_size, 'fontweight', 'bold');
    xlabel('Percentage of Total Sections Computer Counted', 'fontsize',axis_font_size,'fontweight','normal');
    ylabel('Standard Deviation of Percentage Error', 'fontsize',axis_font_size,'fontweight','normal');
    
    
    legend_positions = number_of_percentages;
    cell_array_titles = cell(1, legend_positions);
    
    for i = 1:number_of_percentages
        cur_percentage = percentages_to_check(1, i);
        cur_string = ['Comp Count Error Standard Deviation : ' num2str(cur_percentage) '% of Sections Hand Counted'];
        cell_array_titles{1, i} = cur_string;
    end
    
    axis([0 50 0 10]);
    legend(cell_array_titles);
    hold off
    
    
    graph_directory_name = 'Std Deviation Computer : One Error Type';
    appleType_orchardArea_countType_graphType_dir = makeDirectory({'PNGs'; type_of_apple;...
        str_orchard_area_sampled; string_type_of_count; graph_directory_name; 'NotLineFitted'});
    
    filename = [appleType_orchardArea_countType_graphType_dir, '/comp_count_error_std_dev_one_type_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
    
    
    hold all
    for i = 1:number_of_percentages
        cur_comp_count_error = one_type_std_dev_comp_errors(i, :);
        cur_percentage_comp_count_error = cur_comp_count_error * 100;
        
        [ fh, P ] = findExponentiallyDecreasingFunction(all_sections, cur_percentage_comp_count_error);
        plot(all_sections, fh(all_sections,P));
    end
    
    axis([0 50 0 10]);
    legend(cell_array_titles);
    
    hold off;
    
    appleType_orchardArea_countType_graphType_dir = makeDirectory({'PNGs'; type_of_apple;...
        str_orchard_area_sampled; string_type_of_count; graph_directory_name; 'LineFitted'});
    
    filename = [appleType_orchardArea_countType_graphType_dir, '/comp_count_error_std_dev_one_type_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
end