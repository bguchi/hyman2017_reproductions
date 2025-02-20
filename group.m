%% Directory navigation (edit as needed)
% hyman2017_reproductions directory should be structured as specified in var_spec.txt
base = "C:\Users\talha\Desktop\Benel\hyman2017_reproductions\";
data_folder = "3portdata";

% collating session names
listing = dir(fullfile(base, data_folder, "*.mat"));
session_ids = {listing.name};
session_ids = strrep(session_ids, ".mat", "")';
sessions = table(session_ids, 'VariableNames', ["ID"]); 
clear listing session_ids 

%% Port and ESP inferrence
% visualize P1 R/NR history for Session 1
load(fullfile(base, data_folder, sessions.ID(1) + ".mat"), "Event_timestamps");

figure; 
tiledlayout(1, 2);
p1_rnr_idx_mask = ismember(Event_timestamps(:, 3), [4 7]);
p1_rnr = Event_timestamps(p1_rnr_idx_mask, 3); 

nexttile; 
plot(p1_rnr)
title("Port 1 R/NR History");
xlabel("Trial Number");
xlim([1 length(p1_rnr)]);
ylabel("R/NR Encoding");
ylim([3.5 7.5]);
yticks([4 7]);

nexttile; 
plot(movmean(p1_rnr, 5))
title(["Port 1 R/NR History", "(5-window running average)"]);
xlabel("Trial Number");
xlim([1 length(p1_rnr)]);
ylim([3.5 7.5]);
yticks([4 7]);
clear p1_rnr_idx_mask p1_rnr

% automate port contingency discrimination  
% utility statistics functions
function ev = e_v(vs, ps)
    % does not check size(vs) == size(ps)
    ev = sum(vs .* ps); 
end

function sd = s_d(vs, ps)
    % does not check size(vs) == size(ps)
    ev = e_v(vs, ps); 
    sq_diffs = (vs - ev).^ 2;

    sd = sqrt(e_v(sq_diffs, ps));
    clear ev sq_diffs
end

% generates priors  
% over combinations of reward encodings (4/7, 5/8, 6/9) and contingencies (25/75, 50/50, 75/25)
function hyp_stats = stats()
    hyp_stats = zeros(3, 2, 3); 
    vs = zeros(2, 1, 3);
    p25 = [.25 .75]'; 
    p50 = [.5 .5]'; 
    p75 = [.75 .25]'; 

    for i = 1:3
        vs(:, :, i) = [i + 3, i + 6]';
        hyp_stats(:, :, i) = [e_v(vs(:, :, i), p25), s_d(vs(:, :, i), p25); 
                              e_v(vs(:, :, i), p50), s_d(vs(:, :, i), p50); 
                              e_v(vs(:, :, i), p75), s_d(vs(:, :, i), p75)]; 
    end
    clear vs p25 p50 p75 i
end

% utility function to identify port contingencies based on R/NR history
% must check whether returned `ids` contain repeated elements
function ids = port_ids(Event_timestamps, movmean_window)
    ids = strings(3, 1); 
    hyp = stats(); 

    % filter for p1/p2 events based off associated r/nr codes
    p1_rnr = ismember(Event_timestamps(:, 3), [4 7]);
    p2_rnr = ismember(Event_timestamps(:, 3), [5 8]); 

    % calculate running averages of R/NR history
    mvm1 = movmean(Event_timestamps(p1_rnr, 3), movmean_window); 
    mvm2 = movmean(Event_timestamps(p2_rnr, 3), movmean_window);

    % classify initial port contingency based off how running averages "sandwich" around expected R/NR values 
    % assumes ESP occurs after trial 20
    if hyp(1, 1, 1) - .25*hyp(1, 2, 1) < mean(mvm1(1:20)) & mean(mvm1(1:20)) < hyp(1, 1, 1) + .25*hyp(1, 2, 1)
        ids(1) = "25%"; 
    elseif hyp(2, 1, 1) - .25*hyp(2, 2, 1) < mean(mvm1(1:20)) & mean(mvm1(1:20)) < hyp(2, 1, 1) + .25*hyp(2, 2, 1)
        ids(1) = "50%"; 
    else 
        ids(1) = "75%"; 
    end

    if hyp(1, 1, 2) - .25*hyp(1, 2, 2) < mean(mvm2(1:20)) & mean(mvm2(1:20)) < hyp(1, 1, 2) + .25*hyp(1, 2, 2)
        ids(2) = "25%"; 
    elseif hyp(2, 1, 2) - .25*hyp(2, 2, 2) < mean(mvm2(1:20)) & mean(mvm2(1:20)) < hyp(2, 1, 2) + .25*hyp(2, 2, 2)
        ids(2) = "50%"; 
    else 
        ids(2) = "75%"; 
    end
    
    rs = ["25%", "50%", "75%"]'; 
    ids(3) = rs(find(~ismember(rs, ids), 1)); 
    clear hyp p1_rnr p2_rnr mvm1 mvm2 rs
end

% infers ESP based off where running average 'flips' about 50-50 R/NR value
% should not be run on control ("50%") port
function esp = infer_esp(Event_timestamps, port_id)
    pi_rnr = ismember(Event_timestamps(:, 3), [port_id + 3, port_id + 6]);
    mvm = movmean(Event_timestamps(pi_rnr, 3), 5); 
    hyp = stats(); 

    % assumes ESP occurs after trial 20
    mask = mvm(20:end) < hyp(2, 1, port_id); 
    esp = 20 + find(mask == mask(end), 1); 
    clear pi_rnr mvm hyp mask
end
disp("The inferred ESP for session 1 occured at trial " + infer_esp(Event_timestamps, 1))
clear Event_timestamps

%% Putting it together
% Looping over sessions to collect port IDs, inferred ESPs, and actual ESPs: 
% infer port IDs and ESPs
port_id = strings(3, 1, 16);
port = zeros(1, 16);
inferred_esps = zeros(1, 16);

for i = 1:height(sessions)
    load(fullfile(base, data_folder, sessions.ID(i) + ".mat"), "Event_timestamps"); 
    port_id(:, :, i) = port_ids(Event_timestamps, 10);

    port(i) = find(~ismember(port_id(:, :, i), ["50%"]), 1);
    inferred_esps(i) = infer_esp(Event_timestamps, port(i)); 
end

port_id = reshape(port_id, [3 16])'; 
sessions.P1 = port_id(:, 1); 
sessions.P2 = port_id(:, 2); 
sessions.P3 = port_id(:, 3); 
sessions.InferredESP = inferred_esps'

% appending actual ESPs
load(fullfile(base, "SwitchTrials.mat"), "SwTrial"); 
sessions.ESP = SwTrial(:, 1); 
clear i Event_timestamps port_id port inferred_esps

%% Fig 2A: Distribution of unsolicited NPs imply learned port-reward contingencies
% assumes tracking UNP duration (not counts), does not track NPs at cued port 
unprs = zeros(height(sessions), 7); 
for i = 1 : height(sessions)
    load(fullfile(base, data_folder, sessions.ID(i) + ".mat"));
    num_trials = floor(size(Event_timestamps, 1) / 3);

    % calculate unpds for each trial
    init_ids = sessions{i, ["P1", "P2", "P3"]}; 
    session_i_unpds = calc_unpds(Event_timestamps, Tv1, init_ids, sessions.InferredESP(i), Poke_Entries25, Poke_Entries50, Poke_Entries75);

    % calculate unprs for session i by trial block and port
    unprs(i, :) = [i calc_unprs(sessions.InferredESP(i), session_i_unpds)]; 
    clearvars -except base data_folder sessions unprs
end

varnames = ["session", "pre25", "pre50", "pre75", "post25", "post50", "post75"]; 
unprs = array2table(unprs, VariableNames = varnames)
clear varnames

% Averaging over sessions and calculating standard errors on the means: 
avg_unprs = [mean(unprs.pre25), mean(unprs.pre50), mean(unprs.pre75);
             mean(unprs.post25), mean(unprs.post50), mean(unprs.post75)]; 
se_unprs = [std(unprs.pre25), std(unprs.pre50), std(unprs.pre75);
            std(unprs.post25), std(unprs.post50), std(unprs.post75)];
sem_unprs = (1 / sqrt(height(unprs))) * se_unprs; 
clear se_unprs

% Plotting the results: 
figure; 
cats = ["25%" "50%" "75%"];
b = bar(avg_unprs', 'grouped'); 

hold on

[ngroups, nbars] = size(avg_unprs'); 
x = nan(nbars, ngroups); 
for i = 1:nbars 
    x(i,:) = b(i).XEndPoints; 
end
errorbar(x',avg_unprs',sem_unprs','k','linestyle','none'); 

xlabel("Original Reward Probability");
ylabel("Unsolicited NP Proportion");
legend("Pre-ESP", "Post-ESP", 'Location', 'northwest', 'Fontsize', 5);
title("Fig. 2A: Unsolicited NPs by port");
axis padded

hold off
clear cats avg_unprs ngroups nbars x i sem_unprs

% Statistical Significance Tests
session_unprs = removevars(unprs, "session"); 
session_unprs = table2array(session_unprs); 

probs25 = repmat(["25"], 1, height(unprs));
probs50 = repmat(["50"], 1, height(unprs)); 
probs75 = repmat(["75"], 1, height(unprs)); 
pres = repmat(["pre"], 1, 3 * height(unprs)); 
posts = repmat(["post"], 1, 3 * height(unprs));

probs = repmat([probs25 probs50 probs75], 1, 2); 
blocks = [pres posts]; 
p = anovan(reshape(session_unprs, 1, []), {probs blocks},'model',2,'varnames',{'prob','block'})
clear session_unprs probs25 probs50 probs75 pres posts probs blocks p
