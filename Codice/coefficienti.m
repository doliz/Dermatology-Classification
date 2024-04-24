clc
close all
clear


Matrice = readtable("coefficients.csv");

Header = Matrice(4:end,1);
Matrice = Matrice(4:end,2:end);

Dati = Matrice.Variables;


%%

nomi = {'fibrosis of the papillary dermis'	'thinning of the suprapapillary epidermis'	'follicular horn plug'	'spongiosis'	'focal hypergranulosis'	'koebner phenomenon'};
uno = 0.516293964544090;
due = -1.90115685336461;
tre = 0.252506750073279;
quattro = 0.425863224069238;


bar([uno -uno 0 0;due -due 0 0;tre -tre 0 0; 1.34628606194826...
-0.229158676331302...
-0.688350947896990...
-0.428825783496796;...
 quattro -quattro 0 0;...
-0.0759241052676152...
0.147724424280810...
-0.0695352206155227...
-0.00231444417450301])
set(gca, 'XTick', 1:6, 'XTickLabel', nomi);
legend('0', '1', '2', '3')










