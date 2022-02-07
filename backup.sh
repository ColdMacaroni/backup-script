#!/usr/bin/zsh
# Back up me pc
# Copyright (C) 2022  ColdMacaroni
# Licensed under GPLv3

DIRS_TO_BACK=( "/etc" "/usr/local" "/usr/share/backgrounds" "/home/muffin/bin" "/home/muffin/Documents" "/home/muffin/projects" "/home/muffin/Pictures" "/home/muffin/Downloads" "/home/muffin/git" "/home/muffin/clones" "/home/muffin/.backups" "/home/muffin/.themes"  "/home/muffin/.ssh" "/home/muffin/.config" "/home/muffin/.oh-my-zsh")

FILES_TO_BACK=("/home/muffin/.zshrc" "/home/muffin/.zsh_history" "/home/muffin/.xinitrc" "/home/muffin/.profile" "/home/muffin/TODO" "/home/muffin/notes")

# --- Check directory existence
echo "Checking dirs..."
# Count how many dont exist, if non zero then ask if continue
errors=0
for f in ${DIRS_TO_BACK[@]}
do
    if ! test -d "$f"
    then
        >&2 echo "Directory $f was not found"
        errors=$(($errors + 1))
    fi
done

if [ $errors -gt 0 ]
then
    read "REPLY?$errors directories were missing. Continue? [y/N]: "
    if ! [ "$REPLY" = "y" -o "$REPLY" = "Y" ]
    then
        echo Cancelling.
        exit 1
    fi
else
    echo "All directories good"
fi

# --- Check file existence
echo "Checking files..."
# Count how many dont exist, if non zero then ask if continue
errors=0
for f in ${FILES_TO_BACK[@]}
do
    if ! test -f "$f"
    then
        >&2 echo "File $f was not found"
        errors=$(($errors + 1))
    fi
done

if [ $errors -gt 0 ]
then
    read "REPLY?$errors files were missing. Continue? [y/N]: "
    if ! [ "$REPLY" = "y" -o "$REPLY" = "Y" ]
    then
        echo Cancelling.
        exit 1
    fi
else
    echo "All files good"
fi

dest="$1"

# check that we have a destination
if [ -z "$dest" ]
then
    >&2 echo "Please specify backup destination as argument"
    exit 1

# Check that that destination actually exists
elif ! [ -d "$dest" ]
then
    >&2 echo "$dest does not exist or isn't a directory"
    exit 1
# Permissions?
elif ! [ -w "$dest" ]
then
    >&2 echo "You do not have write permissions for $dest"
    exit 1
fi

echo "Script currently does not handle overwriting files." 
read "REPLY?Are you okay with that? [y/N]: "
if ! [ "$REPLY" = "y" -o "$REPLY" = "Y" ]
then
    echo Cancelling.
    exit 1
fi

# Exit on error.
echo "From now on, will exit on error."
set -e

# DIRS
echo "Backing dirs..."
for f in ${DIRS_TO_BACK[@]}
do
    # path/////to//file is the same as path/to/file
    # In zsh at least
    simple_dir_name="$(basename "$f")"

    # no need to mkdir -p, tar already makes the fancy stuff
    output="$dest/${simple_dir_name}.tar.xz"

    echo "Backing $f to $output"

    # compress and preserve permissions, at max power
    tar -c -p -I 'xz -9 -T0' \
        -f "$output"\
        "$f"
done
echo "Directories done"
echo

echo "Backing files..."
for f in ${FILES_TO_BACK[@]}
do
    # path/////to//file is the same as path/to/file
    # In zsh at least
    simple_dir_name="$(basename "$f")"

    # no need to mkdir -p, tar already makes the fancy stuff
    output="$dest/${simple_dir_name}.tar.xz"

    echo "Backing $f to $output"

    # compress and preserve permissions, at max power
    tar -c -p -I 'xz -9 -T0' \
        -f "$output"\
        "$f"
done
echo "Files done"
echo
echo "All done"

# TODO: Add xz validation with `xz -t ${file}.tar.xz` (ret 0 on correct)
