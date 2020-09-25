function [dc, ac, alpha, ouf, om, cm] = recon_pm(pm, pol, eps, cmin, cmax, calib)
%% test module
% pol = [0, pi/4, pi/4*2, pi/4*3];
% pm = cos(2*(pol-pi/4));

% pol = mod(pol + pi/2,pi);

% calibration
if (nargin < 6)
    calib = ones([size(pm, 1), size(pm, 2), 2]);
end

calib_1 = double(calib(:,:,1)) / 10000;
calib_2 = double(calib(:,:,2)) / 10000;
calib_1(calib_1 < 0.1) = 1;
calib_1(calib_1 > 10) = 1;
calib_2(calib_2 < 0.1) = 1;
calib_2(calib_2 > 10) = 1;

pm(:,:,2) = pm(:,:,2) ./ calib_1;
pm(:,:,3) = pm(:,:,3) ./ calib_2;

%%
if length(size(pm))<3
    pm = reshape(pm, 1, 1, length(pm));
end
%% cal matrix
mat_pm = zeros(length(pol),3);
for kk = 1 : size(mat_pm,1)
    mat_pm(kk,:) = [1 cos(2*pol(kk)) sin(2*pol(kk))];
end
mat_pm_inv = pinv(mat_pm);
% cal pm factors
pm_f = zeros(size(pm,1), size(pm,2), 3);
for kk = 1 : size(mat_pm_inv,1)
    for ll = 1 : size(mat_pm_inv,2)
        pm_f(:,:, kk)= pm_f(:,:,kk) + mat_pm_inv(kk,ll)*pm(:,:,ll);
    end
end
% obtain dc, ac
dc = pm_f(:,:,1);
ac = sqrt(pm_f(:,:,2).^2+pm_f(:,:,3).^2);
% obtain alpha
alpha = zeros(size(dc));
alpha1 = mod(atan(pm_f(:,:,3)./pm_f(:,:,2))/2, pi);
alpha2 = mod((atan(pm_f(:,:,3)./pm_f(:,:,2))+pi)/2, pi);
alpha(pm_f(:,:,2)>=0) = alpha1(pm_f(:,:,2)>=0);
alpha(pm_f(:,:,2)<0) = alpha2(pm_f(:,:,2)<0);
% cal ouf
ouf = 2*ac./(ac+dc);
%% generate om image
%
h = alpha/pi;       % 将alpha转变为0~1
s = 0.6*ones(size(h));
% s = ouf;
%
wf = dc;
% wf = mean(pm, 3);
wf = max(wf-cmin, 0); 
wf = min(wf/cmax, 1);
v = wf;
%
om_hsv = cat(3, h, s, v);
om = hsv2rgb(om_hsv);
%% generate cm image
%
cm = zeros(100, 100);
s = 0.6*ones(size(cm));
%
xx = 0:size(cm,1)-1; yy = xx; c0 = size(cm,1)/2-0.5;
[xx,yy] = meshgrid(xx,yy);
radius = sqrt((xx-c0).^2+(yy-c0).^2);
mask = (radius <= 50) .* (radius>30);  
v = ones(size(cm)).*mask;
%
phy = atan((c0-yy)./(xx-c0));
phy = mod(phy, pi);
h = phy/pi;
%
cm_hsv = cat(3, h, s, v);
cm = hsv2rgb(cm_hsv);
