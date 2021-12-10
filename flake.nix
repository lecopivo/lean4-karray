{
  description = "KArray";

  inputs = {
    lean = {
      url = github:leanprover/lean4;
    };
    nixpkgs.url = github:nixos/nixpkgs/nixos-21.05;
    utils = {
      url = github:yatima-inc/nix-utils;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # A lean dependency
    lean-ipld = {
      url = github:yatima-inc/lean-ipld;
      # Compile dependencies with the same lean version
      inputs.lean.follows = "lean";
    };
  };

  outputs = { self, lean, utils, nixpkgs, lean-ipld }:
    let
      supportedSystems = [
        # "aarch64-linux"
        # "aarch64-darwin"
        "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      inherit (utils) lib;
    in
    lib.eachSystem supportedSystems (system:
      let
        leanPkgs = lean.packages.${system};
        pkgs = nixpkgs.legacyPackages.${system};
        KArray = leanPkgs.buildLeanPackage {
          name = "KArray";  # must match the name of the top-level .lean file
          # Where the lean files are located
          src = ./src;
        };
        Main = leanPkgs.buildLeanPackage {
          name = "Main";  # must match the name of the top-level .lean file
          deps = [ KArray ];
          # Where the lean files are located
          src = ./src;
        };
        test = leanPkgs.buildLeanPackage {
          name = "Tests";
          deps = [ KArray ];
          # Where the lean files are located
          src = ./test;
        };
        joinDepsDerivationns = getSubDrv:
          pkgs.lib.concatStringsSep ":" (map (d: "${getSubDrv d}") ([ KArray ] ++ KArray.allExternalDeps));
      in
      {
        inherit KArray Main test;
        packages = {
          Main = Main.executable;
          test = test.executable;
        };

        checks.test = test.executable;

        defaultPackage = self.packages.${system}.Main;
        devShell = pkgs.mkShell {
          inputsFrom = [ KArray.executable ];
          buildInputs = with pkgs; [
            leanPkgs.lean
          ];
          LEAN_PATH = joinDepsDerivationns (d: d.modRoot);
          LEAN_SRC_PATH = joinDepsDerivationns (d: d.src);
        };
      });
}
