function [hilo_wf,hilo_si] = hilo_pre(img_raw_all, exp)
%hilo_pre channel split, channel register, hilo wf and si image stack
%           prepare
%   img_raw_all: multi-channel raw image
%   exp: Experimental parameters

%% channle split
img_size = [size(img_raw_all, 1), size(img_raw_all, 1)];
img_num = size(img_raw_all, 3);

img_t1 = img_raw_all(img_size(1)/2+1: img_size(1), 1: img_size(2)/2, :);
img_t2 = img_raw_all(1: img_size(1)/2, img_size(2)/2+1: img_size(2), :);
img_t3 = img_raw_all(img_size(1)/2+1: img_size(1), img_size(2)/2+1: img_size(2), :);

%% registration
loc1 = exp.reg(:,:,1);
loc2 = exp.reg(:,:,2);
loc3 = exp.reg(:,:,3);

tmp = pinv(loc2)*loc1; 
tmp(:,3) = [0;0;1];
tform = affine2d(tmp);
R = imref2d(size(img_t1(:,:,1)));
fillval = min(img_t2(:));
img_t2 = imwarp(img_t2, tform, 'bilinear','Outputview',R,'FillValues',fillval);
loc2_reg = loc2 * tform.T;

tmp = pinv(loc3)*loc1; 
tmp(:,3) = [0;0;1];
tform = affine2d(tmp);
fillval = min(img_t3(:));
img_t3 = imwarp(img_t3, tform, 'bilinear','Outputview',R,'FillValues',fillval);
loc3_reg = loc3 * tform.T;

%% hilo preparation
img_sep_all = cat(3, img_t1, img_t2, img_t3);
clearvars img_t1 img_t2 img_t3
hilo_si = img_sep_all(:,:,1:2:end);
hilo_si_2 = img_sep_all(:,:,2:2:end);
hilo_wf = (hilo_si + hilo_si_2) / 2;

end



















