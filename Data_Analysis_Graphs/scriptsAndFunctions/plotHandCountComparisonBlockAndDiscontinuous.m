function plotHandCountComparisonBlockAndDiscontinuous( all_hand_mean_errors_four_d,...
   total_sections, percentages_to_check, type_of_apple, type_of_error_cont, type_of_error_discont  )

    
    global loop_iterations;
    global area_in_orchard_for_error_calculation;
    global names_of_orchard_areas;
    
    all_hand_mean_errors = all_hand_mean_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
    str_orchard_area_sampled = names_of_orchard_areas{area_in_orchard_for_error_calculation};
    
    number_of_percentages = size(percentages_to_check, 2);

    block_hand_mean_errors = all_hand_mean_errors( :, :, type_of_error_cont);
    discontinuous_hand_mean_errors = all_hand_mean_errors( :, :, type_of_error_discont);
    
    string_of_loop_iterations = num2str(loop_iterations);
    
    all_sections = linspace(1, 100, total_sections);

    %cur_percentage = number_of_percentages(number_of_percentages);
    
    title_one = [type_of_apple, ' : ', 'Comparison of Continuous and Discontinuous Hand Count Error'];
    h = figure('Name', title_one, 'position', [100, 100, 800, 600]);
    
    hold all
    
    bars_to_plot = [block_hand_mean_errors, discontinuous_hand_mean_errors] * 100;
    
    bar( 1:number_of_percentages, bars_to_plot );
    
    %{
    for i = 1:number_of_percentages
        cur_hand_count_error = block_hand_mean_errors(i, 1);
        cur_percentage_hand_count_error = cur_hand_count_error * 100;
        cur_hand_count_error_plot = ones(1, total_sections) * cur_percentage_hand_count_error;
        plot( all_sections, cur_hand_count_error_plot );
    end
    
    for i = 1:number_of_percentages
        cur_hand_count_error = discontinuous_hand_mean_errors(i, 1);
        cur_percentage_hand_count_error = cur_hand_count_error * 100;
        cur_hand_count_error_plot = ones(1, total_sections) * cur_percentage_hand_count_error;
        plot( all_sections, cur_hand_count_error_plot );
    end
    %}
    
    title_font_size = 18;
    axis_font_size = 16;
    
    
    title(title_one, 'fontsize', title_font_size, 'fontweight', 'bold');
    xlabel('Percentage of Total Sections Computer Counted', 'fontsize',axis_font_size,'fontweight','normal');
    ylabel('Error (Percent)', 'fontsize',axis_font_size,'fontweight','normal');
    
    
    legend_positions = 2;
    cell_array_titles = cell(1, legend_positions);
    
    cur_string = 'Hand Count Error : Continuous';
    cell_array_titles{1, 1} = cur_string;
    cur_string = 'Hand Count Error : Discontinuous';
    cell_array_titles{1, 2} = cur_string;
    
    %{
    for i = 1:number_of_percentages
        cur_percentage = percentages_to_check(1, i);
        cur_string = ['Hand Count Error : Continuous : ' num2str(cur_percentage) '% of Sections Hand Counted'];
        cell_array_titles{1, i} = cur_string;
    end
    
    offset = number_of_percentages;
    for i = 1:number_of_percentages
        cur_percentage = percentages_to_check(1, i);
        cur_string = ['Hand Count Error : Discontinuous : ' num2str(cur_percentage) '% of Sections Hand Counted'];
        cell_array_titles{1, i+offset} = cur_string;
    end
    %}
    
    max_y = getMaxYForPlotting( [ block_hand_mean_errors(:)*100, discontinuous_hand_mean_errors(:)*100 ], 15);
    
    axis([0 number_of_percentages+1 0 max_y ]);
    
    legend(cell_array_titles);
    
    set(gca,'XTick', 1:numel(percentages_to_check))
    set(gca,'XTickLabel', percentages_to_check )
    
    hold off
    
    graph_directory_name = 'Comparison Continuous And Discontinuous Hand';
    appleType_orchardArea_countType_graphType_dir = makeDirectory({'PNGs'; type_of_apple;...
        str_orchard_area_sampled; 'Continuous And Discontinuous Comparison'; graph_directory_name; 'NotLineFitted'});
    
    filename = [appleType_orchardArea_countType_graphType_dir, '/cont_and_discont_comparison_hand_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
end