% Data processing for SPOT setup
% Step 1: Get HiLo images of different detection channels under different
% excitation wavelengths
% 2020.08.21 Wenhui

clear;

%% parameters
root_path = './';
save_path = root_path;

exp.name = 'MMStack_Default.ome.tif';
exp.excitation = ['488'; '561'];            % excitation channels
exp.emission = ['488'; '561'; '640'];       % emission channels
exp.angle = [0, 60, 120];
exp.phase = [0, 180];
exp.reg(:,:,1) = [387.61, 353.46, 1; 889.29, 467.90, 1; 355.89, 642.68, 1; 739.46, 843.34, 1];
exp.reg(:,:,2) = [359.56, 342.53, 1; 859.03, 457.48, 1; 327.45, 630.90, 1; 708.83, 831.59, 1];
exp.reg(:,:,3) = [359.83, 353.83, 1; 858.73, 468.41, 1; 327.28, 641.62, 1; 708.33, 842.16, 1]; 
exp.reg(:, 1:2, :) = exp.reg(:, 1:2, :) + 1;

ang_n = length(exp.angle);
pha_n = length(exp.phase);
ext_n = size(exp.excitation, 1);
emi_n = size(exp.emission, 1);

%% multi-folder information
folder_dir = dir(root_path);
folder_num = 0;
for count = 3: length(folder_dir)
    folder_name = folder_dir(count).name;
    data_path = sprintf('%s%s/%s_%s', root_path, folder_name, folder_name, exp.name);
    if exist(data_path,'file')
        folder_num = folder_num + 1;
        folder_all{folder_num} = folder_name;
    end
end
exp.folder = folder_all;
exp.root_path = [folder_dir(1).folder, '\'];

%% prepration for hilo
data_path = sprintf('%s%s/%s_%s', root_path, folder_all{1}, folder_all{1}, exp.name);
data_info = bfopen(data_path);
img_size = size(data_info{1}{1,1});
img_num = size(data_info{1}, 1);

folder_num = length(folder_all);
img_num_all = zeros(1, folder_num);
hilo_wf_all = zeros([img_size/2, folder_num*img_num/pha_n * emi_n]);        % wide-field image stack for HiLo
hilo_si_all = zeros([img_size/2, folder_num*img_num/pha_n * emi_n]);        % structured illumination image stack for HiLo

wf_all_save = sprintf('%sHiLo_WF_all.tif', root_path);
si_all_save = sprintf('%sHiLo_SI_all.tif', root_path);
if exist(wf_all_save); delete(wf_all_save); end
if exist(si_all_save); delete(si_all_save); end

fprintf('The folder number being processing is: %02d / %02d', 0, folder_num);
for count = 1: folder_num
    fprintf('\b\b\b\b\b\b\b%02d / %02d', count, folder_num);
    
    folder_name = folder_all{count};
    data_path = sprintf('%s%s/%s_%s', root_path, folder_name, folder_name, exp.name);
    reg_check_path = sprintf('%s%s/reg_check.tif', root_path, folder_name);
    data_info = bfopen(data_path);
    img_num = size(data_info{1}, 1);
    img_num_all(count) = img_num;
    img_raw_all = zeros([img_size, img_num]);
    
    for img_c = 1: img_num
        img_raw_all(:,:,img_c) = double(data_info{1}{img_c, 1});
    end
    clear data_info
    
    [hilo_wf, hilo_si] = hilo_pre(img_raw_all, exp);            % prepration for hilo
    clear img_raw_all
    
    img_p_sum = sum(img_num_all(1: count-1)) / pha_n * emi_n;
    img_c_num = img_num / pha_n * emi_n;
    hilo_wf_all(:,:,img_p_sum+1: img_p_sum+img_c_num) = hilo_wf;
    hilo_si_all(:,:,img_p_sum+1: img_p_sum+img_c_num) = hilo_si;
    
    reg_check = hilo_wf(:,:,floor(img_num/pha_n/2) : img_num/pha_n: end);
    reg_check_1 = hilo_si(:,:,floor(img_num/pha_n/2) : img_num/pha_n: end);
    reg_check = cat(3, reg_check, reg_check_1);
    if exist(reg_check_path); delete(reg_check_path); end
    bfsave(uint16(reg_check), reg_check_path);
end
fprintf('\n');

exp.img_num_all = img_num_all;
exp.img_size = [size(hilo_wf,1), size(hilo_wf,2)];
save('Exp_parameter.mat', 'exp');

bfsave(uint16(hilo_wf_all), wf_all_save);
bfsave(uint16(hilo_si_all), si_all_save);









