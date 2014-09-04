function plotComputerCountComparisonBlockAndDiscontinuous( all_computer_mean_errors_four_d, total_sections,...
    percentages_to_check, type_of_apple, type_of_error_cont, type_of_error_discont )

    % Use makeDirectory()
    % Flexible max_y
    % New directories

    global area_in_orchard_for_error_calculation;
    global names_of_orchard_areas;
    
    str_orchard_area_sampled = names_of_orchard_areas{area_in_orchard_for_error_calculation};
    
    all_computer_mean_errors = all_computer_mean_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
    
    number_of_percentages = size(percentages_to_check, 2);
    
    block_computer_mean_errors = all_computer_mean_errors( :, :, type_of_error_cont);
    discontinuous_computer_mean_errors = all_computer_mean_errors( :, :, type_of_error_discont);
    
    index_error_calc = mod(type_of_error_discont-1, 4) + 1;
    global names_of_error_calcs
    cur_error_calc = names_of_error_calcs{index_error_calc};
    
    global loop_iterations;
    string_of_loop_iterations = num2str(loop_iterations);
    
    all_sections = linspace(1, 100, total_sections);

    %cur_percentage = number_of_percentages(number_of_percentages);
    
    title_one = [type_of_apple, ' : Computer Count Error by Type of Random Section Selection'];
    h = figure('Name', title_one, 'position', [100, 100, 800, 600]);
    
    hold all
    
    for i = 1:number_of_percentages
        cur_comp_count_errors = block_computer_mean_errors(i, :);
        cur_percentage_comp_count_error = cur_comp_count_errors * 100;
        plot( all_sections, cur_percentage_comp_count_error );
    end
    
    for i = 1:number_of_percentages
        cur_comp_count_errors = discontinuous_computer_mean_errors(i,:);
        cur_percentage_comp_count_error = cur_comp_count_errors * 100;
        plot( all_sections,  cur_percentage_comp_count_error);
    end
    
    title_font_size = 18;
    axis_font_size = 16;
    
    inner_title = [type_of_apple, ' : ', 'Comparison of Continuous and Discontinuous Computer Count Error'];
    title(inner_title, 'fontsize', title_font_size, 'fontweight', 'bold');
    xlabel('Percentage of Total Sections Computer Counted', 'fontsize',axis_font_size,'fontweight','normal');
    ylabel('Error (Percent)', 'fontsize',axis_font_size,'fontweight','normal');
    
    
    legend_positions = number_of_percentages*2;
    cell_array_titles = cell(1, legend_positions);
    
    for i = 1:number_of_percentages
        cur_percentage = percentages_to_check(1, i);
        cur_string = ['Computer Error Continuous : ' num2str(cur_percentage) '% of Sections Hand Counted'];
        cell_array_titles{1, i} = cur_string;
    end
    
    offset = number_of_percentages;
    for i = 1:number_of_percentages
        cur_percentage = percentages_to_check(1, i);
        cur_string = ['Computer Error Discontinuous : ' num2str(cur_percentage) '% of Sections Hand Counted'];
        cell_array_titles{1, i+offset} = cur_string;
    end

    max_y = getMaxYForPlotting( [ block_computer_mean_errors(:)*100, discontinuous_computer_mean_errors(:)*100 ], 15);
    
    axis([ 0 50 0 max_y ]);
    legend(cell_array_titles);
    
    hold off
    
    graph_directory_name = 'Comparison Continuous And Discontinuous Computer';
    
    appleType_orchardArea_countType_graphType_dir = makeDirectory({'PNGs'; type_of_apple;...
        str_orchard_area_sampled; 'Continuous And Discontinuous Comparison'; graph_directory_name; 'NotLineFitted'});
    
    filename = [appleType_orchardArea_countType_graphType_dir, '/cont_and_discont_comparison_comp_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
    
    clf();
    hold all;
    for i = 1:number_of_percentages
        cur_comp_count_errors = block_computer_mean_errors(i, :);
        cur_percentage_comp_count_error = cur_comp_count_errors * 100;
        [ fh, P ] = findExponentiallyDecreasingFunction(all_sections, cur_percentage_comp_count_error);
        plot(all_sections, fh(all_sections,P));
    end
    
    for i = 1:number_of_percentages
        cur_comp_count_errors = discontinuous_computer_mean_errors(i,:);
        cur_percentage_comp_count_error = cur_comp_count_errors * 100;
        [ fh, P ] = findExponentiallyDecreasingFunction(all_sections, cur_percentage_comp_count_error);
        plot(all_sections, fh(all_sections,P));
    end
    
    axis([ 0 50 0 max_y ]);
    legend(cell_array_titles);
    hold off;
    
    appleType_orchardArea_countType_graphType_dir = makeDirectory({'PNGs'; type_of_apple;...
        str_orchard_area_sampled; 'Continuous And Discontinuous Comparison'; graph_directory_name; 'LineFitted'});
    
    filename = [appleType_orchardArea_countType_graphType_dir, '/cont_and_discont_comparison_comp_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
    hold off;
end