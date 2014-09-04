function plotTypeOfErrorComparisonHandAndComputerCounts( all_hand_mean_errors_four_d,...
   all_computer_mean_errors_four_d, percentages_to_check, type_of_apple, Show_Continuous_Blocks_Data, percentage_to_use )

    % Use makeDirectory()
    % Flexible max_y
    % New directories

    global loop_iterations;
    global area_in_orchard_for_error_calculation;
    global names_of_orchard_areas;
    
    str_orchard_area_sampled = names_of_orchard_areas{area_in_orchard_for_error_calculation};
    
    all_hand_mean_errors = all_hand_mean_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
    all_computer_mean_errors = all_computer_mean_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
    
    string_of_loop_iterations = num2str(loop_iterations);
    percentage = percentages_to_check(1, percentage_to_use);
    string_percentage = num2str(percentage);
    
    all_computer_mean_errors = all_computer_mean_errors * 100;
    all_hand_mean_errors = all_hand_mean_errors * 100;
    
    if Show_Continuous_Blocks_Data == 1
        offset_type_of_error_comp = 0;
        offset_type_of_error_hand = 0;
        string_type_of_count = 'Continuous Blocks';
    else
        offset_type_of_error_comp = 3;
        offset_type_of_error_hand = 2;
        string_type_of_count = 'Discontinuous Blocks';
    end
    
    computer_mean_errors_extrapolation = all_computer_mean_errors(percentage_to_use, :, offset_type_of_error_comp + 2);
    computer_mean_errors_kriging = all_computer_mean_errors(percentage_to_use, :, offset_type_of_error_comp + 3);

    hand_mean_errors_extrapolation = all_hand_mean_errors(percentage_to_use, :, offset_type_of_error_hand + 1);
    hand_mean_errors_kriging = all_hand_mean_errors(percentage_to_use, :, offset_type_of_error_hand + 2);
    
    total_sections = size(computer_mean_errors_extrapolation, 2);
    all_sections = linspace(1, 100, total_sections);

    title_one = [type_of_apple, ' : Error Comparison of Estimated Apples Counted by the Algorithm and by Hand'];
    h = figure('Name', title_one, 'position', [100, 100, 800, 600]);
    
    hold all
    
    plot( all_sections, hand_mean_errors_extrapolation * ones(1, total_sections) );
    plot( all_sections, hand_mean_errors_kriging * ones(1, total_sections) );
    
    plot( all_sections,  computer_mean_errors_extrapolation );
    plot( all_sections,  computer_mean_errors_kriging );
    
    title_font_size = 18;
    axis_font_size = 16;
    
    inner_title = {title_one,['Sections Sampled in ', string_type_of_count, ' : ', str_orchard_area_sampled]};
    title(inner_title, 'fontsize', title_font_size, 'fontweight', 'bold');
    xlabel('Percentage of Total Sections Counted by the Algorithm', 'fontsize',axis_font_size,'fontweight','normal');
    ylabel('Error (Percent)', 'fontsize',axis_font_size,'fontweight','normal');
    
    cell_array_titles = cell(1, 4);

    cur_string = ['Error of Estimated Apples Counted by Hand and through Extrapolation : ' string_percentage '% of Sections Hand Counted'];
    cell_array_titles{1, 1} = cur_string;
    
    cur_string = ['Error of Estimated Apples Counted by Hand and through Kriging : ' string_percentage '% of Sections Hand Counted'];
    cell_array_titles{1, 2} = cur_string;

    cur_string = ['Error of Estimated Apples Counted by the Algorithm and through Extrapolation : ' string_percentage '% of Sections Hand Counted'];
    cell_array_titles{1, 3} = cur_string;

    cur_string = ['Error of Estimated Apples Counted by the Algorithm and through Kriging : ' string_percentage '% of Sections Hand Counted'];
    cell_array_titles{1, 4} = cur_string;
    
    idx_over_ten_percent = find(all_sections > 5);
    first_idx_over_ten = idx_over_ten_percent(1);
    
    max_y = getMaxYForPlotting([computer_mean_errors_extrapolation(:, first_idx_over_ten:end), computer_mean_errors_kriging(:, first_idx_over_ten:end),...
        hand_mean_errors_extrapolation, hand_mean_errors_kriging ], 10);
    
    axis([0 50 0 max_y]);
    
    legend(cell_array_titles);
    hold off
    
    
    graph_directory_name = 'Comparison Computer and Hand : Multiple Error Types';
    
    appleType_orchardArea_countType_graphType_dir = makeDirectory({'PNGs'; type_of_apple;...
        str_orchard_area_sampled; string_type_of_count; graph_directory_name; 'NotLineFitted'});
    
    filename = [appleType_orchardArea_countType_graphType_dir, '/type_of_error_comparison_computer_and_hand_count_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
    
    clf();
    
    hold all;
    plot( all_sections, hand_mean_errors_extrapolation * ones(1, total_sections) );
    plot( all_sections, hand_mean_errors_kriging * ones(1, total_sections) );
    
    [ fh, P ] = findExponentiallyDecreasingFunction(all_sections, computer_mean_errors_extrapolation);
    plot( all_sections,  fh(all_sections,P) );
    
    [ fh, P ] = findExponentiallyDecreasingFunction(all_sections, computer_mean_errors_kriging);
    plot( all_sections,  fh(all_sections,P) );
    
    axis([0 50 0 max_y]);
    legend(cell_array_titles);

    hold off;
    
    appleType_orchardArea_countType_graphType_dir = makeDirectory({'PNGs'; type_of_apple;...
        str_orchard_area_sampled; string_type_of_count; graph_directory_name; 'LineFitted'});
    
    filename = [appleType_orchardArea_countType_graphType_dir, '/type_of_error_comparison_computer_and_hand_count_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
    
end