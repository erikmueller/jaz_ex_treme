# JazExTreme

This is a follow up of [Jazmax](https://github.com/erikmueller/jazmax?tab=readme-ov-file#jazmax) 

> a crawler that reads the calculated JAZ for different heat pumps based on flow and return temperatures from https://www.waermepumpe.de/jazrechner/. The aggregated data is formatted, sorted by combined efficiency, and written to a local data.json file.

only that this implementation uses an API client to get the data rather than running a browser to go through form submission.

## Installation

```sh
mix deps.get
```

## Running

```sh
mix start
```
