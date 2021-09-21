file_name = "compressed_sample_image_3.txt";
A = importdata(file_name);
A = uint8(A);
%assuming the maximum image dimension to be compressed is 5000x5000 RGB
decompressed_output = zeros(5000, 5000, 3);
dim = size(A);

row = 1;
comp = 1;
col = 0;
i  = 1;
no_of_rows = 0;
no_of_columns = 0;
while i <= dim(2)
    if A(1,i) == 253
        repeat_count = A(1,i+1);
        repeat_num = A(1,i+2);
        for m = 1:repeat_count
            col = col + 1;
            decompressed_output(row, col, comp )= repeat_num;
        end
        i = i + 3;
        continue;
    end
    if A(1,i) == 254
        row = row + 1;
        no_of_columns = col;
        col = 0;
        i = i + 1;
        continue;
    end
    if A(1,i) == 255
        comp = comp + 1;
        no_of_rows = row-1;
        row = 1;
        col = 0;
        i = i + 1;
        continue;
    end
    col = col + 1;
    decompressed_output(row, col, comp) = A(1,i);
    i = i + 1;
end
final_decompressed_image = uint8(decompressed_output(1:no_of_rows, 1:no_of_columns, :));
figure, imshow(final_decompressed_image);
