function [img_rgb, colormap_rgb] = drawRGB(img_h, img_v, img_bg, h_value_min, h_value_max, huel_s, huel_e)
%DrawRGB 
%
%%
img_v = img_v - img_bg;
img_v(img_v < 0) = 0;
img_v = img_v/max(img_v(:));
img_v = imadjust(img_v, stretchlim(img_v, [0.01,0.995]), [0,1]);

img_h(img_h > h_value_max) = h_value_max;
img_h(img_h < h_value_min) = h_value_min;
img_h = interp1([h_value_min, h_value_max], [huel_s, huel_e], img_h);
img_h = mod(img_h,1);

img_s = 0.9*ones(size(img_h));

img_hsv = cat(3,img_h, img_s, img_v);
img_rgb = hsv2rgb(img_hsv);

%% colormap
cm_v = ones(256,50);
cm_s = 0.9*cm_v;

% color map of ratio_c1
cm_h = interp1([h_value_min,h_value_max], [huel_e,huel_s], repmat((linspace(h_value_min,h_value_max,256))',1,50));
cm_h = mod(cm_h,1);
cm_hsv = cat(3, cm_h, cm_s, cm_v);
colormap_rgb = hsv2rgb(cm_hsv);
colormap_rgb = uint8(colormap_rgb*255);

end

