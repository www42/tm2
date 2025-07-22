# Oh My Posh (OMP)
# Install from https://ohmyposh.dev/docs/installation/windows

# Describe your prompt configuration in a json/yaml/toml file, see https://ohmyposh.dev/docs/

# Test your configuration by following command. This produces a single line representing the configuration specified.
oh-my-posh print primary --config "C:\git\tm2\OMP\myOMP.toml" --shell universal

# To use the configuration permanently in PowerShell place the following lin into your $PROFILE
oh-my-posh init pwsh --config "https://raw.githubusercontent.com/www42/tm2/refs/heads/master/OMP/tj.omp.json" | Invoke-Expression
