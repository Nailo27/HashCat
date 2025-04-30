# Go to your vcpkg folder (already cloned earlier)
cd C:\dev\vcpkg

# Bootstrap vcpkg correctly
.\bootstrap-vcpkg.bat

# Integrate vcpkg with Visual Studio
.\vcpkg integrate install

# Now configure Hashcat
cd C:\dev\hashcat-build
cmake -B build -S hashcat -DCMAKE_TOOLCHAIN_FILE=C:/dev/vcpkg/scripts/buildsystems/vcpkg.cmake -DCMAKE_BUILD_TYPE=Release

# Build Hashcat
cmake --build build --config Release

# Go into release folder
cd build\Release

# Test Hashcat
.\hashcat.exe -I
