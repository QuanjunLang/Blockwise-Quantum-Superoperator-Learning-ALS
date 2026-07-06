clear all
clc


Num_samples = 10;
%%
load("p_1_4.mat")

all_M = 50:10:250;
all_p = 1:1:4;
Num_M = length(all_M);
Num_p = length(all_p);

recover_rate_1_4 = zeros(Num_p, Num_M);
for l = 1:Num_p
    for m = 1:Num_M
        recover_rate_1_4(l, m) = sum(squeeze(all_info(l, 1, m, :)) < 1e-5)/Num_samples;
    end
end
figure;imagesc((all_p), (all_M), recover_rate_1_4');colormap(gray);set(gca, 'YDir', 'normal');


%%
load("p_3_4.mat")

all_M = 80:10:260;
all_p = 3:1:4;
Num_M = length(all_M);
Num_p = length(all_p);

recover_rate_3_4 = zeros(Num_p, Num_M);
for l = 1:Num_p
    for m = 1:Num_M
        recover_rate_3_4(l, m) = sum(squeeze(all_info(l, 1, m, :)) < 1e-5)/Num_samples;
    end
end
figure;imagesc((all_p), (all_M), recover_rate_3_4');colormap(gray);set(gca, 'YDir', 'normal');


%%
load("p_5_6.mat")

all_M = 140:10:260;
all_p = 5:1:6;
Num_M = length(all_M);
Num_p = length(all_p);

recover_rate_5_6 = zeros(Num_p, Num_M);
for l = 1:Num_p
    for m = 1:Num_M
        recover_rate_5_6(l, m) = sum(squeeze(all_info(l, 1, m, :)) < 1e-5)/Num_samples;
    end
end


figure;imagesc((all_p), (all_M), recover_rate_5_6');colormap(gray);set(gca, 'YDir', 'normal');


%%
load("p_7_9.mat")

all_M = 180:10:260;
all_p = 7:1:9;
Num_M = length(all_M);
Num_p = length(all_p);

recover_rate_7_9 = zeros(Num_p, Num_M);
for l = 1:Num_p
    for m = 1:Num_M
        recover_rate_7_9(l, m) = sum(squeeze(all_info(l, 1, m, :)) < 1e-5)/Num_samples;
    end
end

figure;imagesc((all_p), (all_M), recover_rate_7_9');colormap(gray);set(gca, 'YDir', 'normal');
%%
load("p_10_14.mat")

all_M = 210:10:260;
all_p = 10:1:14;
Num_M = length(all_M);
Num_p = length(all_p);

recover_rate_10_14 = zeros(Num_p, Num_M);
for l = 1:Num_p
    for m = 1:Num_M
        recover_rate_10_14(l, m) = sum(squeeze(all_info(l, 1, m, :)) < 1e-5)/Num_samples;
    end
end

figure;imagesc((all_p), (all_M), recover_rate_10_14');colormap(gray);set(gca, 'YDir', 'normal');
%%
all_M = 50:10:260;
all_p = 1:14;

Num_M = length(all_M);
Num_p = length(all_p);

recover_rate = zeros(Num_p, Num_M);
recover_rate(1:4, 1:end-1) = recover_rate_1_4;
recover_rate(1:4, end) = 1;

recover_rate(3:4, 4:end) = recover_rate_3_4;
recover_rate(5:6, 10:end) = recover_rate_5_6;
% recover_rate(5:7, 8:end) = recover_rate_5_7;
recover_rate(7:9, 14:end) = recover_rate_7_9;
recover_rate(10:14, 17:end) = recover_rate_10_14;


figure;imagesc((all_p), (all_M), recover_rate');colormap(gray);set(gca, 'YDir', 'normal');