     % create random field with autocorrelation
     [X,Y] = meshgrid(0:500);
     Z = randn(size(X));
     Z = imfilter(Z,fspecial('gaussian',[40 40],8));

     % sample the field
     n = 500;
     x = rand(n,1)*500;
     y = rand(n,1)*500;
     z = interp2(X,Y,Z,x,y);

     % plot the random field
     subplot(2,2,1)
     imagesc(X(1,:),Y(:,1),Z); axis image; axis xy
     hold on
     plot(x,y,'.k')
     title('random field with sampling locations')
     
     % calculate the sample variogram
     
     fprintf('The size of X is : %d by %d \n', size(X, 1), size(X, 2));
     fprintf('The size of Y is : %d by %d \n', size(Y, 1), size(Y, 2));
     fprintf('The size of Z is : %d by %d \n', size(Z, 1), size(Z, 2));
     
     fprintf('The size of x is : %d by %d \n', size(x, 1),  size(x, 2));
     fprintf('The size of y is : %d by %d \n', size(y, 1), size(y, 2));
     fprintf('The size of z is : %d by %d \n', size(z, 1), size(z, 2));

     
     v = variogram([x y],z,'plotit',false,'maxdist',100);
    % and fit a spherical variogram
     subplot(2,2,2)
     [dum,dum,dum,vstruct] = variogramfit(v.distance,v.val,[],[],[],'model','stable');
     title('variogram')

     % now use the sampled locations in a kriging
     [Zhat,Zvar] = kriging(vstruct,x,y,z,X,Y);
     subplot(2,2,3)
     imagesc(X(1,:),Y(:,1),Zhat); axis image; axis xy
     title('kriging predictions')
    subplot(2,2,4)
     contour(X,Y,Zvar); axis image
     title('kriging variance')