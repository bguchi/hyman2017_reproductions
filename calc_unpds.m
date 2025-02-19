function unpds = calc_unpds(Event_timestamps, Tv1, init_ids, esp, Poke_Entries25, Poke_Entries50, Poke_Entries75)
% CALC_UNPDS Calculate unsolicited nose poke durations at each port, for each trial of a session.
%   * Event_timestamps: (...)
%   * Tv1: (...)
%   * init_ids: (str array) the initial (inferred) port contingencies
%      e.g. ["50" "25" "75"] denotes P1 as 50-50 port, P2 as 25-75, etc. 
%   * esp: (int) (inferred) ESP
%   * Poke_Entries25/50/75: (...)
% CALC_UNPDS outputs a num_trials x 3 matrix of UNPDs
%    e.g. entry (j, 2) reflects the UNPD of trial J at P2

    num_trials = floor(size(Event_timestamps, 1) / 3);
    tv1_sr = 1 / (Tv1(2) - Tv1(1)); 
    tv1_start = Tv1(1); 
    ports_to_probs = dictionary(1:3, init_ids);
    probs_to_ports = dictionary(init_ids, 1:3);

    unpds1 = zeros(esp - 1, 3); 
    for i = 1 : esp - 1
        unpds1(i, :) = calc_unpds_for_trial(i); 
    end

    swap_ports_and_probs();  

    unpds2 = zeros(num_trials - esp + 1, 3); 
    for i = esp : num_trials
        unpds2(i - esp + 1, :) = calc_unpds_for_trial(i);
    end 

    unpds = [unpds1 ; unpds2];

    %%% HELPER FUNCTIONS %%%

    function idx = pe_index(start, raw_t, start_bool)
        idx = (raw_t - start) * tv1_sr;
        if start_bool 
            idx = floor(idx); 
        else 
            idx = ceil(idx);
        end
    end
    
    function swap_ports_and_probs()
        init25p = probs_to_ports("25%"); 
        init75p = probs_to_ports("75%");

        ports_to_probs(init25p) = "75%";
        probs_to_ports("75%") = init25p; 

        ports_to_probs(init75p) = "25%";
        probs_to_ports("25%") = init75p; 
    end

    function unpds_for_trial_i = calc_unpds_for_trial(i)
        % Event_timestamps trial start and end (raw time, including ITI)
        start_idx = 3*(i-1) + 1; 
        end_idx = 3*i; 

        % Poke_Entries trial start and end 
        pe_start_idx = pe_index(tv1_start, Event_timestamps(start_idx, 1), 1);

        % handling variable Event_timestamps structure
        % either 3*(num_trials) or 3*(num_trials) + 1 rows (recording ITI)
        if i == num_trials
            % if ITI recorded at end, normal assignnment
            if mod(length(Event_timestamps), 3) == 1
                pe_end_idx = pe_index(tv1_start, Event_timestamps(end_idx, 1), 0);
            else 
                pe_end_idx = pe_index(tv1_start, Event_timestamps(end_idx - 1, 1), 0); 
            end
        else 
            pe_end_idx = pe_index(tv1_start, Event_timestamps(end_idx, 1), 0);
        end

        trial_entries25 = Poke_Entries25(pe_start_idx : pe_end_idx);
        trial_entries50 = Poke_Entries50(pe_start_idx : pe_end_idx);
        trial_entries75 = Poke_Entries75(pe_start_idx : pe_end_idx);

        probs = ["25%", "50%", "75%"];
        trial_entries = {trial_entries25 trial_entries50 trial_entries75};
        probs_to_trials = dictionary(probs, trial_entries); 
        
        dur_p1 = 0; 
        dur_p2 = 0; 
        dur_p3 = 0; 
        port_code = Event_timestamps(start_idx, 3);
        calc_durs(); 

        ports_to_durs = dictionary(1:3, [dur_p1 dur_p2 dur_p3]); 
        unpds_for_trial_i = [ports_to_durs(probs_to_ports("25%")) 
                             ports_to_durs(probs_to_ports("50%"))
                             ports_to_durs(probs_to_ports("75%"))]';
        
        %%% HELPER FUNCTION %%%
        function calc_durs()
            if port_code == 10 
                p2_prob = ports_to_probs(2); 
                p3_prob = ports_to_probs(3); 
                dur_p2 = dur_p2 + sum(tv1_sr * probs_to_trials{p2_prob});
                dur_p3 = dur_p3 + sum(tv1_sr * probs_to_trials{p3_prob}); 
            elseif port_code == 11 
                p1_prob = ports_to_probs(1); 
                p3_prob = ports_to_probs(3); 
                dur_p1 = dur_p1 + sum(tv1_sr * probs_to_trials{p1_prob});
                dur_p3 = dur_p3 + sum(tv1_sr * probs_to_trials{p3_prob});
            else 
                p1_prob = ports_to_probs(1); 
                p2_prob = ports_to_probs(2); 
                dur_p1 = dur_p1 + sum(tv1_sr * probs_to_trials{p1_prob});
                dur_p2 = dur_p2 + sum(tv1_sr * probs_to_trials{p2_prob});
            end
        end

    end

end
