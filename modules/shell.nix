{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.binutils
    pkgs.gcc_multi # Or a specific gcc version if needed
    # Add any other build dependencies for Thor-OS here
  ];
  nativeBuildInputs = [ pkgs.pkg-config ]; # Often needed for building
  shellHook = ''
    export TARGET=x86_64-elf
    export PREFIX="$PWD/opt/cross" # Adjust this path if needed
    export PATH="$PREFIX/bin:$PATH"
    export CC="x86_64-elf-gcc" # You might need to adjust the prefix later
    export CXX="x86_64-elf-g++" # You might need to adjust the prefix later
    export LD="x86_64-elf-ld"   # You might need to adjust the prefix later
  '';
}
