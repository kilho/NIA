function [p, x, y] = p_y2_given_x1x2(xi, yi, x1, x2, initR, r, img, height, width)

x_ = initR*cos(x1)+xi;
y_ = initR*sin(x1)+yi;

x = round(r*cos(x2)+x_);
y = round(r*sin(x2)+y_);

if y<=0 || y>height || x<=0 || x>width
    p = -inf;
else
%     if img(y,x) > 0.5
%         p = -inf;
%     else
    p = log(img(y,x));
%     end
end

% p = log(p);

% % display
% figure(100)
% imshow(img)
% hold on
% plot(x,y,'.')
% hold off

end