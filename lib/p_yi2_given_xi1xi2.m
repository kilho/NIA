function [p, x, y] = p_yi2_given_xi1xi2(xi, yi, x2, r, img, height, width)

x = round(r*cos(x2)+xi);
y = round(r*sin(x2)+yi);

if y<=0 || y>height || x<=0 || x>width || yi<=0 || yi>height || xi<=0 || xi>width
    p = -inf;
else
    p = 0;
    for i = 1:r
        xt = round(i*cos(x2)+xi);
        yt = round(i*sin(x2)+yi);
        p = p + log(img(yt,xt));
    end
%     if img(y,x) >0.5
%         p = -inf;
%     else
%     p = log(img(y,x));
%     end
%     p = img(y,x);
end

% p = log(normpdf(p,img(yi,xi),1));
%p = log(p);

% % display
% figure(100)
% imshow(img)
% hold on
% plot(x,y,'.')
% hold off

end