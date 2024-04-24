function creaCSV(Data,Header)

nomi = strjoin(Header, ', ');
dominio = "";
for col = 1:(size(Data, 2)-1)
    val = unique(Data(:, col));
    if col == 1
        dominio = [strjoin(string(val), ' ')];
    else
        dominio = [dominio strjoin(string(val), ' ')];
    end
end
dominio = [dominio "continuous"];
dominio = strjoin(dominio, ', ');

virgole = repmat(',', 1, size(Data, 2));

dati = '';
for row = 1:size(Data, 1)
    dati = [dati strjoin(string(Data(row, :)), ',')];
end

filename = 'Database_PP_Matlab.csv';
fid = fopen(filename, 'w');
fprintf(fid, '%s\n', nomi);
fprintf(fid, '%s\n', dominio);
fprintf(fid, '%s', virgole);
fprintf(fid, '%s\n', dati);
fclose(fid);
end