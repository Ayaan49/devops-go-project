
{
	description = "";
	
	inputs = {
		 nixpkgs-1ebb7d7bba2953a4223956cfb5f068b0095f84a7.url = "github:nixos/nixpkgs/1ebb7d7bba2953a4223956cfb5f068b0095f84a7";
		 nixpkgs-ac5c1886fd9fe49748d7ab80accc4c847481df14.url = "github:nixos/nixpkgs/ac5c1886fd9fe49748d7ab80accc4c847481df14";
		 nixpkgs-7445ccd775d8b892fc56448d17345443a05f7fb4.url = "github:nixos/nixpkgs/7445ccd775d8b892fc56448d17345443a05f7fb4";
		 nixpkgs-d7570b04936e9b0f5268e0d834dee40368ad3308.url = "github:nixos/nixpkgs/d7570b04936e9b0f5268e0d834dee40368ad3308";
			
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		 gomod2nix.url = "github:nix-community/gomod2nix";
		gomod2nix.inputs.nixpkgs.follows = "nixpkgs";
		
		
		
		
		
		

		 
		 nix2container.url = "github:nlewo/nix2container";
	};
	
	outputs = inputs@{ self, nixpkgs, 
	 gomod2nix, 
	
	
	
	 nix2container , 
	 nixpkgs-1ebb7d7bba2953a4223956cfb5f068b0095f84a7, 
	 nixpkgs-ac5c1886fd9fe49748d7ab80accc4c847481df14, 
	 nixpkgs-7445ccd775d8b892fc56448d17345443a05f7fb4, 
	 nixpkgs-d7570b04936e9b0f5268e0d834dee40368ad3308, 
	 }: let
	  supportedSystems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" "aarch64-linux" ];
	  
	  
	  forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
		inherit system;
		 nix2containerPkgs = nix2container.packages.${system}; 
		 nixpkgs-1ebb7d7bba2953a4223956cfb5f068b0095f84a7-pkgs = import nixpkgs-1ebb7d7bba2953a4223956cfb5f068b0095f84a7 { inherit system; };
		 nixpkgs-ac5c1886fd9fe49748d7ab80accc4c847481df14-pkgs = import nixpkgs-ac5c1886fd9fe49748d7ab80accc4c847481df14 { inherit system; };
		 nixpkgs-7445ccd775d8b892fc56448d17345443a05f7fb4-pkgs = import nixpkgs-7445ccd775d8b892fc56448d17345443a05f7fb4 { inherit system; };
		 nixpkgs-d7570b04936e9b0f5268e0d834dee40368ad3308-pkgs = import nixpkgs-d7570b04936e9b0f5268e0d834dee40368ad3308 { inherit system; };
		
		 buildGoApplication = gomod2nix.legacyPackages.${system}.buildGoApplication;
		pkgs = import nixpkgs { inherit system;  };
		
		
	  });
	in {
	
	packages = forEachSupportedSystem ({ pkgs,
		 buildGoApplication, 
		
		
		 nixpkgs-1ebb7d7bba2953a4223956cfb5f068b0095f84a7-pkgs, 
		 nixpkgs-ac5c1886fd9fe49748d7ab80accc4c847481df14-pkgs, 
		 nixpkgs-7445ccd775d8b892fc56448d17345443a05f7fb4-pkgs, 
		 nixpkgs-d7570b04936e9b0f5268e0d834dee40368ad3308-pkgs, 
		 ... }: {
		default = pkgs.callPackage ./default.nix {
			 inherit buildGoApplication;
			go = pkgs.go_1_22; 
			
			
			
		};
	  });
	
	  devShells = forEachSupportedSystem ({ pkgs, 
		 buildGoApplication, 
		
		
		 nixpkgs-1ebb7d7bba2953a4223956cfb5f068b0095f84a7-pkgs, 
		 nixpkgs-ac5c1886fd9fe49748d7ab80accc4c847481df14-pkgs, 
		 nixpkgs-7445ccd775d8b892fc56448d17345443a05f7fb4-pkgs, 
		 nixpkgs-d7570b04936e9b0f5268e0d834dee40368ad3308-pkgs, 
		 ... }: {
		devShell = pkgs.mkShell {
		  # The Nix packages provided in the environment
		  packages =  [
			nixpkgs-1ebb7d7bba2953a4223956cfb5f068b0095f84a7-pkgs.bash  
			nixpkgs-7445ccd775d8b892fc56448d17345443a05f7fb4-pkgs.coreutils-full  
			nixpkgs-d7570b04936e9b0f5268e0d834dee40368ad3308-pkgs.delve  
			nixpkgs-7445ccd775d8b892fc56448d17345443a05f7fb4-pkgs.go  
			nixpkgs-d7570b04936e9b0f5268e0d834dee40368ad3308-pkgs.gotools  
			
		  ];
		};
	  });
	
	  runtimeEnvs = forEachSupportedSystem ({ pkgs,
		 buildGoApplication, 
		
		
		 nixpkgs-1ebb7d7bba2953a4223956cfb5f068b0095f84a7-pkgs,  nixpkgs-ac5c1886fd9fe49748d7ab80accc4c847481df14-pkgs,  nixpkgs-7445ccd775d8b892fc56448d17345443a05f7fb4-pkgs,  nixpkgs-d7570b04936e9b0f5268e0d834dee40368ad3308-pkgs,  ... }: {
		runtime = pkgs.buildEnv {
		  name = "runtimeenv";
		  paths = [ 
			nixpkgs-ac5c1886fd9fe49748d7ab80accc4c847481df14-pkgs.cacert   
			
		   ];
		};
	   });

	   devEnvs = forEachSupportedSystem ({ pkgs,
		 buildGoApplication, 
		
		
	    nixpkgs-1ebb7d7bba2953a4223956cfb5f068b0095f84a7-pkgs,  nixpkgs-ac5c1886fd9fe49748d7ab80accc4c847481df14-pkgs,  nixpkgs-7445ccd775d8b892fc56448d17345443a05f7fb4-pkgs,  nixpkgs-d7570b04936e9b0f5268e0d834dee40368ad3308-pkgs,  ... }: {
		development = pkgs.buildEnv {
		  name = "devenv";
		  paths = [ 
			nixpkgs-1ebb7d7bba2953a4223956cfb5f068b0095f84a7-pkgs.bash  
			nixpkgs-7445ccd775d8b892fc56448d17345443a05f7fb4-pkgs.coreutils-full  
			nixpkgs-d7570b04936e9b0f5268e0d834dee40368ad3308-pkgs.delve  
			nixpkgs-7445ccd775d8b892fc56448d17345443a05f7fb4-pkgs.go  
			nixpkgs-d7570b04936e9b0f5268e0d834dee40368ad3308-pkgs.gotools  
			
		   ];
		};
	   });
       
	   
	   
	   

ociImage_dev = forEachSupportedSystem ({ pkgs, nix2containerPkgs, system ,  nixpkgs-1ebb7d7bba2953a4223956cfb5f068b0095f84a7-pkgs,  nixpkgs-ac5c1886fd9fe49748d7ab80accc4c847481df14-pkgs,  nixpkgs-7445ccd775d8b892fc56448d17345443a05f7fb4-pkgs,  nixpkgs-d7570b04936e9b0f5268e0d834dee40368ad3308-pkgs,  ... }: {
  
  ociImage_dev_app = nix2containerPkgs.nix2container.buildImage {
    name = "ttl.sh/gonew/go:demo";
    copyToRoot = [ inputs.self.packages.${system}.default ];
    config = {
      cmd = [  "devops-go-project.git"  ];
      entrypoint = [  ];
      env = [
         "foo=bar"
      ];
      ExposedPorts = {
         "8080/tcp" = {}; 
      };
    };
    maxLayers = 100;
    layers = [
      
      
    ];
  };
  

  

  
  ociImage_dev_app-as-dir = pkgs.runCommand "image-as-dir" { } "${inputs.self.ociImage_dev.${system}.ociImage_dev_app.copyTo}/bin/copy-to dir:$out";
  
  
  });



	   
	};
}
