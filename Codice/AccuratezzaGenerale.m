Matrice = readtable("Predizioni.csv");
Dati = Matrice.Variables;


Accuratezza = sum(Dati(:,1) == Dati(:,2))/length(Dati)