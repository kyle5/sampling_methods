function plotComparisonStdDevSingleTypeHandAndCompError( std_dev_computer_errors_four_d, std_dev_hand_errors_four_d, type_of_apple, percentages_to_check, type_of_error_to_show_computer, type_of_error_to_show_hand )


    % Get the correct directory structure
    % Use makeDirectory()
    
    global area_in_orchard_for_error_calculation;
    global names_of_orchard_areas;
    
    str_orchard_area_sampled = names_of_orchard_areas{area_in_orchard_for_error_calculation};
    
    std_dev_hand_errors = std_dev_hand_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
    std_dev_computer_errors = std_dev_computer_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
    
    number_of_percentages = size(percentages_to_check, 2);
    total_sections = size(std_dev_computer_errors, 2);
    
    one_type_std_dev_comp_errors = std_dev_computer_errors( :, :, type_of_error_to_show_computer);
    one_type_std_dev_hand_errors = std_dev_hand_errors( :, :, type_of_error_to_show_hand);
    
    continuous_hand_counts = type_of_error_to_show_hand <= 2;
    continuous_comp_counts = type_of_error_to_show_computer <= 4;
    if continuous_comp_counts ~= continuous_hand_counts
        error('The type of computer and hand counts need to be the same');
    elseif continuous_hand_counts == 1 && continuous_comp_counts == 1 
        string_type_of_count = 'Continuous Blocks';
    else
        string_type_of_count = 'Discontinuous Blocks';
    end
    
    index_error_calc = mod(type_of_error_to_show_computer-1, 4) + 1;
    global names_of_error_calcs
    cur_error_calc = names_of_error_calcs{index_error_calc};
    
    global loop_iterations;
    string_of_loop_iterations = num2str(loop_iterations);
    
    all_sections = linspace(1, 100, total_sections);

    %cur_percentage = number_of_percentages(number_of_percentages);
    
    title_one = [ type_of_apple, ' : ', 'Comparison of Hand and Computer Count Error Standard Deviation : Sections Sampled in ', string_type_of_count, ' : ', str_orchard_area_sampled ];
    h = figure( 'Name', title_one, 'position', [100, 100, 800, 600] );
    
    hold all
    
    for i = 1:number_of_percentages
        cur_comp_count_error = one_type_std_dev_comp_errors(i, :);
        cur_percentage_comp_count_error = cur_comp_count_error * 100;
        cur_comp_count_error_plot = cur_percentage_comp_count_error;
        plot( all_sections, cur_comp_count_error_plot );
    end
    
    for i = 1:number_of_percentages
        cur_hand_count_error = one_type_std_dev_hand_errors(i, 1);
        cur_percentage_hand_count_error = cur_hand_count_error * 100;
        cur_hand_count_error_plot = ones(1, total_sections) * cur_percentage_hand_count_error;
        plot( all_sections, cur_hand_count_error_plot );
    end

    title_font_size = 18;
    axis_font_size = 16;
    
    title(title_one, 'fontsize', title_font_size, 'fontweight', 'bold');
    xlabel('Percentage of Total Sections Computer Counted', 'fontsize',axis_font_size,'fontweight','normal');
    ylabel('Standard Deviation of Percentage Error', 'fontsize',axis_font_size,'fontweight','normal');
    
    
    legend_positions = number_of_percentages*2;
    cell_array_titles = cell(1, legend_positions);
    
    for i = 1:number_of_percentages
        cur_percentage = percentages_to_check(1, i);
        cur_string = ['Computer Count Error Standard Deviation : ' num2str(cur_percentage) '% of Sections Hand Counted'];
        cell_array_titles{1, i} = cur_string;
    end
    
    offset = number_of_percentages;
    for i = 1:number_of_percentages
        cur_percentage = percentages_to_check(1, i);
        cur_string = ['Hand Count Error Standard Deviation : ' num2str(cur_percentage) '% of Sections Hand Counted'];
        cell_array_titles{1, offset + i} = cur_string;
    end
    
    axis([0 50 0 10]);
    legend(cell_array_titles);
    hold off
    
    graph_directory_name = 'Std Deviation Hand and Computer : One Error Type';
    appleType_orchardArea_countType_graphType_dir = makeDirectory({'PNGs'; type_of_apple;...
        str_orchard_area_sampled; string_type_of_count; graph_directory_name; 'NotLineFitted'});
    
    filename = [appleType_orchardArea_countType_graphType_dir, '/hand_comp_error_std_dev_comparison_one_type_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
    
    
    clf();
    
    hold all
        
    for i = 1:number_of_percentages
        cur_comp_count_error = one_type_std_dev_comp_errors(i, :);
        cur_percentage_comp_count_error = cur_comp_count_error * 100;
        
        [ fh, P ] = findExponentiallyDecreasingFunction(all_sections, cur_percentage_comp_count_error);
        plot(all_sections, fh(all_sections,P));
    end
    
    for i = 1:number_of_percentages
        cur_hand_count_error = one_type_std_dev_hand_errors(i, 1);
        cur_percentage_hand_count_error = cur_hand_count_error * 100;
        cur_hand_count_error_plot = ones(1, total_sections) * cur_percentage_hand_count_error;
        plot( all_sections, cur_hand_count_error_plot );
    end
    
    axis([0 50 0 10]);
    legend(cell_array_titles);
    
    hold off;
    
    appleType_orchardArea_countType_graphType_dir = makeDirectory({'PNGs'; type_of_apple;...
        str_orchard_area_sampled; string_type_of_count; graph_directory_name; 'LineFitted'});
    
    filename = [appleType_orchardArea_countType_graphType_dir, '/hand_comp_error_std_dev_comparison_one_type_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
end