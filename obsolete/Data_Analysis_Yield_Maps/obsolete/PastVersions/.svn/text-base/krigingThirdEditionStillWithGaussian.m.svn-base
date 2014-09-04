     load redAppleVariables.mat
     load greenAppleVariables.mat

     red_pc_counts = [red_not_thinned_pc_counts; red_thinned_pc_counts];
     
     size(green_pc_counts(:,1:15))
     size(red_pc_counts)
     size(red_not_thinned_pc_counts)
     size(red_thinned_pc_counts)
     
     
     %apple_types_pc_counts = cell(1, 3);
     
     green_pc_counts(:,1:15);
     
     types_of_apples = 3;
     
     apple_types_ground_counts = cell(1, types_of_apples);
     apple_types_ground_counts{1, 1} = green_ground_counts;
     apple_types_ground_counts{1, 2} = red_not_thinned_ground_counts;
     apple_types_ground_counts{1, 3} = red_thinned_ground_counts;
     
     apple_types_pc_counts = cell(1, types_of_apples);
     apple_types_pc_counts{1, 1} = green_pc_counts;
     apple_types_pc_counts{1, 2} = red_not_thinned_pc_counts;
     apple_types_pc_counts{1, 3} = red_thinned_pc_counts;
     
     %Cell Arrays...

     for i = 1:types_of_apples
         cur_type_hand_counted = apple_types_ground_counts{1, i};
         cur_type_pc_counted = apple_types_pc_counts{1, i};
         
         size_pc_counted = [size(cur_type_pc_counted, 1) size(cur_type_pc_counted, 2)];
         size_hand_counted = [size(cur_type_hand_counted, 1) size(cur_type_hand_counted, 2)];

         min_dim_size_pc = min(size_pc_counted);
         min_dim_size_hand = min(size_hand_counted);
         
         counted_map_pc = cur_type_pc_counted( 1:min_dim_size_pc, 1:min_dim_size_pc);
         counted_map_hand = cur_type_hand_counted(1:min_dim_size_hand, 1:min_dim_size_hand);
         
         scaling_factor = 20;

         width_height_of_created_image = min_dim_size_pc * scaling_factor;

         [X,Y] = meshgrid(1:width_height_of_created_image);
         figure, imagesc(counted_map_pc);

         resized_image_pc = kron(counted_map_pc, [scaling_factor*10, scaling_factor*10]);
         resized_image_hand = kron(counted_map_hand, [scaling_factor*10, scaling_factor*10]);
         
         filtered_pc_counts = imfilter(resized_image_pc, fspecial('gaussian', [4 4], 8));
         figure, imagesc(filtered_pc_counts)


         %{
         fprintf('The size of X is : %d by %d \n', size(X, 1), size(X, 2));
         fprintf('The size of Y is : %d by %d \n', size(Y, 1), size(Y, 2));
         fprintf('The size of Z is : %d by %d \n', size(Z, 1), size(Z, 2));

         fprintf('The size of x is : %d by %d \n', size(x, 1),  size(x, 2));
         fprintf('The size of y is : %d by %d \n', size(y, 1), size(y, 2));
         fprintf('The size of z is : %d by %d \n', size(z, 1), size(z, 2));
         %}


         newx = ones(numel(resized_image_pc), 1);
         newy = ones(numel(resized_image_pc), 1);
         newz = ones(numel(resized_image_pc), 1);

         rows_pc_image = size(counted_map_pc, 1);
         columns_pc_image = size(counted_map_pc, 2);

         % Get values in expanded image
         for j = 1:rows_pc_image
            for k = 1:columns_pc_image
                current_place = j*rows_pc_image + k;
                newx(current_place) = k*scaling_factor;
                newy(current_place) = j*scaling_factor;
                newz(current_place) = counted_map_pc(k, j);
            end
         end

         v = variogram([newx newy], newz,'plotit',false,'maxdist',100);
         [dum,dum,dum,vstruct] = variogramfit(v.distance,v.val,[],[],[],'model','stable', 'plotit', false);
         title('variogram');

         [Zhat,Zvar] = kriging(vstruct, newx, newy, newz, X, Y);
         
         figure, imagesc(X(1,:), Y(:,1), Zhat);
         title('kriging predictions')
     end