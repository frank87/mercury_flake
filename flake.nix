{
  description = "My qt application";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils }: 
  with import nixpkgs { system = "x86_64-linux"; };
  with pkgs;
  let
	build_lib = { name, buildInputs?[], mercuryLibs?[] }:
		stdenv.mkDerivation {
			pname = name;
			version = mercury.version;
			src = mercury.src;

			buildInputs = buildInputs;

			configurePhase = "echo No config";

			patchPhase = ''
					${patch}/bin/patch -p1 < ${self}/patch
					'';

			buildPhase = ''
					PATH=$PATH:${mercury}/bin
					mmc -f extras/*/*.m extras/graphics/*/*.m extras/*/library/*.m extras/*/source/*.m
					mkdir -p $out
					echo mmc --make lib${name}.install --install-prefix $out --no-libgrade --libgrade asm_fast.gc
					mmc --make lib${name}.install --install-prefix $out --no-libgrade --libgrade asm_fast.gc
					'';

			installPhase = "echo Installed";
		};
  in
  {
	packages.x86_64-linux.mercury_opengl = build_lib{ name="mercury_opengl"; buildInputs = [ libGLU libGL ncurses readline ]; };
	packages.x86_64-linux.mercury_glut = build_lib{ name="mercury_glut"; buildInputs = [ freeglut libGLU ]; };
	packages.x86_64-linux.easyx = build_lib{ name="easyx"; buildInputs = [ xorg.libX11 ]; };
	packages.x86_64-linux.mercury_glfw = build_lib{ name="mercury_glfw"; buildInputs = [ glfw2 libGL libGLU ]; };
	packages.x86_64-linux.mercury_allegro = build_lib{ name="mercury_allegro"; buildInputs = [ allegro ]; };
	packages.x86_64-linux.mercury_cairo = build_lib{ name="mercury_cairo"; buildInputs = [ cairo ]; };
	packages.x86_64-linux.mercury_tcltk = build_lib{ name="mercury_tcltk"; buildInputs = [ tcl tk ]; };
	packages.x86_64-linux.posix = build_lib{ name="posix"; buildInputs = [ ]; };
	packages.x86_64-linux.xml =  build_lib{ name="xml"; buildInputs = [ ]; };
	packages.x86_64-linux.wix =  build_lib{ name="wix"; buildInputs = [ ]; };
	packages.x86_64-linux.any =  build_lib{ name="any"; buildInputs = [ ]; };
	packages.x86_64-linux.net =  build_lib{ name="net"; buildInputs = [ ]; };
	packages.x86_64-linux.mp_int =  build_lib{ name="mp_int"; buildInputs = [ libtommath ]; };
	packages.x86_64-linux.mopenssl =  build_lib{ name="mopenssl"; buildInputs = [ openssl ]; };
	packages.x86_64-linux.moose =  build_lib{ name="moose"; buildInputs = [ ]; };
	packages.x86_64-linux.log4m =  build_lib{ name="log4m"; buildInputs = [ ]; };
	packages.x86_64-linux.lex =  build_lib{ name="lex"; buildInputs = [ ]; };
	packages.x86_64-linux.gmp_int =  build_lib{ name="gmp_int"; buildInputs = [ gmp ]; };
	packages.x86_64-linux.fixed =  build_lib{ name="fixed"; buildInputs = [ ]; };
	packages.x86_64-linux.dynamic_linking =  build_lib{ name="dl"; buildInputs = [ ]; };
	packages.x86_64-linux.curses =  build_lib{ name="mcurses"; buildInputs = [ ncurses ]; };
	packages.x86_64-linux.curs =  build_lib{ name="curs"; buildInputs = [ ncurses ]; };
	packages.x86_64-linux.complex_numbers =  build_lib{ name="complex_numbers"; buildInputs = [ ]; };
	packages.x86_64-linux.base64 =  build_lib{ name="base64"; buildInputs = [ ]; };
	packages.x86_64-linux.cgi =  build_lib{ name="cgi"; buildInputs = [ ]; };

	build = { pname, version?"0.0-0", buildInputs?[], mercuryLibs?[], src }:
		let buildInputs2 = builtins.concatLists[ buildInputs 
							 ( 
								builtins.concatLists ( builtins.catAttrs "buildInputs" mercuryLibs ) 
							) ];
		in
		stdenv.mkDerivation {
			inherit pname;
			inherit version;
			inherit src;

			buildInputs = buildInputs2;

			buildPhase = ''
				PATH=$PATH:${mercury}/bin
				MLIBDIR="${ builtins.foldl' ( x: y:  "${x} --ml ${y.pname} --mld ${y}/lib/mercury " ) "" mercuryLibs }"
				LDFLAGS=""
				for DEP in ${ builtins.foldl' ( x: y: "${x} ${y.out}" ) "" buildInputs2 }
				do
					for lib in $DEP/lib/lib*.so
					do
						libbase=''${lib%.so}
						LDFLAGS="$LDFLAGS -l''${libbase##*/lib}"
					done
				done
				echo mmc $MLIBDIR --make ${pname} $LDFLAGS $MLDFLAGS
				mmc $MLIBDIR --make ${pname} $LDFLAGS $MLDFLAGS
				'';

			installPhase = ''
				mkdir -p $out/bin
				cp ${pname} $out/bin
				'';
	};

				

  };
 
}

