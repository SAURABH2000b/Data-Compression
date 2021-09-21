input_image = imread("sample_image_2.jpg");
red_comp = input_image(:,:,1);
green_comp = input_image(:,:,2);
blue_comp = input_image(:,:,3);
image_dim = size(input_image);

%the image we are reading comes from an already compressed format like JPEG
%('.jpg', '.jfif'...), PNG ('png'), etc. the imread() function of MATLAB 
%decompresses the image looking at its file extension and applying the 
%corresponding decompressing algorithm, hence we don't need to worry about
%extracting the raw image from the compressed one by ourself. but we can't 
%use appearing size of this already compressed image to compute the 
%compression factor, thus we need to use the size of the decompressed image 
%by storing it explicitly.

raw_input_image = reshape(input_image, [1 image_dim(1)*image_dim(2)*image_dim(3)]);
FileID = fopen("raw_sample_image_2.txt", 'w');
fprintf(FileID, '%u\t', raw_input_image);
fclose(FileID);
%encoding will be done with 8-bits (1 byte) for each number. there will be
%three different entities in the compressed data:
%1.> color intensity
%2.> count of repetitions
%3.> flags
%color intensity and repetitions count can be distinguished on basis of
%their positions, but in order to make space for flags we consider that max
%value of a count is 252, and the three remaining values can be attached a
%flag meaning as follows:
%1.> 253 -> indicating that the following two numbers will depict a
%count-intensity pair.
%2.> 254 -> indicating the end of line.
%3.> 255 -> indicating end of component.
%we will be following the individual row encoding because it has many
%advantages in applications like previsualizing the compressed image,
%zoom-level dependent displaying (where we skip some rows in order to
%display preview of the compressed image on small screen rectangle).
%these techniques are useful for using images as icons, tiles...

red_comp=adjust_comp(red_comp);
green_comp=adjust_comp(green_comp);
blue_comp=adjust_comp(blue_comp);

compressed_Red = compress(red_comp);
compressed_Green = compress(green_comp);
compressed_Blue = compress(blue_comp);

final_output = transpose([compressed_Red; compressed_Green; compressed_Blue]);
FileID = fopen("compressed_sample_image_2.txt", 'w');
fprintf(FileID, '%u\t', final_output);
fclose(FileID);

compressed_image_dim = size(final_output);
raw_input_dim = size(raw_input_image);
final_output_dim = size(final_output);
compression_factor = double(raw_input_dim(2)/final_output_dim(2));

function compressed_component = compress(inp_comp)
temp_comp_vec = zeros(5000,1,'uint8');
dim = size(inp_comp);
curr_ind=0;
for r=1:dim(1)
    repeat_num = inp_comp(r,1);
    repeat_count = 1;
    for c=2:dim(2)
        if inp_comp(r,c)==repeat_num
            repeat_count = repeat_count + 1;
            if c==dim(2)
                if repeat_count < 4
                    for m=1:repeat_count
                        curr_ind = curr_ind + 1;
                        temp_comp_vec(curr_ind,1) = repeat_num;
                    end
                else
                    repeat_of_repeat = floor(repeat_count/252);
                    remaining_repeat_count = mod(repeat_count,252);
            
                    for n=1:repeat_of_repeat
                        compress_format = [253, 252, repeat_num];
                        for m=1:3
                            curr_ind = curr_ind + 1;
                            temp_comp_vec(curr_ind,1) = compress_format(m);
                        end
                    end
            
                    if remaining_repeat_count < 4
                        for m=1:remaining_repeat_count
                            curr_ind = curr_ind + 1;
                            temp_comp_vec(curr_ind,1) = repeat_num;
                        end
                    else
                        compress_format = [253, remaining_repeat_count, repeat_num];
                        for m=1:3
                            curr_ind = curr_ind + 1;
                            temp_comp_vec(curr_ind,1) = compress_format(m);
                        end
                    end
                end
            end
            continue;
        end
        if repeat_count < 4
            for m=1:repeat_count
                curr_ind = curr_ind + 1;
                temp_comp_vec(curr_ind,1) = repeat_num;
            end
            if c==dim(2)
                curr_ind = curr_ind + 1;
                temp_comp_vec(curr_ind,1) = inp_comp(r,c);
            end
            repeat_num = inp_comp(r,c);
            repeat_count = 1;
            continue;
        end
        if repeat_count > 3
            repeat_of_repeat = floor(repeat_count/252);
            remaining_repeat_count = mod(repeat_count,252);
            
            for n=1:repeat_of_repeat
                compress_format = [253, 252, repeat_num];
                for m=1:3
                    curr_ind = curr_ind + 1;
                    temp_comp_vec(curr_ind,1) = compress_format(m);
                end
            end
            
            if remaining_repeat_count < 4
                for m=1:remaining_repeat_count
                    curr_ind = curr_ind + 1;
                    temp_comp_vec(curr_ind,1) = repeat_num;
                end
            else
                compress_format = [253, remaining_repeat_count, repeat_num];
                for m=1:3
                    curr_ind = curr_ind + 1;
                    temp_comp_vec(curr_ind,1) = compress_format(m);
                end
            end
            repeat_num = inp_comp(r,c);
            repeat_count = 1;
            if c==dim(2)
                curr_ind = curr_ind + 1;
                temp_comp_vec(curr_ind,1) = inp_comp(r,c);
            end
            continue;
        end
    end
    curr_ind = curr_ind + 1;
    temp_comp_vec(curr_ind) = 254;
end
curr_ind = curr_ind + 1;
temp_comp_vec(curr_ind,1) = 255;
compressed_component = temp_comp_vec(1:curr_ind, 1);
end

function correct_comp=adjust_comp(color_comp)
correct_comp=color_comp;
dim=size(color_comp);
for i=1:dim(1)
    for j=1:dim(2)
        if correct_comp(i,j)==253 || correct_comp(i,j)==254 || correct_comp(i,j)==255
            correct_comp(i,j)=252;
        end
    end
end
end
