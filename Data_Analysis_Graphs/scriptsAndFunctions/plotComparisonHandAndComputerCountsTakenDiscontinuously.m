function plotComparisonHandAndComputerCountsTakenDiscontinuously( all_hand_mean_errors,...
   all_computer_mean_errors, percentages_to_check, type_of_apple )
    
    percentage_to_use = 1;
    
    percentage = percentages_to_check(1, percentage_to_use);
    string_percentage = num2str(percentage);

    all_computer_mean_errors = all_computer_mean_errors * 100;
    all_hand_mean_errors = all_hand_mean_errors * 100;
    
    Show_Continuous_Blocks_Data = 0;
    
    if Show_Continuous_Blocks_Data == 1
        offset_type_of_error_comp = 0;
        offset_type_of_error_hand = 0;
        string_type_of_count = 'Continuous Blocks';
    else
        offset_type_of_error_comp = 3;
        offset_type_of_error_hand = 2;
        string_type_of_count = 'Discontinuous Blocks';
    end
    
    computer_mean_errors_extrapolation = all_computer_mean_errors(percentage_to_use, :, offset_type_of_error_comp + 3);
    computer_mean_errors_kriging = all_computer_mean_errors(percentage_to_use, :, offset_type_of_error_comp + 2);
    computer_mean_errors_kriging_sf = all_computer_mean_errors(percentage_to_use, :, offset_type_of_error_comp + 1);

    hand_mean_errors_extrapolation = all_hand_mean_errors(percentage_to_use, :, offset_type_of_error_hand + 1);
    hand_mean_errors_kriging = all_hand_mean_errors(percentage_to_use, :, offset_type_of_error_hand + 2);

    global loop_iterations;
    string_of_loop_iterations = num2str(loop_iterations);
    
    total_sections = size(computer_mean_errors_extrapolation, 2);
    all_sections = linspace(1, 100, total_sections);

    title_one = [type_of_apple, ' : Hand Count and Computer Count Error'];
    h = figure('Name', title_one, 'position', [100, 100, 800, 600]);
    
    hold all
    
    plot( all_sections, hand_mean_errors_extrapolation * ones(1, total_sections) );
    plot( all_sections, hand_mean_errors_kriging * ones(1, total_sections) );
    
    plot( all_sections,  computer_mean_errors_extrapolation );
    plot( all_sections,  computer_mean_errors_kriging );
    plot( all_sections, computer_mean_errors_kriging_sf );
    
    title_font_size = 18;
    axis_font_size = 16;
    
    inner_title = [type_of_apple, ' : ', 'Comparison of Hand and Computer Count Error : ', string_type_of_count];
    title(inner_title, 'fontsize', title_font_size, 'fontweight', 'bold');
    xlabel('Percentage of Total Sections Computer Counted', 'fontsize',axis_font_size,'fontweight','normal');
    ylabel('Error (Percent)', 'fontsize',axis_font_size,'fontweight','normal');
    
    
    cell_array_titles = cell(1, 5);

    cur_string = ['Hand Count Error Extrapolation : ' string_percentage '% of Sections Hand Counted'];
    cell_array_titles{1, 1} = cur_string;
    
    cur_string = ['Hand Count Error Kriging : ' string_percentage '% of Sections Hand Counted'];
    cell_array_titles{1, 2} = cur_string;

    cur_string = ['Extrapolation on Computer Counts : ' string_percentage '% of Sections Hand Counted'];
    cell_array_titles{1, 3} = cur_string;

    cur_string = ['Kriging on Computer Counts : ' string_percentage '% of Sections Hand Counted'];
    cell_array_titles{1, 4} = cur_string;
    
    cur_string = ['Kriging on PC Counts and SF Map : ' string_percentage '% of Sections Hand Counted'];
    cell_array_titles{1, 5} = cur_string;
    
    axis([0 50 0 10]);
    
    legend(cell_array_titles);
    hold off
    
    apple_type_dir = ['PNGs/', type_of_apple, ' ', string_type_of_count];
    mkdir(apple_type_dir);
    filename = [apple_type_dir, '/computer_and_hand_count_error_comparison_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
end