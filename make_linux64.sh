mkdir -p build_linux64 && cd build_linux64
cmake ../
cd ..
cmake --build build_linux64 --config Release
cp build_linux64/libkcp.so Plugins/x86_64/libkcp.so
rm -rf build_linux64
