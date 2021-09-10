%Run Length Encoding (RLE) compression algorithm counts the consecutive
%appearance of a character in a file and using it to encode all these
%repeating characters in a tuple of three characters, {'~' count_character
%repeating_character} where `~' tells the decompressor that the next
%character's ASCII value is the count of the next-to-next character.
%count_character is the character with the ASCII value as count of
%repeatation and repeating_character is the one repeating. 

%this algorithm has certain disadvantages:
%1.> it starts giving compression if the file to be compressed has good
%amound of repeatations with repeating count >= 4, and less repeatations
%with repeating count < 4.

%2.> file specifications are constrained as file should not consist of '~'
%character (or any character that is used by the compressor for signifying
%the start of tuple encoding. and the max repeatations supported is limited
%to 99 (29+99=128). the following code can be modified such that the
%overall cluster of repeatations having size greater than 99 can be
%clustered into groups of 99 characters each, and one extra group with 
%[0,99)characters, and each group of repeatations can be encoded separately 
%(hint: use while loop for each group's encoding).

%3.>only some files (converted to '.txt' file using certain techniques,
%e.g. BinHex Format) can show good compression factors with RLE compression
%technique, e.g. daily rainfall data (which has many repeatations), images
%(where adjacent pixels are likely to have same color)... but formal
%language texts like english text performs worst as english language rarely 
%have any three or more consecutive repeatations of characters in its word
%bank, hence compression factor is generally close to 1.

%we have implemented RLE on two text files:
%'sample.txt' have good amount of long repeatations hence gives compression
% factor of 1.1663 which is good considering the small size of the file.
% 'sample_proper_english.txt' on the other hand gives compression factor of
% 1.1000 which is not good enough.

fileID = fopen("sample.txt", 'r');
[A, count] = fscanf(fileID,'%c',inf); %A is a character vector, count is the number of characters in this character vector.
fclose(fileID);

compressed_chars = blanks(count);

first_char=A(1);
ind=1;
for x=2:count
    if A(x)==first_char
        ind=ind+1;
    else
        break;
    end
end
for y=1:ind-1
    compressed_chars(y)=first_char;
end
char_count=ind-1;
repeat_counter=1;
saving_char=first_char;

for i=ind+1:count
    ch=A(i);
    if ch==saving_char
        repeat_counter=repeat_counter+1;
        continue;
    end
    if repeat_counter<4
        for m=1:repeat_counter
            char_count=char_count+1;
            compressed_chars(char_count)=saving_char;
        end
        saving_char=ch;
        repeat_counter=1;
        if i==count
            char_count=char_count+1;
            compressed_chars(char_count)=ch;
        end
    else
        compressed_format=['~' char(repeat_counter+29) saving_char];
        for n=1:3
            char_count=char_count+1;
            compressed_chars(char_count)=compressed_format(n);
        end
        saving_char=ch;
        repeat_counter=1;
        
    end
end
compressed_data=compressed_chars(1:char_count);
compression_factor = count/char_count;
fileID=fopen('compressed_sample.txt','w');
fprintf(fileID,'%c',compressed_data);
fclose(fileID);
