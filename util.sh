#!/bin/bash
LocateUsersShellProfile() {
    local __resultvar=$1
    if [[ -f ~/.zshrc ]]; then
        eval "$__resultvar"=~/.zshrc
    elif [[ -f ~/.bashrc ]]; then
        eval "$__resultvar"=~/.bashrc
    else
        echo "Could not find your shell profile (searched for ~/.zshrc and ~/.bashrc)"
        echo "Aborting."
        return 1
    fi
}

WaitForYesNo() {
    while :; do
        read -r
        [[ $REPLY =~ ^[Yy]$ ]] && return
        [[ $REPLY =~ ^[Nn]$ ]] && return 1
        echo "Enter 'y' or 'n': "
    done
}

# Prompts user to add an alias entry to a user's shell profile.
# If confirmed, adds an alias line.
AddShellAlias() {
    local SHELL_PROFILE
    LocateUsersShellProfile SHELL_PROFILE || return 1
    local ALIAS_BODY=$1
    if grep -q "${ALIAS_BODY}" "${SHELL_PROFILE}"; then return 0; fi
    echo "The following alias will be added to your ${SHELL_PROFILE}:"
    echo "${ALIAS_BODY}"
    echo "Do you want to continue (y - yes, n - to skip adding the alias): "
    WaitForYesNo || return
    local FIRST_ALIAS_LINE_NUM
    FIRST_ALIAS_LINE_NUM=$(grep -n "^alias" "${SHELL_PROFILE}" | head -1 | cut -d: -f1)
    if (( FIRST_ALIAS_LINE_NUM > 0 )); then
        echo "Adding alias to $SHELL_PROFILE at line ${FIRST_ALIAS_LINE_NUM}"
        { head -n $((FIRST_ALIAS_LINE_NUM - 1)) "$SHELL_PROFILE"; echo "$ALIAS_BODY"; tail -n +"${FIRST_ALIAS_LINE_NUM}" "$SHELL_PROFILE"; } > tmpfile && mv tmpfile "$SHELL_PROFILE"
    else
        echo "Adding alias at the end of $SHELL_PROFILE"
        echo "$ALIAS_BODY" >> "$SHELL_PROFILE"
    fi
}
