% Data processing for SPOT setup
% Step 3: Get emission ratio maps
% 2020.08.21 Wenhui

clear;

%% load parameters
img_avg_name = 'HiLo_avg_561ex.tif';
paras_path = '.\Exp_parameter.mat';
if exist(paras_path)
    load(paras_path);
end

%% parameters
if ~exist(paras_path)

img_avg_name = 'HiLo_avg_561ex.tif';
root_path = './';

exp.name = 'MMStack_Default.ome.tif';
exp.excitation = ['488'; '561'];            % excitation channels
exp.emission = ['488'; '561'; '640'];       % emission channels
exp.angle = [0, 60, 120];
exp.phase = [0, 180];

% multi-folder information
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
    
end

%%
save_path = exp.root_path;
ang_n = length(exp.angle);
pha_n = length(exp.phase);
ext_n = size(exp.excitation, 1);
emi_n = size(exp.emission, 1);

%% image ratio
for count = 1: length(exp.folder)
    folder_name = exp.folder{count};
    img_avg_path = [exp.root_path, folder_name, '\', img_avg_name];
    img_avg_info = bfopen(img_avg_path);
    
    img_num = size(img_avg_info{1}, 1);
    t_num = img_num / emi_n;
    
    save_ratio_c1 = sprintf('%s%s/ratio_value_c1.tif',exp.root_path, folder_name);     if exist(save_ratio_c1);delete(save_ratio_c1);end
    save_rgb_c1 = sprintf('%s%s/ratio_rgb_c1.tif',exp.root_path, folder_name);         if exist(save_rgb_c1);delete(save_rgb_c1);end
    save_colormap = sprintf('%s%s/cm_ratio.tif',exp.root_path, folder_name);         if exist(save_colormap);delete(save_colormap);end
    
    ratio_v_max = 10;
    ratio_v_min = 0;
    img_bg = 0;
    for t_c = 1: t_num
        channel_1 = double(img_avg_info{1}{(t_c-1)*emi_n+3 ,1});
        channel_2 = double(img_avg_info{1}{(t_c-1)*emi_n+2 ,1});
        ratio_c1 = channel_1 ./ channel_2;
        
        ratio_c1(find(isinf(ratio_c1))) = 20;
        ratio_c1(find(isnan(ratio_c1))) = 0;
        ratio_c1(find(ratio_c1 > ratio_v_max)) = ratio_v_max;
        ratio_c1(find(ratio_c1 < ratio_v_min)) = ratio_v_min;
        
        ratio1_min = 0.2; ratio1_max = 1.5;
        huel_s = 0.8; huel_e = 0;
        [img_rgb_c1, colormap_rgb] = drawRGB(ratio_c1, channel_2, img_bg, ratio1_min, ratio1_max, huel_s, huel_e);
        
        % results save
        imwrite(uint16(ratio_c1*1000), save_ratio_c1, 'WriteMode', 'append');
        imwrite(uint8(img_rgb_c1*255), save_rgb_c1, 'WriteMode', 'append');
    end
    imwrite(colormap_rgb, save_colormap, 'WriteMode', 'overwrite');
    
end






