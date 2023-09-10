function [r2,pv] = my_regress(x,y)

x = reshape(x, 1, [])';
y = reshape(y, 1, [])';

X = [ones(size(x)), x];
[b,bint,r,rint,stats] = regress(y,X);

r2 = stats(1);
pv = stats(3);

xx = linspace(min(x),max(x),100);
plot(xx, b(1)+b(2)*xx, 'r-', 'LineWidth',1)

end