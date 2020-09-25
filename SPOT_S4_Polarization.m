% Data processing for SPOT setup
% Step 3: Get emission ratio maps
% 2020.08.21 Wenhui

clear;

%% load parameters
img_pm_name = 'HiLoOS_1.tif';
paras_path = '.\Exp_parameter.mat';
if exist(paras_path)
    load(paras_path);
end

%% parameters
if ~exist(paras_path)

img_pm_name = 'HiLoOS_1.tif';
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

%% polarization demodulation
c_select = 2;
img_bg = 0;

for count = 1: length(exp.folder)
    folder_name = exp.folder{count};
    img_pm_path = [exp.root_path, folder_name, '\', img_pm_name];
    img_pm_info = bfopen(img_pm_path);
    img_size = size(img_pm_info{1}{1,1});
    hilo_num = size(img_pm_info{1}, 1);
    
    hilo = zeros([img_size, hilo_num]);
    for hilo_c = 1: hilo_num
        hilo(:,:,hilo_c) = double(img_pm_info{1}{hilo_c, 1});
    end
    clear img_pm_info
    
    save_om_hilo = sprintf('%s%s/Orientation_hilo.tif',exp.root_path, folder_name);        if exist(save_om_hilo);delete(save_om_hilo);end
    save_angle_hilo = sprintf('%s%s/OMAlpha_hilo.tif',exp.root_path, folder_name);        if exist(save_angle_hilo);delete(save_angle_hilo);end
    save_ouf_hilo = sprintf('%s%s/OUF_hilo.tif',exp.root_path, folder_name);        if exist(save_ouf_hilo);delete(save_ouf_hilo);end
    save_ouf_rgb_hilo = sprintf('%s%s/OUF_rgb_hilo.tif',exp.root_path, folder_name);        if exist(save_ouf_rgb_hilo);delete(save_ouf_rgb_hilo);end
    save_ouf_colormap = sprintf('%s%s/cm_OUF.tif',exp.root_path, folder_name);        if exist(save_ouf_colormap);delete(save_ouf_colormap);end
    save_Orientation_colormap = sprintf('%s%s/cm_Orientation.tif',exp.root_path, folder_name);        if exist(save_Orientation_colormap);delete(save_Orientation_colormap);end
    
    emi_s = hilo_num / emi_n;
    t_num = hilo_num / (emi_n * ext_n * ang_n);
    for t_c = 1: t_num
        t_s = (t_c-1)*(ext_n * ang_n);
        hilo_pm_561ex_561em = hilo(:,:,(c_select-1)*emi_s + t_s + 1: (c_select-1)*emi_s + t_s + ang_n);
        hilo_pm_488ex_561em = hilo(:,:,ang_n + (c_select-1)*emi_s + t_s + 1: ang_n + (c_select-1)*emi_s + t_s + ang_n);
        
        hilo_avg_561ex = mean(hilo_pm_561ex_561em, 3);
        cmin = min(min(hilo_avg_561ex));
        wf_b = hilo_avg_561ex - cmin;
        cmax = max(wf_b(:));
        [hilo_dc, hilo_ac, hilo_ang, hilo_ouf, hilo_om, Ori_colomap] = recon_pm(hilo_pm_561ex_561em, exp.angle, [], cmin, cmax);
        
        % Pseudo-color maps of OUF
        ouf_min = 0.1; ouf_max = 0.7;
        hue2_s = 0.77; hue2_e = 0.23;
        [hilo_ouf_rgb, ouf_colomap] = drawRGB(hilo_ouf, hilo_avg_561ex, img_bg, ouf_min, ouf_max, hue2_s, hue2_e);
        
        % save polarization results
        imwrite(hilo_om, save_om_hilo, 'WriteMode', 'append');
        imwrite(uint16(hilo_ang/pi * 18000), save_angle_hilo, 'WriteMode', 'append');
        imwrite(uint16(hilo_ouf * 10000), save_ouf_hilo, 'WriteMode', 'append');
        imwrite(uint8(hilo_ouf_rgb * 255), save_ouf_rgb_hilo, 'WriteMode', 'append');
    end
    imwrite(ouf_colomap, save_ouf_colormap, 'WriteMode', 'overwrite');
    imwrite(Ori_colomap, save_Orientation_colormap, 'WriteMode', 'overwrite');
end





