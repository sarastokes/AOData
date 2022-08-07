clear ALL


% folder_name = 'C:\Users\spatterson\Postdoc\AO\Data\MC00838_20220804\Ref\';
folder_name = 'C:\Users\spatterson\Dropbox\Postdoc\Data\AO\MC00838_20220804\Ref\';

cd(folder_name);

% Please save all files name in symmetrically before doing the operation 
 % names for example f1,f2,f3...
 %Save the folder of files in the current directory
 path_directory=folder_name; 
 % Pls note the format of files,change it as required
 original_files=dir([path_directory '*.avi']); 
 for k=1:length(original_files)
     fname = original_files(k).name;
     
     flen = length(fname);
     filenameI=strcat(folder_name, fname);
     filenameO=fname(1:flen-4);
     filenameO=strcat(filenameO, 'O.avi');
     filenameO=strcat(folder_name, filenameO);
   % Next do your operation and finding
   
    aviHandle1  = VideoReader(filenameI);
    frames1     = aviHandle1.NumFrames;
    fps1        = aviHandle1.FrameRate;
    imgWidth1   = aviHandle1.Width;
    imgHeight1  = aviHandle1.Height;

    vid_out = VideoWriter(filenameO,'Grayscale AVI');
    vid_out.FrameRate = fps1;
    open(vid_out);

    for (i = 1:frames1)
        frame_i = read(aviHandle1, i);
        writeVideo(vid_out, frame_i);
    end
    
    fprintf('%d, %s\n', k, filenameO);
    
    close(vid_out);
end

return;