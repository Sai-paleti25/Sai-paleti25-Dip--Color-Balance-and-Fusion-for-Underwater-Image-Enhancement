img = imread('gry1.jpg');
im=imread('shrpe1.jpg');
img1=uint8(img);
lab1=uint8(img);
img2=uint8(im);
lab2 = img2;

% input  
R1 = double(lab1(:, :, 1)) / 255;
R2 = double(lab2(:, :, 1)) / 255;

% calculate laplacian contrast weight
Wlap1 = abs(imfilter(R1, fspecial('Laplacian'), 'replicate', 'conv'));
Wlap2 = abs(imfilter(R2, fspecial('Laplacian'), 'replicate', 'conv'));


% calculate the saliency weight
Wsal1 = saliency_detection(img1);

figure
imshow(Wsal1)
Wsal2 = saliency_detection(img2);
figure
imshow(Wsal2)

% calculate the saturation  weight
sigma = 0.25;
avg = 0.5;
Wexp1 = exp(-(R1 - avg).^2 / (2*sigma^2));
Wexp2 = exp(-(R2 - avg).^2 / (2*sigma^2));


% calculate the normalized weight
W1 = (Wlap1 + Wsal1 + Wexp1) ./ (Wlap1 + Wsal1 + Wexp1 + Wlap2  + Wsal2 + Wexp2);
figure
imshow(W1)
W2 = (Wlap2  + Wsal2 + Wexp2) ./ (Wlap1  + Wsal1 + Wexp1 + Wlap2  + Wsal2 + Wexp2);

% calculate the gaussian pyramid
level = 5;
Weight1 = gaussian_pyramid(W1, level);
figure
imshow(Weight1{2})
Weight2 = gaussian_pyramid(W2, level);

% calculate the laplacian pyramid
% input1
R1 = laplacian_pyramid(double(double(img1(:, :, 1))), level);
G1 = laplacian_pyramid(double(double(img1(:, :, 2))), level);
B1 = laplacian_pyramid(double(double(img1(:, :, 3))), level);
% input2
R2 = laplacian_pyramid(double(double(img2(:, :, 1))), level);
G2 = laplacian_pyramid(double(double(img2(:, :, 2))), level);
B2 = laplacian_pyramid(double(double(img2(:, :, 3))), level);

% fusion
for i = 1 : level
    r_py{i} = Weight1{i} .* R1{i} + Weight2{i} .* R2{i};
    g_py{i} = Weight1{i} .* G1{i} + Weight2{i} .* G2{i};
	b_py{i} = Weight1{i} .* B1{i} + Weight2{i} .* B2{i};
end


for i = level : -1 : 2
    [m, n] = size(g_py{i - 1});
    g_py{i - 1} = g_py{i - 1} + imresize(g_py{i}, [m, n]);
end
G = g_py{1};
figure
imshow(G)


for i = level : -1 : 2
    [m, n] = size(r_py{i - 1});
    r_py{i - 1} = r_py{i - 1} + imresize(r_py{i}, [m, n]);
end
R = r_py{1};



for i = level : -1 : 2
    [m, n] = size(b_py{i - 1});
    b_py{i - 1} = b_py{i - 1} + imresize(b_py{i}, [m, n]);
end
B = b_py{1};

har=uint8(R);
fusion = cat(3, uint8(R), uint8(G), uint8(B));
figure; 
imshow(fusion)
