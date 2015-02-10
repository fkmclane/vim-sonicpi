if exists("b:current_syntax")
  finish
endif

" Import and extend Ruby syntax
"  see :help :syn-include
runtime! syntax/ruby.vim
"syntax include @rubyNotTop syntax/ruby.vim
" syntax cluster SonicPi contains=@rubyNotTop

" From server/sonicpi/lib/sonicpi/spiderapi.rb
syntax keyword rubyKeyword at bools choose comment cue dec density dice factor? 
syntax keyword rubyKeyword in_thread inc knit live_loop ndefine one_in print 
syntax keyword rubyKeyword puts quantise rand rand_i range rdist ring rrand 
syntax keyword rubyKeyword rrand_i rt shuffle sleep spread sync uncomment 
syntax keyword rubyKeyword use_bpm use_bpm_mul use_random_seed wait with_bpm 
syntax keyword rubyKeyword with_bpm_mul with_random_seed with_tempo 
syntax keyword rubyDefine define defonce
" From server/sonicpi/lib/sonicpi/mods/sound.rb
syntax keyword rubyKeyword __freesound __freesound_path chord chord_degree 
syntax keyword rubyKeyword complex_sampler_args? control degree 
syntax keyword rubyKeyword fetch_or_cache_sample_path find_sample_with_path 
syntax keyword rubyKeyword free_job_bus hz_to_midi job_bus job_fx_group 
syntax keyword rubyKeyword job_mixer job_proms_joiner job_synth_group 
syntax keyword rubyKeyword job_synth_proms_add job_synth_proms_rm 
syntax keyword rubyKeyword join_thread_and_subthreads kill_fx_job_group 
syntax keyword rubyKeyword kill_job_group load_sample load_samples 
syntax keyword rubyKeyword load_synthdefs midi_to_hz 
syntax keyword rubyKeyword normalise_and_resolve_synth_args normalise_args! 
syntax keyword rubyKeyword note note_info play play_chord play_pattern 
syntax keyword rubyKeyword play_pattern_timed recording_save 
syntax keyword rubyKeyword resolve_sample_symbol_path rest? sample 
syntax keyword rubyKeyword sample_buffer sample_duration sample_info 
syntax keyword rubyKeyword sample_loaded? sample_names scale 
syntax keyword rubyKeyword scale_time_args_to_bpm! set_control_delta! 
syntax keyword rubyKeyword set_current_synth set_mixer_hpf! 
syntax keyword rubyKeyword set_mixer_hpf_disable! set_mixer_lpf! 
syntax keyword rubyKeyword set_mixer_lpf_disable! set_sched_ahead_time! 
syntax keyword rubyKeyword set_volume! shutdown_job_mixer stop synth 
syntax keyword rubyKeyword trigger_chord trigger_fx trigger_inst 
syntax keyword rubyKeyword trigger_sampler trigger_specific_sampler 
syntax keyword rubyKeyword trigger_synth trigger_synth_with_resolved_args 
syntax keyword rubyKeyword use_arg_bpm_scaling use_arg_checks use_debug use_fx 
syntax keyword rubyKeyword use_merged_synth_defaults use_sample_bpm 
syntax keyword rubyKeyword use_sample_pack use_sample_pack_as use_synth 
syntax keyword rubyKeyword use_synth_defaults use_timing_warnings 
syntax keyword rubyKeyword use_transpose validate_if_necessary! 
syntax keyword rubyKeyword with_arg_bpm_scaling with_arg_checks with_debug 
syntax keyword rubyKeyword with_fx with_merged_synth_defaults with_sample_bpm 
syntax keyword rubyKeyword with_sample_pack with_sample_pack_as with_synth 
syntax keyword rubyKeyword with_synth_defaults with_timing_warnings with_transpose 

unlet b:current_syntax