fileID= fopen("compressed_sample.txt",'r');
[A, count] = fscanf(fileID,'%c',inf);
fclose(fileID);

%assuming that max compression ratio achieved by RLE Text compression
%scheme is 5, so we will temporarily store the decompressed string in a
%vector of size 5*count.

decompressed_char_vec = blanks(5*count);

in_char_count=1;
out_char_count=1;

while in_char_count<=count
    if A(in_char_count)~='~'
        decompressed_char_vec(out_char_count)=A(in_char_count);
        in_char_count=in_char_count+1;
        out_char_count=out_char_count+1;
    else
        repeat_char=A(in_char_count+2);
        repeat_count=uint8(A(in_char_count+1)-29);
        for c=1:repeat_count
            decompressed_char_vec(out_char_count)=repeat_char;
            out_char_count=out_char_count+1;
        end
        in_char_count=in_char_count+3;
    end
end
decompressed_data = decompressed_char_vec(1:out_char_count-1);

correct_decompression = false;

%check for correctness of decompressed file

%fileID = fopen("sample.txt",'r');
%[B, count1] = fscanf(fileID,'%c',inf);
%fclose(fileID);
%if count1==out_char_count-1
%    diff = uint8(B)-uint8(decompressed_data);
%    d=find(diff);
%    siz_d = size(d);
%    if siz_d(2)==0
%        correct_decompression = true;
%    end
%end

fileID=fopen('decompressed_sample.txt','w');
fprintf(fileID,'%c',decompressed_data);
fclose(fileID);
