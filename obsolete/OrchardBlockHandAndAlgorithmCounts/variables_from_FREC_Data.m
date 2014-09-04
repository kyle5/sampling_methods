addpath('/excelFiles/');

red_total_cluster_thinned_rows = 10;
red_total_not_cluster_thinned_rows = 5;
red_total_rows = red_total_cluster_thinned_rows + red_total_not_cluster_thinned_rows;

[numbers_multi,txt_multi,raw_multi] = xlsread('FREC_block08_hand_count.xls', 'sections_multi_counts', 'B5:G28', 'basic');

multi_ground_counts = zeros(3, 18);
single_ground_counts = zeros(3, 18);

% First get the data from the excel sheet for the sections that were
% counted multiple times

for row_idx = 1:8:24
    
    cur_row_count = [];
    
    col_idx_row = 2;
    col_idx_section = 3;
    starting_col_idx_counts = 5;
    
    cur_row = numbers_multi( row_idx, col_idx_row );
    
    
    for section_idx = 0:2:7
        real_section_idx = row_idx + section_idx;
        cur_section = numbers_multi( real_section_idx,  col_idx_section );
        
        numbers_added = 0;
        total_count = 0;
        for i = 0:1
            for j = 0:2
                cur_row_counts = real_section_idx + i;
                cur_col_counts = starting_col_idx_counts + j;
                cur_number = numbers_multi( cur_row_counts, cur_col_counts );
                if ~isnan(cur_number)
                    numbers_added = numbers_added + 1;
                    total_count = total_count + cur_number;
                end
            end
        end
        count_applied = round(total_count/numbers_added);
        multi_ground_counts( cur_row, cur_section) = count_applied;
    end
    
end


[numbers_single,txt_single,raw_single] = xlsread('FREC_block08_hand_count.xls', 'sections_single_count', 'A3:T14', 'basic');

% Go through each of the indexes for the rows
col_idx_row = 1;
row_in_excel_sections_idx = 5;
starting_col_in_excel_sections_idx = 3;


for i = 1:3:9
    cur_row_in_excel_rows = 5 + i;
    
    cur_row = numbers_single( cur_row_in_excel_rows, col_idx_row );
    
    % Go through each of the indexes for the sections
    for j = 0:17
        cur_col_in_excel = starting_col_in_excel_sections_idx + j;
        
        cur_section = numbers_single( row_in_excel_sections_idx, cur_col_in_excel );
        % Go through each of the 3 possible places that the number of
        % counts could be
        for k = 0:2
            cur_row_in_excel_counts = cur_row_in_excel_rows + k;
            single_number = numbers_single( cur_row_in_excel_counts, cur_col_in_excel );
            if ~isnan(single_number)
                single_ground_counts( cur_row, cur_section ) = single_number;
            end
        end
        
    end
end

honeycrisp_ground_counts = single_ground_counts + multi_ground_counts;

save('variablesFREC.mat', 'honeycrisp_ground_counts');