cmake_minimum_required(VERSION 3.13.4)
project(WasmLang1)

# Set the LLVM version you want to build
set(LLVM_VERSION "16.0.0")

# Include the CMakeLists.txt in the llvm-project-12.0.1/build directory
add_subdirectory(llvm-project/build)
