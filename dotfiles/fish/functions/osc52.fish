function osc52 --description 'Copy stdin to the local clipboard via OSC 52'
    printf '\e]52;c;'
    base64 --wrap=0
    printf '\a'
end
