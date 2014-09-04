function [ total_count ] = addSpecifiedMatrixValues( image_used, sampled_sections )
    total_count = 0;
    for i = 1:numel(sampled_sections)
        idx_cur_section = sampled_sections(i);
        cur_section_count = image_used(idx_cur_section);
        total_count = total_count + cur_section_count;
    end
end

