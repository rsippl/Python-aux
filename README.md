# Python-aux

Auxiliary libraries needed for Python3 compilation, precompiled (libpng, harfbuzz, freetype...). They can be useful for many other OpenSource projects on iOS, too.

## How to use: 

In your Xcode project, use the menu File -> "Swift Packages" -> "Add Package Dependency". In the window that opens, enter the address for this repository (https://github.com/holzschu/Python-aux.git). 

In the rightmost column, you will see "Swift Package Dependencies", and under it "Python-aux". Under "Referenced Binaries", you have all the libraries, precompiled, as "xcframework". You can link with them, embed them, and Xcode will extract the iOS or Simulator version as needed.

## How to compile: 

In this repository, run `build_all_packages.sh`. This will update the code, compile the packages, create the frameworks, create and compress the xcframeworks and output the hash sums.

For use in your own repository, update the hash sums in `Package.swift`, publish the xcframeworks.zip in the right place and enjoy.
