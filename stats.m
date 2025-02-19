function priors = stats()
    priors = zeros(3, 2, 3); 
    vs = zeros(2, 1, 3);
    p25 = [.25 .75]'; 
    p50 = [.5 .5]'; 
    p75 = [.75 .25]'; 

    for i = 1:3
        vs(:, :, i) = [i + 3, i + 6]';
        priors(:, :, i) = [e_v(vs(:, :, i), p25), s_d(vs(:, :, i), p25); 
                              e_v(vs(:, :, i), p50), s_d(vs(:, :, i), p50); 
                              e_v(vs(:, :, i), p75), s_d(vs(:, :, i), p75)]; 
    end
    clear vs p25 p50 p75 i
end

%%% HELPER FUNCTIONS %%% 

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