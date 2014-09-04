x = 0:10; 
y = sin(x);
xi = 0:0.25:10;
yi = interp1(x,y,xi); 
figure, plot(x,y)
figure, plot(xi, yi)