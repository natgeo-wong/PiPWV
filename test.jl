using Dierckx
using Seaborn

x = collect(0:0.5:10); y = rand(length(x));
spl1 = Spline1D(x,y,k=1); spl2 = Spline1D(x,y,k=2); spl3 = Spline1D(x,y,k=3);
xint = collect(0:0.01:10); yint1 = spl1.(xint); yint2 = spl2.(xint); yint3 = spl3.(xint);
yint = (yint1 .+ yint2) / 2

close()
figure()
# plot(x,y)
# plot(xint,yint)
# plot(xint,yint2)
# plot(xint,yint3)
plot(xint,yint-yint1)
plot(xint,yint2-yint1)
plot(xint,yint3-yint1)
xlim(0,10); grid("on")
gcf()
