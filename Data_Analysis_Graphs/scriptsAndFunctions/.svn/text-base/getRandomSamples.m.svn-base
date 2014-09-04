function [ sampleCountPC, sampleCountHand ] = getRandomSamples( ground_counts, pc_counts, num_sections)
    sampleCountPC = 0;
    sampleCountHand = 0;
    
    total_sections = numel(ground_counts);
    rand_possible_sections = randperm(total_sections);
    
    for j = 1:num_sections
        rand_section = rand_possible_sections(j);

        curCountPC = pc_counts(rand_section);
        sampleCountPC = sampleCountPC + curCountPC;

        curCountHand = ground_counts(rand_section);
        sampleCountHand = sampleCountHand + curCountHand;
    end
end