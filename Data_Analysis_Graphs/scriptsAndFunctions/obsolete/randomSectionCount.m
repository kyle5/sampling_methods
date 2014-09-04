function [ sample_count ] = randomSectionCount( counts, num_sections_to_count )
    
    total_sections = numel(counts);
    rand_possible_sections = randperm(total_sections);

    sample_count = 0;
    for j = 1:num_sections_to_count
        rand_section = rand_possible_sections(j);
        cur_count = counts(rand_section);
        sample_count = sample_count + cur_count;
    end
end
