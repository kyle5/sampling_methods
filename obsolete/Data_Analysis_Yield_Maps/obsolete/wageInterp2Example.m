years = 1950:10:1990;
service = 10:10:30;
wage = [150.697 199.592 187.625
179.323 195.072 250.287
203.212 179.092 322.767
226.505 153.706 426.730
249.633 120.281 598.243];

[X,Y] = meshgrid(service,years');
w = interp2(X, Y, wage, 15, 1975)