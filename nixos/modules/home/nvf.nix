{ nvf, lib, pkgs, ... }:
{
	imports = [ nvf.homeManagerModules.nvf ];

	programs.nvf = {
		enable = true;
		defaultEditor = true;

		settings = {
			vim = {
				viAlias = true;
				vimAlias = true;

				# Editor basics
				lineNumberMode = "relNumber";
				searchCase = "smart";
				preventJunkFiles = true;
				clipboard.enable = true;
				bell = "none";
				options = {
					cmdheight = 0;
					termguicolors = true;
				};

				# Theme
				theme = {
					enable = true;
					name = lib.mkForce "tokyonight";
					style = "night";
					transparent = lib.mkForce true;
				};

				# LSP
				lsp = {
					enable = true;
					formatOnSave = true;
					lightbulb.enable = true;
					lspSignature.enable = true;
				};

				# Treesitter + language support
				languages = {
					enableTreesitter = true;
					enableExtraDiagnostics = true;
					nix.enable = true;
					bash.enable = true;
					python.enable = true;
					go.enable = true;
					json.enable = true;
					yaml.enable = true;
					toml.enable = true;
					markdown.enable = true;
					lua.enable = true;
				};

				# mini.nvim modules
				mini = {
					statusline.enable = true;
					pick.enable = true;
					git.enable = true;
					files.enable = true;
					starter.enable = true;
					hipatterns.enable = true;
					completion.enable = true;
					snippets.enable = true;
					pairs.enable = true;
					comment.enable = true;
					cmdline.enable = true;
				};

				startPlugins = with pkgs.vimPlugins; [
					mason-nvim
					mason-lspconfig-nvim
				];

				luaConfigPre = ''
					vim.g.mapleader = " "
					vim.g.maplocalleader = " "
				'';

		luaConfigPost = ''
			require("mason").setup()
			require("mason-lspconfig").setup()
			vim.keymap.set("n", "<Leader>e", MiniFiles.open, { desc = "File explorer" })
		'';
			};
		};
	};
}
