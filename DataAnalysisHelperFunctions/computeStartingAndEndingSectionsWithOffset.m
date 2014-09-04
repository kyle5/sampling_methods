function [ cur_starting_section, cur_ending_section ] = computeStartingAndEndingSectionsWithOffset( cur_starting_section, cur_ending_section, offset_possible )
    offset = round( rand(1) * offset_possible );
    cur_starting_section =  cur_starting_section + offset;
    cur_ending_section = cur_ending_section + offset;
end