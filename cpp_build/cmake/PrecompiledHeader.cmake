function(AddPrecompiledHeader targets)
    if (NOT USE_PCH)
		return()
	endif()
	
	if (CMAKE_GENERATOR MATCHES "^Visual Studio")
		set(PrecompiledHeader "aspose_pch.h")
		set(PrecompiledSource "${ASPOSE_ROOT}/pch/aspose_pch.cpp")
		set(PrecompiledBinary "$(IntDir)$(TargetName).pch")

		set_source_files_properties(${PrecompiledSource}
									PROPERTIES COMPILE_FLAGS "/Yc\"${PrecompiledHeader}\" /Fp\"${PrecompiledBinary}\""
											   OBJECT_OUTPUTS "${PrecompiledBinary}")
	    source_group("pch" FILES ${PrecompiledSource})
		add_definitions("-Zm500 /Yu\"${PrecompiledHeader}\" /FI\"${PrecompiledHeader}\" /Fp\"${PrecompiledBinary}\" /MP")
		
		foreach (target IN ITEMS ${targets})
			target_sources(${target} PRIVATE ${PrecompiledSource})
			target_include_directories(${target} PRIVATE "${ASPOSE_ROOT}/pch")
		endforeach()
	else()
		list(LENGTH targets target_count)
		if (${target_count} EQUAL "1")
			set_target_properties(${targets} PROPERTIES
				COTIRE_CXX_PREFIX_HEADER_INIT "${ASPOSE_ROOT}/pch/aspose_pch.h"
				COTIRE_ADD_UNITY_BUILD FALSE)
			cotire("${targets}")
		endif()
	endif()
endfunction()

function (GeneratePrecompiledHeader)
    if (NOT USE_PCH OR NOT MSVC)
		return()
	endif()
	
    set(PrecompiledHeader "aspose_pch.h")
    set(PCH_FILE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/pch/${PrecompiledHeader}")

    file(GLOB_RECURSE HEADER_FILES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}/include" "${CMAKE_CURRENT_SOURCE_DIR}/include/system/*.h")
    list(SORT HEADER_FILES)

    set(pch_new "// Automatically generated by CMake\n")
    set(pch_new "${pch_new}#pragma once\n\n")
    set(pch_new "${pch_new}#include <defines.h>\n")
    set(pch_new "${pch_new}#include <detail.h>\n")
    set(pch_new "${pch_new}#include <fwd.h>\n")
    foreach (FILENAME ${HEADER_FILES})
        set(pch_new "${pch_new}#include <${FILENAME}>\n")
    endforeach()
    
    set(pch_old "")
    
    if (EXISTS "${PCH_FILE_PATH}")
        file(READ "${PCH_FILE_PATH}" pch_old)
    endif()
    
    if (NOT pch_old STREQUAL pch_new)
        file(WRITE "${PCH_FILE_PATH}" "${pch_new}")
    endif()
endfunction()