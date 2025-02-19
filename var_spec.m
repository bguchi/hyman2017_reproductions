%% 
% *RELEVANT VARIABLE SPECIFICATIONS (Fig. 2A)*
% 
% *hyman2017_reproductions*
% 
% The "home" directory containing the interactive ('live', |.mlx|) reproductions 
% script, function (e.g., |calc_unpds.m|) scripts, data on ESPs for all sessions 
% (|SwitchTrials.mat|), the |images| sub-directory, and the |3portdata| sub-directory. 
% The reproductions script must *always* be run in this directory. 
% 
% *3portdata*
% 
% Directory containing data for 16 sessions (|.mat| files) and a sub-directory 
% of neural spike data. We will *never* work with the neural spike data for this 
% reproduction.  
% 
% Each session in the |3portdata| directory is structured the same. The relevant 
% variables for our purposes are : 
% 
% ----
% 
% |EVENT_TIMESTAMPS|
%% 
% * |(3*num_trials| or |3*num_trials + 1)| x 3 matrix of doubles
% * Each row represents a portion of a trial: (1) the trial start, (2) the nose 
% poke for that trial, and (3) the reward/no reward outcome. Some sessions append 
% a singular trial start to the end of the collected data, explaining the variable 
% number of rows. 
% * C1: start time (s) of portion 
% * C2: end time (s) of portion 
% * C3: portion code 
%% 
% C3, the portion code, is coded by the following scheme: 
%% 
% * 10, 11, 12: the cue light is illuminated at port 1, 2, or 3
% * 1, 2, 3: a nose poke is recorded at port 1, 2, or 3
% * 4, 5, 6: a reward is recorded at port 1, 2, or 3
% * 7, 8, 9: a no-reward is recorded at port 1, 2, or 3
%% 
% |Event_timestamps| only codes for "kosher" trial sequences (i.e., sequences 
% at a singular port). Consequently, 10-1-4 could appear in the matrix, but never 
% something like 12-1-4, 10-2-4, 10-7-4, etc. (since these violate events at a 
% single port or sequence ordering).
% 
% ----
% 
% |TV1|
%% 
% * 1 x (|variable|) row vector of doubles
% * Each column represents a timestamp of the session; the sampling rate is 
% 100 Hz = .01 s, i.e., every column is separated by .01s
% * Row 1 records the raw timestamp (s) at column |i| 
%% 
% Somewhat annoyingly, |Tv1| does not start from 0s. Therefore events as timestamped 
% in |Event_timestamps| or |Poke_Entries| always need to be appropriately "zeroed" 
% and indexed with |Tv1|. 
% 
% ----
% 
% |POKE_ENTRIES|, |POKE_ENTRIES{25, 50, 75}|
%% 
% * (|size(Tv1, 2) - 1|) x 1 vector of doubles 
% * Each row represents a |Tv1|-corresponding timestamp of the given session; 
% presumably, the first timestamp of |Tv1| got "cut off", since the first poke-relevent 
% event occurs far after the start of each session
% * Col 1 records whether a nose poke occurred (|1| for true, |0| for false) 
% at *any* of the 25%, 50%, or 75% ports at the timestamp corresponding to row 
% |i|
%% 
% |Poke_Entries25/50/75| is formatted the same as |Poke_Entries|, but port-specific 
% (e.g., whether a nose poke occurred at the 25% port at the timestamp corresponding 
% to row |i|).   
% 
% 
% 
% |**********|
% 
% *IRRELEVANT VARIABLE SPECIFICATIONS (Fig. 2A)*
% 
% Durations: 500 x 3 double
%% 
% * N rows: (N = number of trials) NAN-padded until 500 rows
% * C1: duration of event (s - float)
% * C2: port (1/2/3 - int) entered
% * C3: rewarded (1) or not (2) (int - should be treated as boolean)
% * rows ordered by port and reward, in ascending order; then NAN-padded
%% 
% Event_ints: 2 x 3 matrix 
%% 
% * rows: 
% * C1: 
% * C2: 
% * C3: 
% * descriptor
%% 
% Events_ints5: 1 x 3 vector
%% 
% * rows
% * C1: 
% * C2: 
% * C3:
% * descriptor
%% 
% Tmtx: 1 x (5*T) matrix (float)
%% 
% * log of 5 Hz (every 200ms) sampled times over duration (T) of session
%% 
% iFR: num_cells x (5*T) matrix (float)
%% 
% * num_cells rows: number of cells identified by pre-processed spike sorting 
% algorithm 
% * 5*T columns: log of pre-processed instantaneous firing rates sampled at 
% 5 Hz (every 200ms) over duration (T) of session
%% 
% STbin1: num_cells x (100*T) matrix (ints)
%% 
% * num_cells rows: number of cells identified by pre-processed spike sorting 
% algorithm
% * 100*T columns: