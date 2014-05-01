# Generic Convertor For Bright Star Catalogue, 5th Revised Ed.

## Install

This tool requires node.js.

In the folder of `convert.coffee`

* `npm install` following dependencies:
  - coffee
  - async
  - underscore

* Download BSC data files and put `bsc5.dat` and `notes` in this folder

* Write your own underscore template and save it in this folder

## Run

Just:

```shell
coffee convert template\_file\_name output\_file\_name
```

## Writing Templates

You should learn to write underscore template first.

A single variable named `data` is passed to the template. It's an array of all star entries.

Entry format:

```javascript
{
  id: 1,
  // other fields
  notes: [/**array of notes**/]
}
```

Note Format:

```javascript
{
  id: 1,
  category: 'something',
  remarks: 'something else'
}
```

