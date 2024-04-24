%% ---------------------------- LETTURA DATI -------------------------------
clc
close all
clear


Matrice = readtable("Dati_Nuovo.csv");
Header = Matrice.Properties.VariableNames;
Dati = Matrice.Variables;
[m, n] = size(Dati);

n = n-1;


%% ---------------------------- DATA VISUALIZATION -------------------------

% Ora vado a fare un analisi univariata, per vedere quali feature sono più
% associate all'outcome


% Outcomek = Dati;

% for k = 1:6
    p1 = zeros(n,n);
    V1 = zeros(n,n);
%    Outcomek(:,n) = Dati(:,n) == i;
    for i = 1:n
        for j = 1:n
            [tbl, chi2, p1(i,j)] = crosstab(Dati(:,i), Dati(:,j));  % Test Chi2
            % Cramer's V
            %               X²
            % V = √ ------------------ 
            %        m * min(r-1,c-1)
            V1(i,j) = sqrt(chi2/(m* (min(size(tbl)-1)) ) );
        end
    end
    figure(1)
    % subplot(1,2,1)
    imagesc(p1); % Display the matrix as an image
    colorbar;
    set(gca, 'XTick', 1:n, 'XTickLabel', Header, 'YTick', 1:n, 'YTickLabel', Header);
    xtickangle(90); 
    ax = gca;
    ax.XAxisLocation = 'top';
        fig = gcf;
    fig.Position(3:4) = [700 600];


    figure(2)
    % subplot(1,2,1)
    imagesc(V1);  % Display the matrix as an image
    colorbar;

    % Metto le label per ogni riga
    set(gca, 'XTick', 1:n, 'XTickLabel', Header, 'YTick', 1:n, 'YTickLabel', Header);
    xtickangle(90); 
    ax = gca;
    ax.XAxisLocation = 'top';

        fig = gcf;
    fig.Position(3:4) = [700 600];

    disp("LE FEATURE MAGGIORMENTE ASSOCIATE ALL'OUTCOME SONO: ")
    Header{V1(:,n) > .6}
    

    % COMMENTI GRAFICO P-VALUE e CORRELAZIONE
    % Da questo Grafico vedo subito che tutte le feature sono legate
    % all'outcome, e non ne esiste nessuna che sia indipendente.
    % Quello che posso fare è vedere quali feature sono legate a quale outcome.

    % CONSEGUENZA BINARIZZAZIONE OUTCOME SU INDIPENDENZA E CORRELAZIONE
    % Ho 6 diversi outcome [1 6], posso vedere se ne estono alcune legate
    % all'outcome 1,2...6
    % Dai grafici si envince che nessuna variabile ha qualche indipendenza.
    % Quindi già me le devo tenere tutte.
    % Proviamo ora a fare la correlazione per variabili categoriche/Intervallari (se
    % esiste)

    % Esiste la corrleazione di Spearman, per variabili binarie non va bene
    % perché va a guardare i rangho tra 2 variabili, quindi se ho M F (0 1)
    % avrò tanti "pareggi", quindi rende la matrice tutta uguale (infatti
    % l'avevo già calcolata quando ho fatto le dummy variables ed era venuta
    % tutta 0. Proviamo a calcolarla ora che ho diversi valori).
    % Ok la correlazione di spearman funziona, ora so che alcune variabili
    % sono associate maggiormente all'outcome.
%%

    % UNIRE INSIEME VARIABILI, NE VALE LA PENA?
    % Ora potrei poensare di vedere quali variabili siano dipendenti e
    % strettamente correlate e cercare di metterle insieme.
    % Attenzione però, perché cambiamenti su una variabile mi danno
    % cambiamenti nell'altra. Se le unisco vado a perdere informazioni tra
    % le variabili.
    % Però è possibile che combinandole riesco a non perdere poi così tanta
    % informazione, e che riescano a catturare meglio la relazione con
    % l'outcome


%% ---------------------------- PRE PROCESSING -------------------------

% PANORAMICA
% In questa fase vado a fare Imputing, Bilanciamenti, Uso di Dummy
% Variables ecc. 
% Scrivi il codice in modo tale che sia generalizzabile. Quindi quando vado
% a fare modifiche sui dati non devo fare mille mila modifiche

% IMPUTING
% Imputing l'ho fatto su Orange, al posto di alcuni dati mancanti sull'età
% ho fatto messo l'opzione simple tree.

% DISCRETIZZAZIONE ?
% Bisogna vedere se ha senso discrettizarla oppure no. Guardando alla
% variabilità spiegata, l'età fa abbastanza pena. Quindi penso proprio che
% manco mi serve la variabile stessa.





% BILANCIAMENTI
% Alcune varibili hanno delle categorie rare, le quali possono portarmi a
% fare overfitting e, di conseguenza, andare a peggiorare la
% generalizzazione. Per questo motivo posso pensare di collassare categorie
% su loro stesse.
% Però il problema principale è che:
%       - Perdo informazione, vale la pena perderla? Dipende, bisogna
%         vedere una misura di disperisione. 
%       - Peggioro l'indipendenza, questo perché vado a nascondere alcune
%         informazioni che rendono le variabili indipendenti tra di loro. Ne
%         vale la pena? Dipende, bisogna vedere se collasando le categorie
%         cosa vado a rendere non più indipendente e qunata informazione
%         andrei a perdere. Quindi, allo stesso modo, devo andare a calcolare
%         una misura di disperisione
% 
% Per ora, dato che il test del chi quadro funziona male per le categorie
% rare (frequenze <5), incorporo le categorie rare e continuo ad usare il
% test del chi quadro. Per una variabile (erythema) la categroia rara è la
% 0, quindi l'assenza del sintomo. In questo caso non ha alcun senso
% incorporarla alla 1. Per questo userò il test esatto di fisher.
% Però non posso usare la V di Cramer per questa variabile, quindi dovrei
% vedere se ha senso eliminarla completamente. Si possono però usare gli odds
% ratio.Però, se vado a vedere il rank, vedo che non è in grado di spiegare
% molta variabilità, quindi magari è meglio toglierla.
% Chiedi domani alla prof.
clc

for i = 1:n
    freq{i} = tabulate(Dati(:,i));

    if sum(freq{i}(:,2) < 5) ~= 0
        i
        Header{i}
        find(freq{i}(:,2) < 5)
    end
end

% Vedo su orange le categorie che devono essere collassate
%  4 - vacuolisation_and_damage_of_basal_layer: 1 -> 2
%  8 - erythema: forse eliminazione
% 23 - follicular_horn_plug: ~95% vs ~5%, 3 -> 2; Binarizzazione/Eliminazione
% 24 - perifollicular_parakeratosis: ~95% vs ~5%, Binarizzazione
% 29 - polygonal_papules: 1 -> 2
% 33 - band_like_infiltrate: 1 -> 2

% ---------------------------- MODIFICA DATI -------------------------------
%   ORANGE
%       - Usando la feature statistic, posso vedere che alcune categorie di
%       alcuni attributi, sono associati ad un solo outcome.
%       Per esempio per thinning_of_... le categorie 1 2 3 sono associate
%       quasi completamente all'outcome 1.
%       Ha senso incorporarle? Alla fine non hanno informazioni
%       contrastanti tra di loro. (Ce ne sono molte altre)
% Variabili che vado a Binarizzare
%    2 - thinning_of_the_suprapapillary_epidermis
%    3 - focal_hypergranulosis
%    4 - vacuolisation_and_damage_of_basal_layer
%    5 - ral_mucosal_involvement
%    7 - melanin_incontinence
%   20 - munro_microabcess
%   23 - follicular_horn_plug
%   24 - perifollicular_parakeratosis
%   27 - fibrosis_of_the_papillary_dermis
%   29 - polygonal_papules
%   30 - saw_tooth_appearance_of_retes
%   31 - clubbing_of_the_rete_ridges
Dati2 = Dati;
Binarizza = [2 3 4 5 7 20 23 24 27 29 30 31];
for i = Binarizza
    Dati2(Dati2(:,i) ~= 0, i) = 1;
end

% Dati2(Dati2(:,4) == 1, 4) = 2;
% Dati2(Dati2(:,23) == 3, 23) = 2;
% Dati2(or(Dati2(:,24) == 3, Dati2(:,24) == 2), 24) = 1;
% Dati2(Dati2(:,29) == 1, 29) = 2;
Dati2(Dati2(:,33) == 1, 33) = 2;

% ---------------------------- LETTURA DATI --------------------------------
    p2 = zeros(n,n);
    V2 = zeros(n,n);
%    Outcomek(:,n) = Dati(:,n) == i;
    for i = 1:n
        for j = 1:n
            [tbl, chi2, p2(i,j)] = crosstab(Dati2(:,i), Dati2(:,j));  % Test Chi2
            V2(i,j) = sqrt(chi2/(m* (min(size(tbl)-1)) ) );
        end
    end
    figure(3)
    %subplot(1,2,2)
    imagesc(p2); % Display the matrix as an image
    colorbar;
    set(gca, 'XTick', 1:n, 'XTickLabel', Header, 'YTick', 1:n, 'YTickLabel', Header);
    xtickangle(90); 
    ax = gca;
    ax.XAxisLocation = 'top';
    fig = gcf;
    fig.Position(3:4) = [700 600];

%     subplot(1,2,2)
%     imagesc(cor);  % Display the matrix as an image
%     colorbar;
% 
%     % Metto le label per ogni riga
%     set(gca, 'XTick', 1:n, 'XTickLabel', Header, 'YTick', 1:n, 'YTickLabel', Header);
%     xtickangle(90); 
%     ax = gca;
%     ax.XAxisLocation = 'top';
    
    % Aggiusto la posizione del grafico


    figure(4)
    % subplot(1,2,2)
    imagesc(V2);  % Display the matrix as an image
    colorbar;

    % Metto le label per ogni riga
    set(gca, 'XTick', 1:n, 'XTickLabel', Header, 'YTick', 1:n, 'YTickLabel', Header);
    xtickangle(90); 
    ax = gca;
    ax.XAxisLocation = 'top';

        fig = gcf;
    fig.Position(3:4) = [700 600];

%     fig = gcf;
%     fig.Position(3:4) = [1400 600];

    % Vado a vedere come è cambiata l'indipendenza e la correlazione dopo
    % la binarizzazione
    figure(5)
    subplot(1,2,1)
    imagesc(abs(p2-p1));  % Display the matrix as an image
    colorbar;

    % Metto le label per ogni riga
    set(gca, 'XTick', 1:n, 'XTickLabel', Header, 'YTick', 1:n, 'YTickLabel', Header);
    xtickangle(90); 
    ax = gca;
    ax.XAxisLocation = 'top';

    subplot(1,2,2)
    imagesc(V2-V1);  % Display the matrix as an image
    colorbar;

    % Se la Mappa è negativa, allora l'associazione tra target e attributo
    % è diminuito, altrimenti è aumentato


    % COMMENTI SUI GRAFICI DELLE DIFFERENZE
    % L'indipendenza tra le variabili è peggiorata, però d'altro canto,
    % l'associazione tra gli attributi e il target è aumentato e non
    % di poco. Quinid, cosa è meglio? Secondo me è meglio che
    % l'associazione con il target sia aumentato. L'indipendenza alla fine
    % la posso migliorare usando le dummy variables.
    colorbar;

    % Metto le label per ogni riga
    set(gca, 'XTick', 1:n, 'XTickLabel', Header, 'YTick', 1:n, 'YTickLabel', Header);
    xtickangle(90); 
    ax = gca;
    ax.XAxisLocation = 'top';



    fig = gcf;
    fig.Position(3:4) = [1400 600];

% T-SNE
% t-sne serve per visualizzare i dati con altà dimensionalità, in 2
% dimensioni. Questo per andare a vedere i cluster / separazione della
% classificazione.
% Nel mio database, per esempio, ho le categorie target molto ben separate,
% tranne che per qualche esempio (magari è meglio toglierlo) e le categorie
% 2 e 4 si confondono molto tra di loro.
% Ma questo cosa significa esattamente? Non penso che abbia senso
% incorporare tra di loro gli outcome, però vuol dire certamente che la
% complessità della classificazione ricade sul discernere queste 2
% categorie. Quindi la feature selection dovrebbe concentrarsi su di loro?
% Ho trovato degli outliers, li vado a rimuovere



%% Dummy Variables
% % Esporto il database e lo modifico su Orange
% % creaCSV(Dati2,Header);
% 
% 
% % DUMMY VARIABLES
% % L'uso delle dummy variables è utile perché: aumenta l'indipendenza tra le
% % variabili (ottimo per modelli) e in alcuni casi va a bilanciare i dati.
% % Inoltre sto aggiungendo informazioni perchè vado a vedere nello specifico
% % quale istanza della variabile categorica è associata all'outcome.
% % Il problema principale con le dummy variables, è la perdita di
% % informazione. Nel mio caso, avendo per lo più variabili ordinali, vado a
% % perdere le informazioni sulla ordinalità delle variabili.
% % Però, dato che la regressione lineare è afflitta negativamente da
% % variabili categoriche ordinali (favorisce valori più alti), non è
% % necessariamente una cosa malvagia.
% % Un altro problema riguarda la sparsità dei dati. Variabili categoriche
% % rare, non saranno per nulla bilanciate una volta trasformate. Il che può
% % portare a distorsione e Overfitting del modello.
% 
% 
% % 
% Matrice = readtable("Dati_Dummy.csv");
% Header = Matrice.Properties.VariableNames;
% Dati = Matrice.Variables;
% [m, n] = size(Dati);
% 
% n = n-1; % Qui perché come ultima varaiabile ho messo l'età
% 
%     pd = zeros(n,n);
%     Vd = zeros(n,n);
% %    Outcomek(:,n) = Dati(:,n) == i;
%     for i = 1:n
%         for j = 1:n
%             [tbl, chi2, pd(i,j)] = crosstab(Dati(:,i), Dati(:,j));  % Test Chi2
%             Vd(i,j) = sqrt(chi2/(m* (min(size(tbl)-1)) ) );
%         end
%     end
%     figure(3)
%     subplot(1,2,1)
%     imagesc(pd); % Display the matrix as an image
%     colorbar;
%     set(gca, 'XTick', 1:n, 'XTickLabel', Header, 'YTick', 1:n, 'YTickLabel', Header);
%     xtickangle(90); 
%     ax = gca;
%     ax.XAxisLocation = 'top';
% 
% %     subplot(1,2,2)
% %     imagesc(cor);  % Display the matrix as an image
% %     colorbar;
% % 
% %     % Metto le label per ogni riga
% %     set(gca, 'XTick', 1:n, 'XTickLabel', Header, 'YTick', 1:n, 'YTickLabel', Header);
% %     xtickangle(90); 
% %     ax = gca;
% %     ax.XAxisLocation = 'top';
%     
%     % Aggiusto la posizione del grafico
% 
%     subplot(1,2,2)
%     imagesc(Vd);  % Display the matrix as an image
%     colorbar;
% 
%     % Metto le label per ogni riga
%     set(gca, 'XTick', 1:n, 'XTickLabel', Header, 'YTick', 1:n, 'YTickLabel', Header);
%     xtickangle(90); 
%     ax = gca;
%     ax.XAxisLocation = 'top';
%     fig = gcf;
%     fig.Position(3:4) = [1400 600];
% 
% 
% Dal grafico della V di Cramer, fatto sulle Dummy Variables, si può vedere
% che le variabili sono più indipendenti tra di loro, e il grado di
% correlazione che hanno sul target è molto più marcato per alcune di esse
% rispetto a quanto usciva nei grafiic precedenti.
% Posso usare la V di Cramer come misura di dispersione? Secondo me no,
% dato che non è una misura dell'informazione,ma una misura della forza
% dell'associazione tra variabili, e non penso manco abbia un unità di misura.

%% ---------------------------- FEATURE SELECTION --------------------------


% Ora devo vedere quali variabili sono più associate all'outcome
% Dai tentativi che ho fatto, ho visto che usando il rank, risco ad
% ottenere un'efficienza di ~0.8, il problema però è che guardando la
% Matrice di Confusione, vedo che le feature scelte (3 se non ricordo
% male) portano con se un bel bias. Infatti il classificatore funziona
% molto bene per le malattie 1,3,5 e funziona estremamente male per le
% altre. Avevo provato a rendere il rank una dummy variable, e vedere quali
% feature fossero più associate alle singole malattie, e ne avevo trovate 6.
% Il classificatore aveva comunque un efficienza di ~0.8, ma era molto più
% bilanciato.
% Ha senso fare una cosa del genere ho c'é bisogno di altri metodi?
% Esitono però altri metodi di selezione delle feature, come ad esempio la
% ReliefF, devo vedere però come funziona.



% COSA HO FATTO:
%   - La feature selection va fatta solo sul training data, questo perché
%   sto facendo effettivamente la parte di training, se vado ad imparare
%   anche dai dati di testing la mia classificazione avrà certamente un
%   bias. Per questo motivo, prima di tutto, ho fatto un campionamento
%   stratificato. Questo perché la variabile target non è uniformemente
%   distribuita. Quindi il classificatore verrebbe ancor più sbilanciato
%   dalla categoria più numerosa.
%   - Dopodiché devo decidere che tipo di feature selection fare. 
%     Creo una variabile target dummy, e verifico quale attributo è il
%     migliore per ogni categoria. Uso un altra metodica? La prof ha detto
%     che la prima è un ottima idea.
%   - Ho diviso l'outcome in dummy variables, e preso le 6 feature più
%   informative per ogni outcome. Funziona molto bene, forse fin troppo
%   bene
%   - Ora, il problema è che, se divido il training e test con il classico
%   70/30, e ricampiono tante volte, i campioni non saranno indipendenti,
%   quindi la stima dell'accuratezza può essere distorta.
%   Se invece usassi la k-fold cross validazione, i campioni non saranno
%   indipendenti, però c'é un problema.
%   La feature selection la vado a fare su tutto il database? Oppure per
%   ogni k-fold faccio la feature selection?
%   Il problema della prima è che andrei a fare Overfitting, mi fido troppo
%   del database.
%   Il problema della seconda, invece, è che potrei trovare feature diverse
%   ad ogni fold, quindi quale modello devo andare poi a scegliere? Se ne
%   ho alcuni diversi? Faccio ulteriori k-fold per ogni modello trovato e
%   scelgo qual è il migliore?
%

%   

% Se vado ad usare la regressione logistica, posso usare i grafici fatti in
% precedenza per vedere se le feature scelte sono indipendenti e
% incorrelate.
%% -------------- MODELS TRAINING, EVALUATION, AND SELECTION ---------------


% Qui devo vedere quale Modello ha più senso utilizzare date le
% caratteristiche del mio database. Non penso basti solamente provare tutti
% quanti i modelli e prendere semplicemente quello che funziona meglio.
% Capisici il motivo per cui alcuni modelli sono più adatti anche se non
% funziona bene.
% Allora, qui è meglio usare un 10-fold Cross validazione e calcolare
% l'accuratezza e Intervalli di Confidenza.
% Commenta poi un po' l'AUC.

% * Prova a vedere se posso graficare gli esempi per vedere se è possibile
%   fare clustering (es. incorporare la 4 e 6), anche usando t-sne.

% * Rivedi di fare le dummy sull'outcome e vedere quali attributi spiegano
%   più variabilità


