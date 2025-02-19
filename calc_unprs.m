 function unprs = calc_unprs(esp, unpds)
 % CALC_UNPRS Calculate unsolicited nose poke rates at each port, across a session. 
 %   * esp: (int) (inferred) ESP
 %   * unpds: (num_trials x 3 double) UNPDs as output by CALC_UNPDS
 % CALC_UNPRS outputs a 1 x 6 matrix of UNPRs for each port-block mix of a session. 

    % split unpds into pre-/post-ESP
    unpds1 = unpds(1 : esp, :); 
    unpds2 = unpds(esp + 1 : end, :);
    
    % calculate unprs by trial block and port 
    totals_unpds1 = sum(unpds1); 
    totals_unpds2 = sum(unpds2);
    grand_total_unpds1 = sum(totals_unpds1); 
    grand_total_unpds2 = sum(totals_unpds2); 
    
    unpr_pre25 = totals_unpds1(1) / grand_total_unpds1; 
    unpr_pre50 = totals_unpds1(2) / grand_total_unpds1;
    unpr_pre75 = totals_unpds1(3) / grand_total_unpds1;
    unpr_post25 = totals_unpds2(1) / grand_total_unpds2; 
    unpr_post50 = totals_unpds2(2) / grand_total_unpds2;
    unpr_post75 = totals_unpds2(3) / grand_total_unpds2;

    unprs = [unpr_pre25 unpr_pre50 unpr_pre75 unpr_post25 unpr_post50 unpr_post75]; 
end