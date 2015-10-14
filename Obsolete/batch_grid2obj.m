function batch_grid2obj(input_dir,output_dir)
    files=dir(input_dir);
    n=length(files);
    
    %Counter
    k=1;
    for j=1:n
        if files(j).isdir==0 && ~isempty(strfind(files(j).name,'.grid'))
            %Display progress
            fprintf(1,'Converting file %s. \n',files(j).name);
            
            %Convert files
            [~,filename,~]=fileparts(files(j).name);
            out_filename=strcat(output_dir,'/',filename,'.obj');
            quads=grid2array(strcat(input_dir,'/',files(j).name));
            array2obj(quads,out_filename);
            
            fprintf(1,'Wrote file: "%s" to directory "%s" \n',files(j).name,out_filename);
            k=k+1;
        end
    end
end