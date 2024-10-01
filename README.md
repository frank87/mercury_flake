# mercury_flake
Mercury integration for nixos flakes

create a flake in your source directory like this:

{
  description = "My qt application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    mercury_flake.url = "github:frank87/mercury_flake";
  };

  outputs = { self, nixpkgs, mercury_flake }: {
        defaultPackage.x86_64-linux = with import nixpkgs { system = "x86_64-linux"; }; 
                        mercury_flake.build{ 
                                # src: source of your program
                                src=self;
                                # pname: name of the executable (like make --make)
                                pname="maze"; 
                                # mercuryLibs: packages containing build mercury-libraries
                                mercuryLibs = with mercury_flake.packages.x86_64-linux; [ mercury_opengl mercury_glut ]; 
                                # buildInputs: other dependencies(just like mkDerivation)
                                buildInputs = []; 
                        };
  };
 
}

And build with 
    nix build

Outputs:
    * packages.x86_64-linux.<library-name> - libraries from the extras-directory in the main mercury distribution.
    * build  - funtion making a derivation.
