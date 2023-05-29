# Copyright (C) 2018-2023 Intel Corporation
# SPDX-License-Identifier: Apache-2.0
#

include(GNUInstallDirs)

#
# ov_common_libraries_cpack_set_dirs()
#
# Set directories for cpack
#
macro(ov_common_libraries_cpack_set_dirs)
    # override default locations for common libraries
    set(OV_CPACK_TOOLSDIR ${CMAKE_INSTALL_BINDIR}) # only C++ tools are here
    set(OV_CPACK_INCLUDEDIR ${CMAKE_INSTALL_INCLUDEDIR})
    set(OV_CPACK_LIBRARYDIR ${CMAKE_INSTALL_LIBDIR})
    if(WIN32)
        set(OV_CPACK_RUNTIMEDIR ${CMAKE_INSTALL_BINDIR})
    else()
        set(OV_CPACK_RUNTIMEDIR ${CMAKE_INSTALL_LIBDIR})
    endif()
    set(OV_WHEEL_RUNTIMEDIR ${OV_CPACK_RUNTIMEDIR})
    set(OV_CPACK_ARCHIVEDIR ${CMAKE_INSTALL_LIBDIR})
    if(CPACK_GENERATOR MATCHES "^(CONAN|VCPKG)$")
        set(OV_CPACK_IE_CMAKEDIR ${CMAKE_INSTALL_DATADIR}/openvino)
        set(OV_CPACK_NGRAPH_CMAKEDIR ${CMAKE_INSTALL_DATADIR}/openvino)
        set(OV_CPACK_OPENVINO_CMAKEDIR ${CMAKE_INSTALL_DATADIR}/openvino)
        set(OV_CPACK_PLUGINSDIR ${OV_CPACK_RUNTIMEDIR})
    else()
        set(OV_CPACK_IE_CMAKEDIR ${CMAKE_INSTALL_LIBDIR}/cmake/inferenceengine${OpenVINO_VERSION})
        set(OV_CPACK_NGRAPH_CMAKEDIR ${CMAKE_INSTALL_LIBDIR}/cmake/ngraph${OpenVINO_VERSION})
        set(OV_CPACK_OPENVINO_CMAKEDIR ${CMAKE_INSTALL_LIBDIR}/cmake/openvino${OpenVINO_VERSION})
        set(OV_CPACK_PLUGINSDIR ${OV_CPACK_RUNTIMEDIR}/openvino-${OpenVINO_VERSION})
    endif()
    set(OV_CPACK_LICENSESDIR licenses)

    ov_get_pyversion(pyversion)
    if(pyversion)
        set(OV_CPACK_PYTHONDIR ${CMAKE_INSTALL_LIBDIR}/${pyversion}/site-packages)
    endif()

    # non-native stuff
    set(OV_CPACK_SHAREDIR ${CMAKE_INSTALL_DATADIR}/openvino) # internal
    set(OV_CPACK_SAMPLESDIR ${OV_CPACK_SHAREDIR}/samples)
    set(OV_CPACK_DEVREQDIR ${OV_CPACK_SHAREDIR})
    unset(OV_CPACK_SHAREDIR)

    # skipped during common libraries packaging
    set(OV_CPACK_WHEELSDIR "tools")

    # for BW compatibility
    set(IE_CPACK_LIBRARY_PATH ${OV_CPACK_LIBRARYDIR})
    set(IE_CPACK_RUNTIME_PATH ${OV_CPACK_RUNTIMEDIR})
    set(IE_CPACK_ARCHIVE_PATH ${OV_CPACK_ARCHIVEDIR})

    if(CPACK_GENERATOR STREQUAL "BREW")
        set(CMAKE_SKIP_INSTALL_RPATH OFF)
    endif()
endmacro()

ov_common_libraries_cpack_set_dirs()

#
# Override CPack components name for common libraries generator
# This is needed to change the granularity, i.e. merge several components
# into a single one
#

macro(ov_override_component_names)
    # merge C++ and C runtimes
    set(OV_CPACK_COMP_CORE_C "${OV_CPACK_COMP_CORE}")
    set(OV_CPACK_COMP_CORE_C_DEV "${OV_CPACK_COMP_CORE_DEV}")
    # merge all pythons into a single component
    set(OV_CPACK_COMP_PYTHON_OPENVINO "pyopenvino")
    set(OV_CPACK_COMP_PYTHON_IE_API "${OV_CPACK_COMP_PYTHON_OPENVINO}")
    set(OV_CPACK_COMP_PYTHON_NGRAPH "${OV_CPACK_COMP_PYTHON_OPENVINO}")
    # merge all C / C++ samples as a single samples component
    set(OV_CPACK_COMP_CPP_SAMPLES "samples")
    set(OV_CPACK_COMP_C_SAMPLES "${OV_CPACK_COMP_CPP_SAMPLES}")
    # move requirements.txt to core-dev
    # set(OV_CPACK_COMP_OPENVINO_DEV_REQ_FILES "${OV_CPACK_COMP_CORE_DEV}")
    # move core_tools to core-dev
    # set(OV_CPACK_COMP_CORE_TOOLS "${OV_CPACK_COMP_CORE_DEV}")
endmacro()

ov_override_component_names()

#
# Override include / exclude rules for components
# This is required to exclude some files from installation
# (e.g. debian packages don't require setupvars scripts)
#

macro(ov_define_component_include_rules)
    # core components
    unset(OV_CPACK_COMP_CORE_EXCLUDE_ALL)
    set(OV_CPACK_COMP_CORE_C_EXCLUDE_ALL ${OV_CPACK_COMP_CORE_EXCLUDE_ALL})
    unset(OV_CPACK_COMP_CORE_DEV_EXCLUDE_ALL)
    set(OV_CPACK_COMP_CORE_C_DEV_EXCLUDE_ALL ${OV_CPACK_COMP_CORE_DEV_EXCLUDE_ALL})
    # licensing
    set(OV_CPACK_COMP_LICENSING_EXCLUDE_ALL EXCLUDE_FROM_ALL)
    # samples
    set(OV_CPACK_COMP_CPP_SAMPLES_EXCLUDE_ALL EXCLUDE_FROM_ALL)
    set(OV_CPACK_COMP_C_SAMPLES_EXCLUDE_ALL ${OV_CPACK_COMP_CPP_SAMPLES_EXCLUDE_ALL})
    set(OV_CPACK_COMP_PYTHON_SAMPLES_EXCLUDE_ALL EXCLUDE_FROM_ALL)
    # python
    set(OV_CPACK_COMP_PYTHON_OPENVINO_EXCLUDE_ALL EXCLUDE_FROM_ALL)
    set(OV_CPACK_COMP_PYTHON_IE_API_EXCLUDE_ALL ${OV_CPACK_COMP_PYTHON_OPENVINO_EXCLUDE_ALL})
    set(OV_CPACK_COMP_PYTHON_NGRAPH_EXCLUDE_ALL ${OV_CPACK_COMP_PYTHON_OPENVINO_EXCLUDE_ALL})
    set(OV_CPACK_COMP_PYTHON_WHEELS_EXCLUDE_ALL EXCLUDE_FROM_ALL)
    # tools
    set(OV_CPACK_COMP_CORE_TOOLS_EXCLUDE_ALL EXCLUDE_FROM_ALL)
    set(OV_CPACK_COMP_OPENVINO_DEV_REQ_FILES_EXCLUDE_ALL EXCLUDE_FROM_ALL)
    set(OV_CPACK_COMP_DEPLOYMENT_MANAGER_EXCLUDE_ALL EXCLUDE_FROM_ALL)
    # scripts
    set(OV_CPACK_COMP_INSTALL_DEPENDENCIES_EXCLUDE_ALL EXCLUDE_FROM_ALL)
    set(OV_CPACK_COMP_SETUPVARS_EXCLUDE_ALL EXCLUDE_FROM_ALL)
endmacro()

ov_define_component_include_rules()
