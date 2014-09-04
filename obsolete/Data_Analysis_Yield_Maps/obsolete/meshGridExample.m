[X,Y] = meshgrid(-3:.5:3);
Z = peaks(X,Y);

[XI,YI] = meshgrid(-3:.125:3);
ZI = interp2(X,Y,Z,XI,YI);

mesh(X,Y,Z), hold, mesh(XI,YI,ZI+15)
hold off

axis([-3 3 -3 3 -5 20])