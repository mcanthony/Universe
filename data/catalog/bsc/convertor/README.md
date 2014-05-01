# Generic Convertor For Bright Star Catalogue, 5th Revised Ed.

## Install

This tool requires node.js.

In the folder of `convert.coffee`

* `npm install` following dependencies:
  - coffee-script
  - async
  - underscore

* [Download](https://github.com/akfish/Universe/tree/master/data/catalog/bsc#file-summary) BSC data files and put `bsc5.dat` and `notes` in this folder

* Write your own underscore template and save it in this folder

## Run

Usage:

```shell
coffee convert template_file_name output_file_name
```

Example (using the json template in this folder) :

```shell
coffee convert json bsc5.json
```

## Writing Templates

You should learn to write underscore template first.

A single variable named `data` is passed to the template. It's an array of all star entries.

### Star Entry format

```javascript
{
  id: 1,
  // other fields
  notes: [/**array of notes**/]
}
```

[Complete Field Reference](https://github.com/akfish/Universe/tree/master/data/catalog/bsc#file-catalog)

### Note Format

```javascript
{
  id: 1,
  category: 'something',
  remarks: 'something else'
}
```

[Complete Field Reference](https://github.com/akfish/Universe/tree/master/data/catalog/bsc#file-notes)

### About The Built-in `json` Template

It generates a single array containing all stars.

Each star is an array:

```javascript
[
  name,
  right_ascension_in_degree,
  declination_in_degree,
  visual_magnitude,
  mk_spectral_classification
]
```
