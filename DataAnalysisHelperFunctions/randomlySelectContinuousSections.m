function [ rand_sections_to_count ] = randomlySelectContinuousSections(...
    number_of_sections_to_count, sections_in_each_group, total_sections, rows, valid_counts )
    
    number_of_groups_of_sections = floor(number_of_sections_to_count/sections_in_each_group);
    number_left_over = number_of_sections_to_count - number_of_groups_of_sections * sections_in_each_group;
    
    sections_per_a_row = total_sections/rows;
    groups_per_a_row = floor(sections_per_a_row/sections_in_each_group);
    image_size = [ rows, sections_per_a_row ];
    
    extra_sections = mod(sections_per_a_row, sections_in_each_group);
    
    % This shows the number of spaces that each of the sections can move
    % around in the space that will be aportioned to them

    extra_sections_split_between_sides = floor( extra_sections/groups_per_a_row );

    % The ending section is given the extra space that is still left over
    additional_ending_spaces = mod( extra_sections, groups_per_a_row );
    
    if sections_in_each_group > sections_per_a_row
        error('Sections in each group need to be less than the total sections in the row');
    end
    if sections_in_each_group * number_of_groups_of_sections > total_sections
        error('Lower the sections per a group or the total number of groups of sections (sections/group * total groups > total sections)');
    end
    
    for i = sections_per_a_row:-1:1
        if ~mod(i, sections_in_each_group)
            row_splitting_length = i;
            break;
        end
    end
    
    groups_per_a_row = row_splitting_length/sections_in_each_group;
    total_groups_possible = groups_per_a_row * rows;
    
    if total_groups_possible < number_of_groups_of_sections
        number_of_groups_of_sections = total_groups_possible;
        number_left_over = number_of_sections_to_count - number_of_groups_of_sections * sections_in_each_group;
    end
    
    rand_groups = randperm( groups_per_a_row * rows );
    rand_groups_to_count = rand_groups( 1:number_of_groups_of_sections );

    groups_size = [ rows, groups_per_a_row ];
    
    section_count = 0;
    total_sections_in_groups_to_count = number_of_groups_of_sections * sections_in_each_group;
    total_sections_to_count = total_sections_in_groups_to_count + number_left_over;
    rand_sections_to_count = zeros( 1, total_sections_to_count );
    
    show_map = 0;
    if total_sections_to_count > total_sections - 20
        show_map = 1;
    end
    
    for i = 1:number_of_groups_of_sections
        cur_segment = rand_groups_to_count( i );
        
        [ cur_segment_row, cur_segment_group_in_row ] = ind2sub( groups_size, cur_segment );
        
        % This gets the offset that is due to the previous offsets that
        % were set by the previous sections in the row
        previous_segment_offsets = extra_sections_split_between_sides * ( cur_segment_group_in_row - 1 );
        
        cur_starting_section = (cur_segment_group_in_row-1) * sections_in_each_group + 1;
        cur_starting_section_in_its_space = cur_starting_section + previous_segment_offsets;
        
        cur_ending_section = cur_starting_section + sections_in_each_group - 1;
        cur_ending_section_in_its_space = cur_ending_section + previous_segment_offsets;
        
        offset_possible = extra_sections_split_between_sides;
        if cur_segment_group_in_row == groups_per_a_row
            offset_possible = offset_possible + additional_ending_spaces;
        end
        
        [ cur_starting_section, cur_ending_section ] = computeStartingAndEndingSectionsWithOffset(...
            cur_starting_section_in_its_space, cur_ending_section_in_its_space, offset_possible );
        
        cur_sections = cur_starting_section:cur_ending_section;
        
        for j = 1:sections_in_each_group
            cur_section = cur_sections(j);
            cur_index = sub2ind( image_size, cur_segment_row, cur_section );
            
            section_count = section_count + 1;
            rand_sections_to_count(:, section_count) = cur_index;
        end
    end
    possible_for_left_over = setdiff(1:total_sections, rand_sections_to_count);
    mixed_pos_left_over = possible_for_left_over(randperm(length(possible_for_left_over)));
    rand_sections_to_count(1, total_sections_in_groups_to_count+1:total_sections_in_groups_to_count+number_left_over) = mixed_pos_left_over(1:number_left_over);
    if ~isempty(setdiff(rand_sections_to_count, unique(rand_sections_to_count)))
        error('same values');
    end
    if show_map == 1
        map = zeros(rows, sections_per_a_row);
        map(rand_sections_to_count) = 0.5;
        %map(mixed_pos_left_over) = map(mixed_pos_left_over) + .25; 
        %figure, imagesc(map);
    end
end