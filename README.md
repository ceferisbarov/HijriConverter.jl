# hijri-converter

<!-- start description -->

A Julia package to convert accurately between Hijri and Gregorian dates
using the Umm al-Qura calendar.

<!-- end description -->

<!-- start summary -->

## Features

- Multilingual representation of weekday names, months, and calendar era notations.
- Easily extendable to support other natural languages.
- Rich comparison between dates.
- Validation of input dates.

## Limitations

- The date range supported by converter is limited to the period from the beginning
  of 1343 AH (1 August 1924 CE) to the end of 1500 AH (16 November 2077 CE).
- The conversion is not intended for religious purposes where sighting of the lunar
  crescent at the beginning of Hijri month is still preferred.

## Installation

## Basic Usage

```julia
import hijri_converter: Hijri, Gregorian, to_hijri, to_gregorian


# Convert a Hijri date to Gregorian
g = to_gregorian(Hijri(1403, 2, 17))

# Convert a Gregorian date to Hijri
h = to_hijri(Gregorian(1982, 12, 2))
```

<!-- end summary -->

## Documentation


## Progress and Feedback
You can follow progress of the project from [this Trello board](https://trello.com/b/tGMCDQjH). You can email me at cefer.isbarov@gmail.com for any feedback or suggestion.

## License

This project is licensed under the terms of the MIT license.

## Acknowledgements

This project is roughly a direct translation of Python library [hijri-converter](https://github.com/dralshehri/hijri-converter). Changes were made where a certain Python feature did not exist in Julia. We do intend to add extra functionality to the project.
