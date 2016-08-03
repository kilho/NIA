function p = p_y1_given_x1(xi, yi, x1, r, img, height, width)

x = round(r*cos(x1)+xi);
y = round(r*sin(x1)+yi);

if y<=0 || y>height || x<=0 || x>width || yi<=0 || yi>height || xi<=0 || xi>width
    p = -inf;
else
    p = 0;
    for i = 1:r
        xt = round(i*cos(x1)+xi);
        yt = round(i*sin(x1)+yi);
        p = p + log(img(yt,xt));
    end
%     if img(y,x) >0.5
%         p = -inf;
%     else
%     p = log(img(y,x));
%     end
%     p = img(y,x);
end
% % display
% figure(100)
% imshow(img)
% hold on
% plot(x,y,'.')
% hold off
% pause
end