%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trabalho de CFC
% Algoritmo de decodificação baseline JPEG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Chama-se a função abaixo no matlab com os parâmetros:
% all_simb -> Sequência de todos símbolos da codificação
% qtd_linhas, qtd_colunas -> Quantidade de linhas e colunas de blocos 8x8
%                            Esse parâmetro é dado no programa jpeg_cod.m
% flag_test -> Se o usuário optar para verificar o resultado da 
%              codificação de uma certa sequência de símbolos, 
%              passa como parâmetro a matrix dessa sequência (dada pela
%              rotina de teste do programa jpeg_code.m)
%              Passar valor zero no caso de não realizar teste

% Para chamar o programa, escrever no matlab:
%   bloco = jpeg_decod(all_simb, qtd_linhas, qtd_colunas, flag_test)
%   flag_test = simb_t -> para teste
%   flag_test = 0 -> sem testes

% Obs: No caso de testar a decodificação de um bloco, necessita-se de que
% o componente DC anterior seja passado. Seu valor é passado na rotina de
% teste do jepeg_cod.m

function bloco = jpeg_decod(all_simb, qtd_linhas, qtd_colunas, flag_test)


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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Funções auxilares %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % Decodifica sequencia de símbolos para um único bloco 8x8
    function block = decod_blocos(simb, DC_ant, x, y)
        % Bloco a ser decodificado
        block(8,8) = 0;
        
        % Aponta para o elemento do bloco que será definido
        % Usado para percorrer o bloco, de acordo com o mapeamento zig-zag
        block_pointer = 1;
        
        for k = 1:size(simb,1)
            % Componente DC
            if k == 1
                block(1,1) = simb(1,3) + DC_ant;
                block_pointer = block_pointer + 1;
                
            % Componente AC
            else
                % Se o simbolo RUNLENGTH for diferente de zero, preenche 
                % RUNLENGTH elementos com zero
                for kk = 1:simb(k,1)
                    block(y(block_pointer),x(block_pointer)) = 0;
                    block_pointer = block_pointer + 1;
                end
                
                % Quando AMP for diferente de zero, seta o respectivo 
                % valor no bloco (depois de ter percorrido seu RUNLENGTH)
                if simb(k,3) ~= 0
                    block(y(block_pointer),x(block_pointer)) = simb(k,3);
                    block_pointer = block_pointer + 1;
                    
                else
                    % Preenche o final do bloco com zeros, simb: (0,0)
                    if simb(k,1) == 0
                        for kk = 1:(64 - (block_pointer - 1))
                            block(y(block_pointer),x(block_pointer)) = 0;
                            block_pointer = block_pointer + 1;
                        end
                    % caso simb: (15,0)
                    else
                        for kk = 1:15
                            block(y(block_pointer),x(block_pointer)) = 0;
                            block_pointer = block_pointer + 1;
                        end
                    end
                end
            end
        end
    end

    % Realiza dequantização, IDCT e deslocamento de 128
    function decodificar = decod(decod_J)
        decod_R = decod_J .* tabela_luminancia;
        decod_Ridct = idct2(decod_R);
        decod_Rfinal = decod_Ridct + 128;
        decodificar = round(decod_Rfinal);
    end

    % Encontra o código de Huffman
    function [DC_index,linha,coluna] = compare_huffman(huffman)
        key = 0;
        DC_index = 0;
        for huffman_DC = 1:12
            if huffman == dc_huffman(huffman_DC)
                DC_index = huffman_DC;
                key = 1;
                break;
            end
        end
        if key == 0
            for huffman_linha = 1:16
                for huffman_coluna = 1:10
                    if huffman == ac_huffman(huffman_linha,huffman_coluna)
                        linha = huffman_linha;
                        coluna = huffman_coluna;
                        break;
                    end
                end
            end
        end
    end

    function seq_simb = decod_binario(seq_cod)
        huffman = '';
        seq_simb = []
        for k = 1:size(seq_cod,1)
            huffman = strcat(huffman,seq_cod(k))
            %if any(strcmp(ac_huffman,{huffman})) == 0;
            %    huffman = '';
            %end
            [DC_index, linha, coluna] = compare_huffman(huffman);
            
            % Se DC_index ~= 0 -> Representa componente DC
            if DC_index ~= 0
                % Pegar a amplitude DC:
                
                
                %this_simb = [-1 DC_index 
            end
            
        end
        seq_simb = 0;
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Corpo do programa %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


bloco(qtd_linhas * 8, qtd_colunas * 8) = 0;

% A sequencia de simbolos está escrita numa matriz, sendo cada símbolo
% DC: (SIZE)(AMP) e AC: (RUN,SIZE)(AMP) presente numa linha da matriz
% base_pointer aponta para a primeira linha e simb_pointer aponta para
% a última linha de uma sequencia de símbolos que corresponde a um único
% bloco 8x8. Varre-se assim os símbolos gerando os blocos 8x8
base_pointer = 1;
simb_pointer = 2;

% Guarda o componente DC anterior que foi decodificado
DC_ant = 0;


%name_bit = input('Digite o nome do arquivo .bit: ');
%fid = fopen(name_bit,'r');
%all_code = fread(fid,'ubit1');
%fclose(fid);
%decod_binario(cod_test);    


for i = 1:qtd_linhas
    for j = 1:qtd_colunas
        % Limpando a variável que armazena a sequência de símbolos que 
        % corresponde a um bloco 8x8
        clear simb;
        
        % Se for o último bloco
        if (i == qtd_linhas) && (j == qtd_colunas)
            simb = all_simb(base_pointer : size(all_simb,1) , :);
        else
            % Varre a matrix até achar a sequencia do bloco 8x8
            while 1
                % No programa de cod. -1 está no campo de RUN, indicando
                % o começo da sequencia de um bloco 8x8
                if all_simb(simb_pointer,1) == -1
                    break
                else
                    simb_pointer = simb_pointer + 1;
                end
            end
            % Guarda essa sequência
            simb = all_simb(base_pointer:(simb_pointer-1) , :);
        end

        % Decodifica num bloco 8x8
        J = decod_blocos(simb, DC_ant, x, y);
        
        % Volta a quantização, faz a IDCT e desloca de 128  
        R = decod(J);
        
        % Insere o resultado no bloco total
        bloco(1 + 8*(i-1) : 8*i , 1 + 8*(j-1) : 8*j) = R;
        
        % Atualiza o base_pointer, simb_pointer e DC_ant
        base_pointer = simb_pointer;
        simb_pointer = simb_pointer + 1;
        DC_ant = J(1);
    end
end

% Converte os valores para unsigned int 8 bits
bloco = uint8(bloco);

% Cria o arquivo de imagem com nome a ser escolhido
name = input('Digite o nome da imagem de saida (imagem.bmp): ')
imwrite(bloco,name,'bmp')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Funções de Teste %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % Realiza decodificação de um único bloco 8x8
    % Simbolo testado passado como parametro
    
    function show_bloco()
        i = input('Linha da matrix I: ');
        j = input('Coluna da matrix I: ');	
        amostra = bloco(1 + 8*(i-1) : 8*i , 1 + 8*(j-1) : 8*j);
        disp(amostragem);
    end

    %show_bloco();
    
    test_J = [];
    
    if flag_test == 0
        test_J = [];
    else
        disp('Para:')
        flag_test
        test_DC_ant = input('Passe o valor da componente DC anterior: ');
        J = decod_blocos(flag_test, DC_ant, x, y)
        R = decod(J)
    end


end
    