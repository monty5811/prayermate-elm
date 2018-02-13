[![Build Status](https://semaphoreci.com/api/v1/monty5811/prayermate-elm/branches/master/badge.svg)](https://semaphoreci.com/monty5811/prayermate-elm)

This is an _unofficial_ web client for PrayerMate.

<img src="/screenshot.png?raw=true">

## Why?
https://twitter.com/andygeers/status/908439768643641344

## Features

 * Quickly edit your PrayerMate data
 * Drag and drop interface
 * Purely client side - your data is never sent to a server
 * Automatically saves your current state in case you accidentally clsoe the tab
 * Get started quickly with some demo data

## How to use it

 * Export your from PrayerMate - this gives you a `.json` file
 * Go to https://prayermate.deanmontgomery.com and import your data (**Note** the client is all run client side - your data is never sent to a server)
 * Edit your data until you are happy
 * Export from the web client - this gives you anoterh `.json` file
 * Import this new file into PrayerMate

## Caveats

 * This is **alpha** quality software with no guarantees - make sure you have backups of your PrayerMate data
 * Attachments are ignored
 * The PrayerMate import is purely additive, if you delete something in the web client, it will not be deleted when you reimport into the app. To get around this limitation, delete all your data in the PrayerMate before you import the new file. **Remember to backup your data before you do this**

## CSV Import

Visit [prayermate.deanmontgomery.com/csv](https://prayermate.deanmontgomery.com/csv) to convert CSV data for import into PrayerMate.

<img src="/screenshot_csv.png?raw=true">

## Contributing

This is a purely client side app written in [Elm](http://elm-lang.org) (with some javascript to handle files and localstorage).
Styling is done with [tailwind](https://tailwindcss.com).

### Prerequisites

 * Install node

### Development

Getting started:

```
# clone repo
git clone https://github.com/monty5811/prayermate-elm.git
cd prayermate-elm
# install
yarn
# run dev server
yarn dev
# the app should now be running on localhost:4001 and will watch the source files for changes
```

Tests:

```
yarn generate_fixtures  # requires python installed
yarn test
```

Code formatting, please format your code before committing:

```
yarn format:js
yarn format:elm
```

Build:

```
yarn build
# public will now be populated with files ready for deployment
```
