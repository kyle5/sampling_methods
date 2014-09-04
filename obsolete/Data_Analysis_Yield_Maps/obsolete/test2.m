load redAppleVariables.mat

% create random field with autocorrelation
     [X,Y] = meshgrid(0:150);
     Z = randn(size(X));
     Z = imfilter(Z,fspecial('gaussian',[40 40],8));
     sizeOfZ = size(Z);
     fprintf('The size of Z is : %d by %d', sizeOfZ(1), sizeOfZ(2));
     % sample the field
     n = 500;
     x = rand(n,1)*150;
     y = rand(n,1)*150;

     x = (1:150)';
     y = (1:150)';
     
     z = interp2(X,Y,Z,x,y);
     
     % plot the random field

     % Kyle
     % z is the magnitude of each of the points at coord x, y
     % 

     subplot(2,2,1)
     imagesc((1:150),(1:150)',Z); axis image; axis xy

     plot(x,y,'.k');
     title('random field with sampling locations');

     % calculate the sample variogram
     
     straight_vector = [];
     rows = size(red_thinned_pc_counts, 1);
     for i = 1:rows
         cur_row = red_thinned_pc_counts(i,:);
         straight_vector = [straight_vector, cur_row];
     end
     
     straight_vector_down = straight_vector';
     first_input = [x y];
     
     disp(size(z));
     disp(size(straight_vector_down));
     disp(size(first_input));
     disp(size(red_thinned_pc_counts));
     
     v = variogram(first_input, straight_vector_down,'plotit',false,'maxdist',100);
     
     % and fit a spherical variogram
     subplot(2,2,2)
     
     [ dum,dum,dum,vstruct ] = variogramfit(v.distance,v.val,[],[],[],'model','stable');
     title('variogram')

     % now use the sampled locations in a kriging
     
     [Zhat,Zvar] = kriging(vstruct,x,y,z,X,Y);
     subplot(2,2,3)
     imagesc(X(1,:),Y(:,1),Zhat); axis image; axis xy
     title('kriging predictions');
     subplot(2,2,4)
     contour(X,Y,Zvar); axis image
     title('kriging variance');