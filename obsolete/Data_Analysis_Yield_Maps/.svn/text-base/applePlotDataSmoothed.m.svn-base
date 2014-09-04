load redAppleVariables.mat

image_pc = red_thinned_pc_counts;

subplot(2, 2, 1)
imagesc(image_pc);

resized_image_pc = imresize(image_pc, 100);

smoothed_image_pc = gaussianFilter(resized_image_pc);

subplot(2, 2, 2)
imagesc(smoothed_image_pc);


original_image_hand = red_thinned_ground_counts;

subplot(2, 2, 3)
imagesc(original_image_hand);

resized_image_hand = imresize(original_image_hand, 100);

smoothed_image_hand = gaussianFilter(resized_image_hand);

subplot(2, 2, 4)
imagesc(smoothed_image_hand);