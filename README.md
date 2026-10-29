# HEXVULTURE

GlitchByte Phantom Labs

Public-source X research toolkit for Linux.

## Features

- Live terminal post collection
- Posts 50, 75, and 100
- Followers and Following account IDs
- Following usernames AUTO
- Optional text output using -o
- Offline saved-results history

## Example: Posts 50

    bash recipes/HEXVULTURE-RECIPES.sh posts50 https://x.com/ACCOUNT

## Example: Live + Save

    bash recipes/HEXVULTURE-LIVE-SAVE.sh posts50 https://x.com/ACCOUNT -o output.txt

Replace ACCOUNT with a public X username.

## Privacy

Never publish browser cookies, credentials, private
investigation files, or identifying computer details.

Some modes may require an operator-owned authenticated
browser session. Respect privacy and platform rules.


## Installation requirements

Install Python 3 and `gallery-dl` on Linux.
The `gallery-dl` executable must be available in PATH.

A recommended isolated installation is:

    pipx install gallery-dl

Check availability with:

    gallery-dl --version

## Browser authentication

Some X collection modes require the operator's own
Firefox session. The tool reads browser authentication
locally when needed; session contents must never be
included in a repository, report, or shared package.

## Portable example

From the downloaded repository folder:

    bash recipes/HEXVULTURE-RECIPES.sh posts50 https://x.com/ACCOUNT

To save results while printing live:

    bash recipes/HEXVULTURE-LIVE-SAVE.sh posts50 https://x.com/ACCOUNT -o output.txt

Replace ACCOUNT with the desired public profile username.


<!-- HEXVULTURE-PUBLIC-INSTALL-v1 -->
## Quick Start

After downloading and extracting the repository:

    bash INSTALL.sh
    bash RUN.sh --help

### Live posts

    bash RUN.sh posts50 https://x.com/ACCOUNT

### Following usernames

    bash RUN.sh usernames-auto https://x.com/ACCOUNT

### Live + Save

    bash RUN.sh posts100 https://x.com/ACCOUNT -o output.txt

The output file is saved locally. Existing files are not overwritten.

Replace ACCOUNT with an X username. Some modes may require
your own authenticated Firefox browser session.

Never share browser cookies, credentials, private research
files or identifying device information.

