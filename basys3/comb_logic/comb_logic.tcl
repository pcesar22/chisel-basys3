lappend ::auto_path ../

package require basys3lib 1.0

# Setup globals
::basys3lib::set_proj_name "comb_logic"
::basys3lib::set_proj_root "."
::basys3lib::set_output_dir "./output"
::basys3lib::set_bitstream_dir "."

::basys3lib::global_print
