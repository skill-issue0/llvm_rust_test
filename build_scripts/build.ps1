$llvm_version = "16.0.5"

# Check if scoop is installed
if (!(Get-Command "scoop" -errorAction SilentlyContinue)) {
    irm get.scoop.sh | iex
}

if (!(Get-Command "git" -errorAction SilentlyContinue)) {
    Write-Output "git is not installed, installing with scoop"
    scoop install git
}

if (!(Get-Command "cmake" -errorAction SilentlyContinue)) {
    Write-Output "cmake is not installed, installing with scoop"
    scoop install cmake
}

if (!(Get-Command "7z" -errorAction SilentlyContinue)) {
    Write-Output "7z is not installed, installing with scoop"
    scoop install 7z
}


function build-msvc {
    $msvc_version = $args[0]
    $msvc_cmake_generator = $args[1]
    $crt_release = $args[2]
    $crt_release_capitalized = "$crt_release".ToUpper()
    $current_dir = (Get-Location)
    $source_dir = "$current_dir\llvm"
    $build_dir = "$source_dir\build"
    $install_dir = "$current_dir\llvm-$llvm_version-windows-x64-$msvc_version-$crt_release"

    # Clone the llvm repository
    git clone --single-branch --branch "llvmorg-$llvm_version" --depth 1 "https://github.com/llvm/llvm-project.git" $source_dir

    # Construct a build directory and run cmake
    New-Item -ItemType "directory" -Force -Path $build_dir
    cmake `
        -S "$source_dir\llvm" `
        -B $build_dir `
        -G $msvc_cmake_generator `
        -Thost=x64 `
        -A x64 `
        -DLLVM_ENABLE_PROJECTS="lld;clang" `
        -DCMAKE_BUILD_TYPE=Release `
        -DCMAKE_INSTALL_PREFIX="$install_dir" `
        -DLLVM_ENABLE_LIBXML2=OFF `
        -DLLVM_ENABLE_ZLIB=OFF `
        -DLLVM_USE_CRT_RELEASE="$crt_release_capitalized"
        #-DLLVM_ENABLE_ASSERTIONS=ON

    # Build the project
    New-Item -ItemType "directory" -Force -Path $install_dir
    cmake --build $build_dir --target INSTALL --config Release

    # Create an archive from the installation
    7z a -mx9 "llvm-$llvm_version-windows-x64-$msvc_version-$crt_release.7z" "$install_dir\*"

    # Clean up all the directories
    Get-ChildItem -Path $install_dir -Force -Recurse | Remove-Item -force -recurse -Confirm:$false
    Get-ChildItem -Path $source_dir -Force -Recurse | Remove-Item -force -recurse -Confirm:$false
    Remove-Item $install_dir -Force -Recurse -Confirm:$false
    Remove-Item $source_dir -Force -Recurse -Confirm:$false
}

build-msvc "msvc17" "Visual Studio 17 2022" "mt"
build-msvc "msvc16" "Visual Studio 16 2019" "mt"

build-msvc "msvc17" "Visual Studio 17 2022" "md"
build-msvc "msvc16" "Visual Studio 16 2019" "md"