% initialize all variables for this model
mVec = [1; 2];
jVec = [0; 0];
phi0Vec = [0; 0];
lVec = [5; 5];
sVec = [3; 3];

kVec = [0; 0];
g = 9.8;

a1 = mVec(1) * sVec(1)^2 + jVec(1) + mVec(2) * lVec(1)^2;
a2 = lVec(1) * sVec(2) * cos(phi0Vec(1) - phi0Vec(2));
b1 = lVec(1) * sVec(2) * cos(phi0Vec(1) - phi0Vec(2));
b2 = mVec(2) * sVec(2)^2 + jVec(2);

d1 = (mVec(1) * a1 + mVec(2) * lVec(2)) * g;
d2 = mVec(2) * a2 * g;

x1 = -kVec(1) * a2 / (a2 * b1 - a1 * b2);
x2 = kVec(2) * a1 / (a2 * b1 - a1 * b2);
x3 = a2 / (a2 * b1 - a1 * b2);
x4 = -a1 / (a2 * b1 - a1 * b2);
x5 = -(d1 * a2 + d2 * a1) / (a2 * b1 - a1 * b2);

y1 = -kVec(1) * b2 / (a2 * b1 - a1 * b2);
y2 = kVec(2) * b1 / (a2 * b1 - a1 * b2);
y3 = b2 / (a2 * b1 - a1 * b2);
y4 = -b1 / (a2 * b1 - a1 * b2);
y5 = (d2 * b1 - d1 * b2) / (a2 * b1 - a1 * b2);

x11 = d1 * a2 * sin(phi0Vec(1)) / (a2 * b1 - a1 * b2);
x12 = d2 * a1 * sin(phi0Vec(2)) / (a2 * b1 - a1 * b2);
x13 = (-d1 * a2 * cos(phi0Vec(1)) - d1 * a2 * sin(phi0Vec(1)) * phi0Vec(1)) / ...
    (a2 * b1 - a1 * b2) + (-d2 * a1 * cos(phi0Vec(2)) - ...
    d2 * a1 * sin(phi0Vec(2)) * phi0Vec(2)) / (a2 * b1 - a1 * b2);

y11 = d1 * b2 * sin(phi0Vec(1)) / (a2 * b1 - a1 * b2);
y12 = -d2 * b1 * sin(phi0Vec(2)) / (a2 * b1 - a1 * b2);
y13 = (d2 * b1 * cos(phi0Vec(2)) + d2 * b1 * sin(phi0Vec(2)) * phi0Vec(2)) / ...
    (a2 * b1 - a1 * b2) + (-d1 * b2 * cos(phi0Vec(1)) - ...
    d1 * b2 * sin(phi0Vec(1)) * phi0Vec(1)) / (a2 * b1 - a1 * b2);

%initialize A and B relying on theoretical materials
aMat = [0 0 1 0; 0 0 0 1; y11 y12 y1 y2; x11 x12 x1 x2];
bMat = [0 0; 0 0; y3 y4; x3 x4];

endTime = 5;
