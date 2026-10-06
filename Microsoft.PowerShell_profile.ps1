oh-my-posh init pwsh --config $env:POSH_THEMES_PATH/my_quick-term.omp.json | Invoke-Expression
#oh-my-posh init pwsh --config "paradox" | Invoke-Expression

function tsrun {
    node --experimental-strip-types $args
}