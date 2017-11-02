%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trabalho de CFC
% Algoritmo de codificação baseline JPEG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Chama-se a função abaixo no matlab com os parâmetros:
% nome - > nome da imagem a ser aberta (ex: Ex1.bmp)
% flag_test -> se o usuário optar para verificar o resultado da 
%               codificação de um certo bloco 8x8, passa como 
%               parâmetro o valor 1 nesse campo

% Para chamar o programa, escrever no matlab
%   [I,J_test,simb_t,all_simb] = jpeg_cod('nome.bmp',n)
%   n = 1 -> para teste
%   n = 0 -> sem testes

function [I,J_test,simb_t,cod_t,all_simb] = jpeg_cod(nome, flag_test)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variáveis globais
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Tabela para quantizacao da componente de luminancia
tabela_luminancia = [
                    16 11 10 16 24 40 51 61 ;
                    12 12 14 19 26 58 60 55 ;
                    14 13 16 24 40 57 69 56 ;
                    14 17 22 29 51 87 80 62 ;
                    18 22 37 56 68 109 103 77 ;
                    24 35 55 64 81 104 113 92 ;
                    49 64 78 87 103 121 120 101 ;
                    72 92 95 98 112 100 103 99 
                    ];

                
% Ordem zig-zag dos indices dos blocos 8x8
% X e Y armazenam os indices na ordem de zig-zag,
% isto é, um mapeamento é feito, em vez de chamar
% J(i,j), J(i,j+1)..., que corresponde a uma leitura linear,
% chamaremos J(y(k), x(k)), J(y(k+1), x(k+1))..., que corresponderá
% a leitura em zig-zag

x(64) = 0; % indica a coluna de J
y(64) = 0; % indica a linha de J

% O primeiro elemento da leitura zig-zag é J(1,1)
x(1) = 1;
y(1) = 1;

index = 1;
diagonal_loop = 1; % numero de elementos varridos na leitura diagonal
inc = 1; 

% Há 4 tipos de movimentos na leitura zig-zag:
% direita, baixo, diagonal para baixo, diagonal para cima
% o loop abaixo varre a matrix seguindo esses segmentos

for k= 1:27 % K aponta para o proximo componente do zig-zag
        
    % Desloca para direita
    if (mod(k,4) == 1 && k < 15) || (mod(k,4) == 3 && k > 14)
        x(index + 1) = x(index) + 1;
        y(index + 1) = y(index);
        index = index + 1;
    end
    
    % Desce diagonal
    if mod(k,4) == 2
        for k2 = 1:diagonal_loop
            x(index + 1) = x(index) - 1;
            y(index + 1) = y(index) + 1;
            index = index + 1;
        end
        diagonal_loop = diagonal_loop + inc;
    end
    
    % Desloca para baixo
    if (mod(k,4) == 3 && k < 15) || (mod(k,4) == 1 && k > 14)
        x(index + 1) = x(index);
        y(index + 1) = y(index) + 1;
        index = index + 1;
    end
    
    % Sobe diagonal
    if mod(k,4) == 0
        for k2 = 1:diagonal_loop
            x(index + 1) = x(index) + 1;
            y(index + 1) = y(index) - 1;
            index = index + 1;
        end
        diagonal_loop = diagonal_loop + inc;
    end
    
    if diagonal_loop == 7
        inc = -1;
    end
    
    % Após a leitura da maior diagonal (k = 14) do 
    % zig-zag, a ordem dos movimentos muda, por isso verifica-se a 
    % a condição de k < 15, vista acima
end

dc_huffman = {'00', '010', '011', '100', '101', '110', '1110', ...
              '11110', '111110', '1111110', '11111110', '111111110'};

C=[];
empty=0;
EOB = '1010';
ZRL = '11111111001';

% Tabela de Huffman para codificação
% Mapeamento dos símbolos para a tabela:
% (RUN + 1) -> Linha
% SIZE -> Coluna
ac_huffman={
   '00'               '01'               '100'              '1011'             '11010'            '1111000'          '11111000'         '1111110110'       '1111111110000010' '1111111110000011';...
   '1100'             '11011'            '1111001'          '111110110'        '11111110110'      '1111111110000100' '1111111110000101' '1111111110000110' '1111111110000111' '11111111100001000';...
   '11100'            '11111001'         '1111110111'       '111111110100'     '1111111110001001' '1111111110001010' '1111111110001011' '1111111110001100' '1111111110001101' '1111111110001110';...
   '111010'           '111110111'        '111111110101'     '1111111110001111' '1111111110010000' '1111111110010001' '1111111110010010' '1111111110010011' '1111111110010100' '1111111110010101';...
   '111011'           '1111111000'       '1111111110010110' '1111111110010111' '1111111110011000' '1111111110011001' '1111111110011010' '1111111110011011' '1111111110011100' '1111111110011101';...
   '1111010'          '11111110111'      '1111111110011110' '1111111110011111' '1111111110100000' '1111111110100001' '1111111110100010' '1111111110100011' '1111111110100100' '1111111110100101';...
   '1111011'          '111111110110'     '1111111110100110' '1111111110100111' '1111111110101000' '1111111110101001' '1111111110101010' '1111111110101011' '1111111110101100' '1111111110101101';...
   '11111010'         '111111110111'     '1111111110101110' '1111111110101111' '1111111110110000' '1111111110110001' '1111111110110010' '1111111110110011' '1111111110110100' '1111111110110101';...
   '111111000'        '111111111000000'  '1111111110110110' '1111111110110111' '1111111110111000' '1111111110111001' '1111111110111010' '1111111110111011' '1111111110111100' '1111111110111101';...
   '111111001'        '1111111110111110' '1111111110111111' '1111111111000000' '1111111111000000' '1111111111000010' '1111111111000011' '1111111111000100' '1111111111000101' '1111111111000110';...
   '111111010'        '1111111111000111' '1111111111001000' '1111111111001001' '1111111111001010' '1111111111001011' '1111111111001100' '1111111111001101' '1111111111001110' '1111111111001111';...
   '1111111001'       '1111111111010000' '1111111111010001' '1111111111010010' '1111111111010011' '1111111111010100' '1111111111010101' '1111111111010110' '1111111111010111' '1111111111011000';...
   '1111111010'       '1111111111011001' '1111111111011010' '1111111111011011' '1111111111011100' '1111111111011101' '1111111111011110' '1111111111011111' '1111111111100000' '1111111111100001';...
   '11111111000'      '1111111111100010' '1111111111100011' '1111111111100100' '1111111111100101' '1111111111100110' '1111111111100111' '1111111111101000' '1111111111101001' '1111111111101010';...
   '1111111111101011' '1111111111101100' '1111111111101101' '1111111111101110' '1111111111101111' '1111111111110000' '1111111111110001' '1111111111110010' '1111111111110011' '1111111111110100';...
   '1111111111110101' '1111111111110110' '1111111111110111' '1111111111111000' '1111111111111001' '1111111111111010' '1111111111111011' '1111111111111100' '1111111111111101' '1111111111111110'
};

%size(dc_huffman)
%size(ac_huffman)
%ac_huffman(2,1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Funcoes auxiliares %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % Retorna bloco 8x8 de coordenadas (i,j) da imagem I quantizado
    function J = DCT_quant(I,i,j)
        % Separacao dos blocos
        bloco = I(1 + 8*(i-1) : 8*i , 1 + 8*(j-1) : 8*j);
        
        % Deslocamento de 128 dos elementos do bloco
        bloco = double(bloco);
        bloco = bloco - 128;
        
        % DCTF
        J = dct2(bloco);
        
        % Quantizacao
        J = round(J./tabela_luminancia);
    end


    % Retorna o simbolo SIZE de um componente de um bloco 8x8
    function size_number = size_simb(number)
        number = abs(number);
        s = size(de2bi(number));
        if number == 0
            size_number = 0;
        else
            size_number = s(2);
        end
    end


    % Retorna a sequencia de simbolos de um bloco 8x8 quantificado
    function [simb, dc_ant] = cod_simbolos(J,DC_ant,x,y)
        % Simbolo RUN
        run = 0;
        for k = 1:64
            % Componente DC:
            if k == 1
                % O elemento -1 foi inserido apenas para tornar possivel 
                % a combinação com as matrizes das componentes AC e
                % identificar o começo da seq de simb de um bloco
                DC_diferencial = J(1) - DC_ant;
                dc_ant = J(1);
                simb = [-1 size_simb(DC_diferencial) DC_diferencial];
                
            % Componente AC:
            else
                % indexacao: 1 -> qual linha (y), 2 -> qual coluna (x)
                comp = J(y(k),x(k));
                
                % Se o componente AC for zero, incrementa RUN
                if comp == 0
                    run = run + 1;
                    if k == 64
                        % EOB (end of block)
                        simbAC = [0 0 0];
                        simb = cat(1, simb, simbAC);
                    end
                else
                    % Caso haja uma sequencia de mais de 15 zeros
                    zeros = fix(run/16);
                    for kk = 1:zeros
                        simbESP = [15 0 0];
                        simb = cat(1, simb, simbESP);
                        run = run - 15;
                    end
                    simbAC = [run size_simb(comp) comp];
                    
                    
                    % Concatena os simbolos de cada componente numa matrix
                    simb = cat(1, simb, simbAC);
                    
                    % Zera simbolo RUN
                    run = 0;
                end   
            end
        end
    end

    % Converte simbolo Amplitude, em decimal, para seu respectivo valor 
    % binario, considerando se a amplitude for negativa
    function bi = amp2bin(dec)
        if dec >= 0
            bi = de2bi(dec);
        else
            bi = de2bi(bi2de(xor(de2bi(abs(dec)+1),1))+1);
            if (size(bi,2) < size_simb(dec))
                bi(size_simb(dec)) = 0;
            else
                bi = bi(1:size_simb(dec));
            end
        end
        
        bi = bi(end:-1:1);
    end


    % 
    function int_vec = str2int(cell_vec)
        int_vec = [];
        str_vec = cell2mat(cell_vec);
        for i = 1:size(str_vec,2)
            int_vec = [int_vec uint8(str_vec(i))-48];
        end
    end
        

    % Codifica a matrix de símbolos no seu vetor de bits
    function seq_bin = cod_binario(seq_simb)
        %all_simb
        seq_bin = [];
        for k = 1:size(seq_simb,1)
            % Componente DC
            if seq_simb(k,1) == -1 % Código foi feito para q -1 indique DC
                bin_code = dc_huffman(seq_simb(k,2)+1);
                
            % Componente AC
            else
                %all_simb(k,1)+1 
                %all_simb(k,2)
                if seq_simb(k,2) == 0
                    if  seq_simb(k,1) == 0
                        bin_code = {EOB};
                    else
                        bin_code = {ZRL};
                    end
                else
                    bin_code = ac_huffman(seq_simb(k,1)+1, seq_simb(k,2));
                    
                end
            end
            
            seq_bin = [seq_bin str2int(bin_code)];
            seq_bin = [seq_bin amp2bin(seq_simb(k,3))];    
        
            % Retira o último elemento (0 do EOB) que foi inserido 
            if (seq_simb(k,1) == 0) && (seq_simb(k,2) == 0) && (seq_simb(k,3) == 0)
                seq_bin = seq_bin(1:end-1);
            end
        end
    end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Corpo do programa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
% Le arquivo de imagem .bmp (passado como parametro)
I = imread(nome);

% Tamanho total do arquivo de imagem lido
T = size(I);

% Quantidades de linhas e colunas de blocos 8x8
% Se não forem múltiplos de 8, retira-se o resto

qtd_linhas = (T(1) - mod(T(1),8))/8
qtd_colunas = (T(2) - mod(T(2),8))/8

% Componente DC do bloco anterior
DC_ant = 0;

all_simb = [];

% Loop para executar o algoritmo por bloco 8x8
for i = 1:qtd_linhas
    for j = 1:qtd_colunas
        % Chama a função que realiza DCTF e quantizacao para cada bloco
        J = DCT_quant(I,i,j);
        
        % Chama a função de codificacao da sequencia de simbolos
        % Recebe o novo componente DC para cod. diferencial seguinte
        [simb_t, DC_ant] = cod_simbolos(J, DC_ant, x,y);
        
        % Concatena todos os simbolos numa unica matriz
        all_simb = cat(1, all_simb, simb_t);
    end
end

% Codifica os simbolos na sequência de bits
all_code = cod_binario(all_simb);
        
% Escreve a sequencia de bits gerada num arquivo .bit
name = input('Digite o nome do arquivo.bit: ');
fid = fopen(name,'w');
fwrite(fid,all_code,'ubit1');
fclose(fid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Funções de teste
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    function show_I()
        i = input('Linha da matrix I: ');
        j = input('Coluna da matrix I: ');	
        amostra = I(1 + 8*(i-1) : 8*i , 1 + 8*(j-1) : 8*j);
        disp(amostra)
    end

    %show_I();

    
    % Realiza o algoritmo para um único bloco especificado
    function [J_t, simb_t, DC_ant, seq_bin_t] = teste(i,j)
	J_t = DCT_quant(I,i,j);
    
        % Caso o bloco:
        % Não esteja na primeira coluna
        if j > 1
            J_t_ant = DCT_quant(I, i, j-1);
            DC_ant = J_t_ant(1);
        else
            % Esteja na primeira coluna mas não na primeira linha
            if i > 1
                J_t_ant = DCT_quant(I, i-1, qtd_colunas);
                DC_ant = J_t_ant(1);
            % Seja o primeiro elemento
            else
                DC_ant = 0;
            end
        end
        
        simb_t = cod_simbolos(J_t, DC_ant, x,y);
        seq_bin_t = cod_binario(simb_t);
    end

    J_test = [];
    simb_t = [];
    cod_t =[];

    % Se a flag de teste (passada como parâmetro) estiver ativada
    if flag_test == 1
        disp('Teste de codificacao, escolha as coordenadas do bloco');
        %disp('Dimensoes da Matrix I');
        %qtd_linhas
        %qtd_colunas

        i_test = input('Linha da matrix I: ');
        j_test = input('Coluna da matrix I: ');	

        [J_test, simb_t, DC_ant, cod_t] = teste(i_test, j_test);
        J_test
        DC_ant
        disp('Simbolos:');
        disp('RUN SIZE AMP');
        simb_t
        cod_t
        
    end
end
