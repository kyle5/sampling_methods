function [ all_hand_mean_errors ] = getMeanErrorsHandCountSmoothed( ground_counts, actually_counted, parameters )
    %
    loop_iterations = parameters.loop_iterations_input;
    total_sections = numel(ground_counts);
    all_hand_mean_errors = zeros(1, total_sections, 1, 3);
    for num_sections = 1:total_sections
      fprintf( 'Percent complete: %.2f\n', double(num_sections)/total_sections );
        all_hand_count_errors_overall = zeros(loop_iterations, 1);
        all_hand_count_errors_rows = zeros(loop_iterations, 1);
        all_hand_count_errors_sections = zeros(loop_iterations, 1);
        
        for i = 1:loop_iterations
            
            cur_ground_counted_matrix = zeros(size(ground_counts));
            
            totalCount = 0;
            rand_possible_sections = randperm(total_sections);
            rand_possible_sections_to_use = rand_possible_sections(1:num_sections);
            for j = 1:num_sections
                rand_section = rand_possible_sections(j);
                
                curCount = ground_counts(rand_section);
                totalCount = totalCount + curCount;
                
                cur_ground_counted_matrix(rand_section) = curCount;
            end
            
            averageCount = totalCount/num_sections;
            
            otherSections = zeros(size(ground_counts));
            otherSections(rand_possible_sections_to_use) = 1;
            cur_ground_counted_matrix(~otherSections) = averageCount;
            
            error_by_section = computeAverageErrorBetweenMatrices( cur_ground_counted_matrix, ground_counts, 0, 1 );
            
            comp_counts_by_row = sum( cur_ground_counted_matrix, 1 );
            ground_counts_by_row = sum( ground_counts, 1 );
            
            error_by_row = computeAverageErrorBetweenMatrices( ground_counts_by_row, comp_counts_by_row, 0, 1 );
            
            total_ground_counted = sum(cur_ground_counted_matrix(:));
            error_overall = abs(total_ground_counted - actually_counted)/abs(actually_counted);
            
            all_hand_count_errors_overall(i, 1) = error_overall;
            all_hand_count_errors_rows(i, 1) = error_by_row;
            all_hand_count_errors_sections(i, 1) = error_by_section;
        end
        
        mean_error_overall = mean( all_hand_count_errors_overall );
        mean_error_rows = mean( all_hand_count_errors_rows );
        mean_error_sections = mean( all_hand_count_errors_sections );
        
        all_hand_mean_errors(1, num_sections, 1, 3) = mean_error_overall;
        all_hand_mean_errors(1, num_sections, 1, 2) = mean_error_rows;
        all_hand_mean_errors(1, num_sections, 1, 1) = mean_error_sections;
    end
end