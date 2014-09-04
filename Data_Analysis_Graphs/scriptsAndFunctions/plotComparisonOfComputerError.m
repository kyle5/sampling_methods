function plotComparisonOfComputerError( all_computer_mean_errors, type_of_apple, percentages_to_check )

    global loop_iterations;
    
    num_percentages = numel(percentages_to_check);
    
    cur_percentage = percentages_to_check(1, num_percentages);
    cur_mean_error_computer_count_direct_extrapolation = all_computer_mean_errors(num_percentages, :, 3);
    cur_mean_error_computer_count_kriging = all_computer_mean_errors(num_percentages, :, 2);
    string_of_loop_iterations = num2str(loop_iterations);
    
    total_sections = size(all_computer_mean_errors, 2);
    
    all_sections = linspace(1, 100, total_sections);
    
    figure_title = [type_of_apple, ' : Computer Count Error'];
    h = figure('Name', figure_title, 'position', [100, 100, 600, 500]);
    
    hold all;
    
    cur_percentage_mean_error_computer_count_direct_extrapolation = cur_mean_error_computer_count_direct_extrapolation * 100;
    cur_percentage_mean_error_computer_count_kriging = cur_mean_error_computer_count_kriging * 100;

    plot(all_sections, cur_percentage_mean_error_computer_count_direct_extrapolation);
    
    %poly = polyfit( all_sections, cur_percentage_mean_error_computer_count_direct_extrapolation, -1 );
    %function_values = polyval( poly, all_sections );
    %plot( all_sections, function_values );
    %mdl = @(a,x)(a(1) + a(2)*exp(-a(3)*x));
    %a0 = [0;1;1];
    %[ahat,r,J,cov,mse] = nlinfit(10:total_sections, cur_percentage_mean_error_computer_count_direct_extrapolation(10:total_sections), mdl, a0);
    %plot(all_sections,mdl(ahat,1:total_sections),'r')
    
    plot(all_sections, cur_percentage_mean_error_computer_count_kriging);

    title_font_size = 16;    
    axis_font_size = 16;
    
    xlabel('Percentage of Total Sections Computer Counted', 'fontsize',axis_font_size,'fontweight','normal');
    ylabel('Error (Percent)', 'fontsize',axis_font_size,'fontweight','normal');
    inner_title = [type_of_apple, ' : Computer Count Error'];
    title(inner_title, 'fontsize', title_font_size, 'fontweight', 'bold');
    
    legend_positions = 2;
    cell_array_titles = cell( 1, legend_positions );
    
    cur_string_extrapolation = ['Computer Error Extrapolation : ' num2str(cur_percentage) '% of Sections Hand Counted'];
    cur_string_kriging = ['Computer Error Kriging : ' num2str(cur_percentage) '% of Sections Hand Counted'];

    cell_array_titles{1, 1} = cur_string_extrapolation;
    cell_array_titles{1, 2} = cur_string_kriging;
    
    legend( cell_array_titles );
    
    axis( [0 50 0 30] );
    
    hold off;
    
    filename = ['PNGs/', type_of_apple, '/computer_error_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);

end