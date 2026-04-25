/**
 * Name: Muhammad Sufiyan Sadiq
 * Date: 16_04_2026
 * Description: This is a package to contain any custom structs
 * the user might want to use
 * */

package cache_struct_pkg;
	typedef struct {
		bit [27:0] 	tag;
		bit [31:0] 	data;
		bit 		valid;
		bit 		dirty;
	} cache_line;
endpackage : cache_struct_pkg

