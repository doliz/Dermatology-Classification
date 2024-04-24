clc
close all
clear


Matrice = readtable("Classificatori.csv");
Header = Matrice.Properties.VariableNames;
Dati = Matrice.Variables;

Dati = Dati(2:end,[1 2 3 4 5 30]);
[m, n] = size(Dati);
k = 10;

Fold = 1:k;
Accuratezza = zeros(4,k);
for j = 2:5
    for i = Fold
        indFold = Dati(:,end) == i;
        k = sum(indFold);
        Accuratezza(j-1,i) = sum(Dati(indFold, j) == Dati(indFold, 1))/k;
    end
    
    Header{j}
    StdAcc = std(Accuratezza(j-1,:));

    AccMedia = mean(Accuratezza(j-1,:))
    [AccMedia - tcdf(k-1,1-0.05/2)*StdAcc/sqrt(k)  AccMedia + tcdf(k-1,1-0.05/2)*StdAcc/sqrt(k)]

end
%%
modelli = {'Logistic Regression','Logistic Regression','Logistic Regression','Logistic Regression','Logistic Regression','Logistic Regression','Logistic Regression','Logistic Regression','Logistic Regression','Logistic Regression',...
         'SVM','SVM','SVM','SVM','SVM','SVM','SVM','SVM','SVM','SVM',...
         'Tree','Tree','Tree','Tree','Tree','Tree','Tree','Tree','Tree','Tree', ...
         'Constant','Constant','Constant','Constant','Constant','Constant','Constant','Constant','Constant','Constant'};

[p, ~, stats] = kruskalwallis([Accuratezza(1,:) Accuratezza(2,:) Accuratezza(3,:) Accuratezza(4,:)],modelli)
multcompare(stats)



