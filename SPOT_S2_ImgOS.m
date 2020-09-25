% Data processing for SPOT setup
% Step 1: Get optical sectioned images by averaging the polarization
% modulaged HiLo images
% 2020.08.21 Wenhui

clear;

%% load parameters
paras_path = '.\Exp_parameter.mat';
load(paras_path);

%%
save_path = exp.root_path;
ang_n = length(exp.angle);
pha_n = length(exp.phase);
ext_n = size(exp.excitation, 1);
emi_n = size(exp.emission, 1);

%% image average
hilo_dir_s = dir(exp.root_path);
for count = 1: length(hilo_dir_s)
    hilo_dir_name = hilo_dir_s(count).name;
    if contains(hilo_dir_name, 'HiLoOS') && contains(hilo_dir_name, '.tif')
        hilo_all_name = hilo_dir_name;
    end
    if contains(hilo_dir_name, 'HiLo_WF') && contains(hilo_dir_name, '.tif')
        hilo_wf_all_name = hilo_dir_name;
    end
    if contains(hilo_dir_name, 'HiLo_SI') && contains(hilo_dir_name, '.tif')
        hilo_si_all_name = hilo_dir_name;
    end
end

hilo_all_path = [exp.root_path, hilo_all_name];
hilo_wf_all_path = [exp.root_path, hilo_wf_all_name];
hilo_si_all_path = [exp.root_path, hilo_si_all_name];

hilo_all_info = bfopen(hilo_all_path);
hilo_wf_all_info = bfopen(hilo_wf_all_path);
hilo_si_all_info = bfopen(hilo_si_all_path);

img_size = size(hilo_all_info{1}{1,1});
img_num = size(hilo_all_info{1}, 1);

hilo_all = zeros([img_size, img_num]);
hilo_wf_all = zeros([img_size, img_num]);
hilo_si_all = zeros([img_size, img_num]);
for count = 1: size(hilo_all_info{1}, 1)
    hilo_all(:,:,count) = double(hilo_all_info{1}{count, 1});
    hilo_wf_all(:,:,count) = double(hilo_wf_all_info{1}{count, 1});
    hilo_si_all(:,:,count) = double(hilo_si_all_info{1}{count, 1});
end
clear('hilo_all_info', 'hilo_wf_all_info', 'hilo_si_all_info');

hilo_num_all = exp.img_num_all / pha_n * emi_n;
for count = 1: length(exp.folder)
    
    % separat files and store in different folders
    folder_name = exp.folder{count};
    hilo_wf_save = sprintf('%s%s/HiLo_WF.tif',exp.root_path, folder_name);      if exist(hilo_wf_save);delete(hilo_wf_save);end
    hilo_save = sprintf('%s%s/HiLoOS_1.tif',exp.root_path, folder_name);        if exist(hilo_save);delete(hilo_save);end
    hilo_wf_avg_488ex_save = sprintf('%s%s/HiLo_WF_avg_488ex.tif',exp.root_path, folder_name);      if exist(hilo_wf_avg_488ex_save);delete(hilo_wf_avg_488ex_save);end
    hilo_wf_avg_561ex_save = sprintf('%s%s/HiLo_WF_avg_561ex.tif',exp.root_path, folder_name);      if exist(hilo_wf_avg_561ex_save);delete(hilo_wf_avg_561ex_save);end
    hilo_avg_488ex_save = sprintf('%s%s/HiLo_avg_488ex.tif',exp.root_path, folder_name);            if exist(hilo_avg_488ex_save);delete(hilo_avg_488ex_save);end
    hilo_avg_561ex_save = sprintf('%s%s/HiLo_avg_561ex.tif',exp.root_path, folder_name);            if exist(hilo_avg_561ex_save);delete(hilo_avg_561ex_save);end
    
    hilo_num_sum = sum(hilo_num_all(1: count-1));
    hilo_wf = hilo_wf_all(:,:, hilo_num_sum+1: hilo_num_sum+hilo_num_all(count));
    hilo_si = hilo_si_all(:,:, hilo_num_sum+1: hilo_num_sum+hilo_num_all(count));
    hilo = hilo_all(:,:, hilo_num_sum+1: hilo_num_sum+hilo_num_all(count));    % HiLo image order: polarization << excitation channel << time points << detection channel
                                                                                % First get different polarizations. Second get different excitations. Three channls are got simultaneously.
    t_num = hilo_num_all(count) / (emi_n * ext_n * ang_n);
    hilo_wf_avg_488ex = zeros([img_size, emi_n, t_num]);
    hilo_wf_avg_561ex = zeros([img_size, emi_n, t_num]);
    hilo_avg_488ex = zeros([img_size, emi_n, t_num]);
    hilo_avg_561ex = zeros([img_size, emi_n, t_num]);
    
    emi_s = hilo_num_all(count) / emi_n;
    for t_c = 1: t_num
        t_s = (t_c-1)*(ext_n * ang_n);
        for emi_c = 1: emi_n
            hilo_avg_561ex(:,:,emi_c, t_c) = mean(hilo(:,:,(emi_c-1)*emi_s + t_s + 1: (emi_c-1)*emi_s + t_s + ang_n), 3);
            hilo_avg_488ex(:,:,emi_c, t_c) = mean(hilo(:,:,ang_n + (emi_c-1)*emi_s + t_s + 1: ang_n + (emi_c-1)*emi_s + t_s + ang_n), 3);
            
            hilo_wf_avg_561ex(:,:,emi_c, t_c) = mean(hilo_wf(:,:,(emi_c-1)*emi_s + t_s + 1: (emi_c-1)*emi_s + t_s + ang_n), 3);
            hilo_wf_avg_488ex(:,:,emi_c, t_c) = mean(hilo_wf(:,:,ang_n + (emi_c-1)*emi_s + t_s + 1: ang_n + (emi_c-1)*emi_s + t_s + ang_n), 3);
        end
    end
    
    % save images
    bfsave(uint16(hilo_wf), hilo_wf_save);
    bfsave(uint16(hilo), hilo_save);
    bfsave(uint16(hilo_wf_avg_488ex), hilo_wf_avg_488ex_save, 'dimensionOrder', 'XYCTZ');
    bfsave(uint16(hilo_wf_avg_561ex), hilo_wf_avg_561ex_save, 'dimensionOrder', 'XYCTZ');
    bfsave(uint16(hilo_avg_488ex), hilo_avg_488ex_save, 'dimensionOrder', 'XYCTZ');
    bfsave(uint16(hilo_avg_561ex), hilo_avg_561ex_save, 'dimensionOrder', 'XYCTZ');
    
end













