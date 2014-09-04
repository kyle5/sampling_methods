function [ output_args ] = showFiguresOfCountsUnsmoothed( figures_to_show )
    for i = 1: size(figures_to_show, 3)
        cur_figure_to_show = figures_to_show(:,:,i);
        figure, imagesc(cur_figure_to_show);
        colormap jet;
    end
    output_args = 0;
end

