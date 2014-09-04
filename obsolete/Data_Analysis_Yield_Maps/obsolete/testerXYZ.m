
     [X,Y] = meshgrid(0:15);
     Z = randn(size(X));
     Z = imfilter(Z,fspecial('gaussian',[4 4],8));
    figure, imagesc(X(1,:),Y(:,1),Z); axis image; axis xy