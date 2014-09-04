function plotComparisonHandCountsBlockAndDiscontinuous( all_hand_mean_errors,...
   all_computer_mean_errors, percentages_to_check, type_of_apple, type_of_error_to_show_computer, type_of_error_to_show_hand  )

    number_of_percentages = size(percentages_to_check, 2);

    one_type_of_computer_mean_errors = all_computer_mean_errors( :, :, type_of_error_to_show_computer);
    one_type_of_hand_mean_errors = all_hand_mean_errors( :, :, type_of_error_to_show_hand);
    
    if type_of_error_to_show_hand <= 2
        string_type_of_count = 'Continuous Blocks';
    else
        string_type_of_count = 'Discontinuous Blocks';
    end
    
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
    
    title_font_size = 18;
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
        cur_string = ['Computer Error Kriging of Computer Counts and SF Map : ' num2str(cur_percentage) '% of Sections Hand Counted'];
        cell_array_titles{1, i+offset} = cur_string;
    end

    
    axis([0 50 0 10]);
    
    legend(cell_array_titles);
    hold off
    
    apple_type_dir = ['PNGs/', type_of_apple, ' ', string_type_of_count];
    filename = [apple_type_dir, '/computer_and_hand_count_error_comparison_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
end