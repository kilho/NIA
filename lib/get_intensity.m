function [p x y] = get_intensity(xi, yi, x1, r, img, height, width)

x = round(r*cos(x1)+xi);
y = round(r*sin(x1)+yi);
if y<=0 || y>height || x<=0 || x>width
    p = -inf;
else
    p = img(y,x);
end


% % display
% figure(100)
% imshow(img)
% hold on
% plot(x,y,'.')
% hold off
% pause
end